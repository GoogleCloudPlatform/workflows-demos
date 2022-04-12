# Twitter sentiment analysis using Language API connector and parallel iteration

> **Note:** Parallel steps/iteration is a feature in *preview*.
> Only allow-listed projects can currently take advantage of it. Please fill out
> [this form](https://docs.google.com/forms/d/e/1FAIpQLSf6n6QR3PD_coYr2CjnJejQ6qp1knHA8KdSsqPlkVwzBCZn2Q/viewform)
> to get your project allow-listed before attempting this sample.

In this sample, you will see how to use [Cloud Natural Language API
connector](https://cloud.google.com/workflows/docs/reference/googleapis/language/Overview)
and parallel [iteration](https://cloud.google.com/workflows/docs/reference/syntax/iteration)
syntax to analyze sentiments of latest tweets of from multiple Twitter handles.

Each Twitter handle is handled in a parallel branch.

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

Create a [workflow.yaml](workflow.yaml) to define the workflow.

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
          - twitterHandleResults : {} # results from branches keyed by twitter handle
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
              - initBranch:
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
      assign:
        - numberOfTweets: ${len(searchTweetsResult.body.data)}
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

You can see the full [workflow.yaml](workflow.yaml).

## Deploy and execute workflow

Deploy workflow:

```sh
gcloud workflows deploy twitter-sentiment-parallel \
    --source=workflow.yaml
```

Run the workflow:

```sh
gcloud workflows run twitter-sentiment-parallel --data='{"bearerToken":"", "twitterHandles":["googlecloudtech", "googlecloud","google", "cnn", "bbcworld"],"maxResults":"50"}'
```

After a few minutes, you should see the see the result:

```sh
...
result: '{"bbcworld":{"averageSentiment":-0.20000000000000004,"minSentimentIndex":25,"minSentimentScore":-0.9,"numberOfTweets":50,"totalSentimentScore":-10.000000000000002},"cnn":{"averageSentiment":-0.038000000000000006,"minSentimentIndex":41,"minSentimentScore":-0.7,"numberOfTweets":50,"totalSentimentScore":-1.9000000000000001},"google":{"averageSentiment":0.03200000000000001,"minSentimentIndex":45,"minSentimentScore":-0.1,"numberOfTweets":50,"totalSentimentScore":1.6000000000000003},"googlecloud":{"averageSentiment":0.16521739130434782,"minSentimentIndex":32,"minSentimentScore":-0.6,"numberOfTweets":46,"totalSentimentScore":7.6},"googlecloudtech":{"averageSentiment":0.06285714285714286,"minSentimentIndex":26,"minSentimentScore":-0.5,"numberOfTweets":35,"totalSentimentScore":2.2}}'
```
