# Twitter sentiment analysis using Language API connector and parallel iteration

> **Note:** Parallel steps/iteration is a feature in *preview*.
> Only allow-listed projects can currently take advantage of it. Please fill out
> [this form](https://docs.google.com/forms/d/e/1FAIpQLSf6n6QR3PD_coYr2CjnJejQ6qp1knHA8KdSsqPlkVwzBCZn2Q/viewform)
> to get your project allow-listed before attempting this sample.

In this sample, you will see how to use [Cloud Natural Language API
connector](https://cloud.google.com/workflows/docs/reference/googleapis/language/Overview)
and parallel [iteration](https://cloud.google.com/workflows/docs/reference/syntax/iteration)
to analyze sentiments of latest tweets of from multiple Twitter handles.

Each Twitter handle is handled in a parallel iteration step.

## Twitter API

In order to use Twitter API, you need to sign up for a developer account from
[Twitter developer
portal](https://developer.twitter.com/en/docs/developer-portal/overview). Once
you have the account, you need to create an app and get a bearer token to use in
your API calls. This tutorial assumes that you already have a bearer token ready.

Twitter has an API to search for Tweets. Here's an example to get 100 Tweets
from [@GoogleCloudTech](https://twitter.com/googlecloudtech):

```sh
BEARER_TOKEN=...
TWITTER_HANDLE=GoogleCloudTech
MAX_RESULTS=100

curl -X GET -H "Authorization: Bearer $BEARER_TOKEN" "https://api.twitter.com/2/tweets/search/recent?query=from:$TWITTER_HANDLE&max_results=$MAX_RESULTS"
```

## Cloud Natural Language API

[Natural Language API](https://cloud.google.com/natural-language) uses machine
learning to reveal the structure and meaning of texts. It has methods such as
sentiment analysis, entity analysis, syntactic analysis and more.

In this example, you will use sentiment analysis. Sentiment analysis inspects
the given text and identifies the prevailing emotional opinion within the text,
especially to determine a writer's attitude as positive, negative, or neutral.

You can see a sample sentiment analysis response
[here](https://cloud.google.com/natural-language/docs/basics#sentiment_analysis_response_fields).
You will use `score` of `documentSentiment` to identify the sentiment of each
post. Score ranges between -1.0 (negative) and 1.0 (positive) and corresponds to
the overall emotional leaning of the text.

You will also calculate average and minimum sentiment score of all processed tweets.

## Enable services

First, enable required services:

```sh
gcloud services enable \
  workflows.googleapis.com \
  language.googleapis.com
```

## Define workflow

Create a [workflow-parallel.yaml](workflow-parallel.yaml) to define the workflow.

In the `init` step, read the bearer token, twitter handles, max results for the
Twitter API.

```yaml
main:
  params: [args]
  steps:
    - init:
        assign:
          - bearerToken: ${args.bearerToken}
          - twitterHandles: ${args.twitterHandles} # list of twitter handles strings
          - maxResults: ${args.maxResults}
          - twitterHandleResults : {} # results from each iteration keyed by twitter handle
```

Next, we define a step with `parallel` keyword with a for loop. Each iteration
of the for loop runs in parallel. We also define a shared `twitterHandleResults`
variable that will hold the results from each parallel iteration:

```yaml
  - processTwitterHandles:
      parallel:
        shared: [twitterHandleResults]
        for:
            value: twitterHandle
            in: ${twitterHandles}
            steps:
              - initStep:
                  assign:
                    - totalSentimentScore: 0
                    - minSentimentScore: 1
                    - minSentimentIndex: -1
```

In the `searchTweets` step, fetch Tweets using the Twitter API:

```yaml
  - searchTweets:
      call: http.get
      args:
        url: ${"https://api.twitter.com/2/tweets/search/recent?query=from:" + twitterHandle + "&max_results=" + maxResults}
        headers:
          Authorization: ${"Bearer " + bearerToken}
      result: searchTweetsResult
```

In `processPosts` steps, analyze each Tweet in a `for-in` loop using the
Language API connector and keep track of the current, total and min sentiment
score:

```yaml
  - processPosts:
      for:
        value: tweet
        index: tweetIndex
        in: ${searchTweetsResult.body.data}
        steps:
          - analyzeSentiment:
              call: googleapis.language.v1.documents.analyzeSentiment
              args:
                  body:
                    document:
                      content: ${tweet.text}
                      type: "PLAIN_TEXT"
              result: sentimentResult
          - updateTotalSentimentScore:
              assign:
                  - currentScore: ${sentimentResult.documentSentiment.score}
                  - totalSentimentScore: ${totalSentimentScore + currentScore}
          - updateMinSentiment:
              switch:
                - condition: ${currentScore < minSentimentScore}
                  steps:
                    - assignMinSentiment:
                        assign:
                          - minSentimentScore: ${currentScore}
                          - minSentimentIndex: ${tweetIndex}
          - logTweetScore:
              call: sys.log
              args:
                text: ${string(tweetIndex) + ". " + text.substring(tweet.text, 0, 50) + "... -> " + string(currentScore) + " " + string(totalSentimentScore)}
```

In the last steps, calculate the average sentiment score and return
the results by assigning to the `twitterHandleResults` keyed under the `twitterHandle`:

```yaml
  - assignResult:
      switch:
        - condition: ${numberOfTweets == 0}
          steps:
            - assignZero:
                assign:
                  - averageSentiment: 0
        - condition: ${numberOfTweets > 0}
          steps:
            - assignAverage:
                assign:
                  - averageSentiment: ${totalSentimentScore / numberOfTweets}
  - logResult:
      call: sys.log
      args:
        text: ${"N:" + string(numberOfTweets) + " tweets with average sentiment:" + string(averageSentiment) + " min sentiment:" + string(minSentimentScore) + " at index:" + string(minSentimentIndex)}
  - returnResult:
      assign:
        - twitterHandleResults[twitterHandle]: {}
        - twitterHandleResults[twitterHandle].numberOfTweets: ${numberOfTweets}
        - twitterHandleResults[twitterHandle].totalSentimentScore: ${totalSentimentScore}
        - twitterHandleResults[twitterHandle].averageSentiment: ${averageSentiment}
        - twitterHandleResults[twitterHandle].minSentimentScore: ${minSentimentScore}
        - twitterHandleResults[twitterHandle].minSentimentIndex: ${minSentimentIndex}
```

In the last step, return the results from all parallel iterations:

```yaml
  - returnResults:
      return: ${twitterHandleResults}
```

You can see the full [workflow-parallel.yaml](workflow-parallel.yaml).

## Deploy and execute workflow

Deploy workflow:

```sh
gcloud workflows deploy twitter-sentiment-parallel \
    --source=workflow-parallel.yaml
```

Run the workflow:

```sh
gcloud workflows run twitter-sentiment-parallel --data='{"bearerToken":"", "twitterHandles":["googlecloud","googlecloudtech", "bbc", "cnn", "twitter"],"maxResults":"100"}'
```

After a few minutes, you should see the see the result:

```json
{
  "bbc": {
    "averageSentiment": 0.19230769230769226,
    "minSentimentIndex": 10,
    "minSentimentScore": -0.1,
    "numberOfTweets": 13,
    "totalSentimentScore": 2.4999999999999996
  },
  "cnn": {
    "averageSentiment": -0.020000000000000007,
    "minSentimentIndex": 72,
    "minSentimentScore": -0.8,
    "numberOfTweets": 100,
    "totalSentimentScore": -2.000000000000001
  },
  "googlecloud": {
    "averageSentiment": 0.1867924528301887,
    "minSentimentIndex": 26,
    "minSentimentScore": -0.3,
    "numberOfTweets": 53,
    "totalSentimentScore": 9.9
  },
  "googlecloudtech": {
    "averageSentiment": 0.10512820512820512,
    "minSentimentIndex": 8,
    "minSentimentScore": -0.4,
    "numberOfTweets": 39,
    "totalSentimentScore": 4.1
  },
  "twitter": {
    "averageSentiment": 0.10909090909090911,
    "minSentimentIndex": 3,
    "minSentimentScore": 0,
    "numberOfTweets": 11,
    "totalSentimentScore": 1.2000000000000002
  }
}
```

## Compare with non-parallel version

You can deploy and execute [workflow-serial.yaml](workflow-serial.yaml) to
compare the parallel version of the workflow with the non-parallel version which
usually takes 2x time.
