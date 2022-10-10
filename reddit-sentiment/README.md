# Reddit sentiment analysis using Language API connector and iteration syntax

In this sample, you will see how to use [Cloud Natural Language API
connector](https://cloud.google.com/workflows/docs/reference/googleapis/language/Overview)
and [for-in](https://cloud.google.com/workflows/docs/reference/syntax#for-in)
iteration syntax to analyze sentiments of top Reddit posts in a subreddit.

## Reddit API

Reddit has an API to get top posts in a subreddit. Here's an example to get top
4 posts in `googlecloud` subreddit:

```sh
curl -X GET https://www.reddit.com/r/googlecloud/top.json?t=month&count=4&limit=100
```

You will use this API to fetch top posts in a subreddit.

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

You will also calculate and average score for the average sentiment of all
processed posts.

## Enable services

First, enable required services:

```sh
gcloud services enable \
  workflows.googleapis.com \
  language.googleapis.com
```

## Define workflow

Create a `workflow.yaml` to define the workflow.

In the `init` step, read subreddit name and number of posts to read as runtime
arguments and initialize totalScore to keep track of total sentiment:

```yaml
main:
  params: [args]
  steps:
    - init:
        assign:
          - subreddit: ${args.subreddit}
          - count: ${args.count}
          - totalScore: 0
```

In the second step, fetch top posts using the Reddit API:

```yaml
    - getTopPosts:
        call: http.get
        args:
          url: ${"https://www.reddit.com/r/" + subreddit + "/top.json?t=month&count=" + limit + "&limit=" + limit}
        result: topPostsResult
```

Next, analyze each post in a `for-in` loop using the Language API connector:

```yaml
    - processPosts:
        for:
          value: post
          in: ${topPostsResult.body.data.children}
          steps:
            - analyzeSentiment:
                call: googleapis.language.v1.documents.analyzeSentiment
                args:
                    body:
                      document:
                        content: ${post.data.title + " " + post.data.selftext}
                        type: "PLAIN_TEXT"
                result: sentimentResult
            - updateTotalScore:
                assign:
                    - currentScore: ${sentimentResult.documentSentiment.score}
                    - totalScore: ${totalScore + currentScore}
            - logPost:
                call: sys.log
                args:
                  text: ${post.data.title + " " + post.data.selftext + ":" + string(currentScore) + " " + string(totalScore)}
```

Finally calculate the average sentiment score and return the result:

```yaml
    - assignResult:
        assign:
          - numberOfPosts: ${len(topPostsResult.body.data.children)}
          - avgSentiment: ${totalScore / numberOfPosts}
    - logResult:
        call: sys.log
        args:
          text: ${"Total score:" + string(totalScore) + " for n:" + string(numberOfPosts) + " posts with average sentiment:" + string(avgSentiment)}
    - returnResult:
        return: ${avgSentiment}
```

You can see the full [workflow.yaml](workflow.yaml).

## Deploy and execute workflow

Deploy workflow:

```sh
gcloud workflows deploy reddit-sentiment \
    --source=workflow.yaml
```

Execute workflow:

```sh
gcloud workflows execute reddit-sentiment \
    --data='{"subreddit":"googlecloud","count":"4"}'
```

After a couple of seconds, you should see the see the average sentiment under `result`:

```sh
gcloud workflows executions describe bcf52313-4ce9-4c4f-9b5e-2f461223923f --workflow reddit-sentiment --location us-central1

argument: '{"count":"4","subreddit":"googlecloud"}'
endTime: '2021-05-27T13:46:52.402307280Z'
name: projects/1011272509317/locations/us-central1/workflows/reddit-sentiment/executions/bcf52313-4ce9-4c4f-9b5e-2f461223923f
result: '-0.25'
startTime: '2021-05-27T13:46:50.202583444Z'
state: SUCCEEDED
workflowRevisionId: 000001-49b
```
