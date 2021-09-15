# Twitter sentiment analysis using for-in and Language API connector

In this sample, you will see how to use [Cloud Natural Language API
connector](https://cloud.google.com/workflows/docs/reference/googleapis/language/Overview)
and [for-in](https://cloud.google.com/workflows/docs/reference/syntax#for-in)
iteration syntax to analyze sentiments of latest Twitter posts of a Twitter handle.

## Twitter API

In order to use Twitter API, you need to sign up for a developer account. Once
you have the account, you need to create an app and get a bearer token to use in
your API calls. This tutorial assumes that you already have a bearer token
ready.

Twitter has an API to search for Tweets. Here's an example to get 100 Tweets
from [@GoogleCloudTech](https://twitter.com/googlecloudtech):

```sh
BEARER_TOKEN=...
TWITTER_HANDLE=@GoogleCloudTech
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

You will also calculate and average score for the sentiment of all processed
tweets.

## Enable services

First, enable required services:

```sh
gcloud services enable \
  workflows.googleapis.com \
  language.googleapis.com
```

## Define workflow

Create a `workflow.yaml` to define the workflow.

In the `init` step, read the bearer token, twitter handle, max results and
initialize a total sentiment score:

```yaml
main:
  params: [args]
  steps:
    - init:
        assign:
          - bearerToken: ${args.bearerToken}
          - twitterHandle: ${args.twitterHandle}
          - maxResults: ${args.maxResults}
          - totalSentimentScore: 0
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
Language API connector and keep track of the current and total sentiment score:

```yaml
    - processPosts:
        for:
          value: tweet
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
```

In the last steps, calculate the total and average sentiment scores and return
the result:

```yaml
    - assignResult:
        assign:
          - numberOfTweets: ${len(searchTweetsResult.body.data)}
          - averageSentiment: ${totalSentimentScore / numberOfTweets}
    - logResult:
        call: sys.log
        args:
          text: ${"Total score:" + string(totalSentimentScore) + " for n:" + string(numberOfTweets) + " tweets with average sentiment:" + string(averageSentiment)}
    - returnResult:
        return:
          numberOfTweets: ${numberOfTweets}
          totalSentimentScore: ${totalSentimentScore}
          averageSentiment: ${averageSentiment}
```

You can see the full [workflow.yaml](workflow.yaml).

## Deploy and execute workflow

Deploy workflow:

```sh
gcloud workflows deploy twitter-sentiment \
    --source=workflow.yaml
```

Execute workflow:

```sh
gcloud workflows execute twitter-sentiment \
    --data='{"bearerToken":"", "twitterHandle":"GoogleCloudTech","maxResults":"100"}'
```

After a minute or so, you should see the see the result:

```sh
gcloud workflows executions describe bcf52313-4ce9-4c4f-9b5e-2f461223923f twitter-sentiment

...
result: '{"averageSentiment":0.26562499999999983,"numberOfTweets":64,"totalSentimentScore":16.99999999999999}'
startTime: '2021-09-15T14:49:59.682689084Z'
state: SUCCEEDED
workflowRevisionId: 000008-c75
```
