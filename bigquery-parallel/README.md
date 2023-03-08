# Running BigQuery jobs against Wikipedia dataset with Workflows parallel iteration

In this sample, you will see how to use parallel
[iteration](https://cloud.google.com/workflows/docs/reference/syntax/iteration)
to run BigQuery jobs against Wikipedia dataset in parallel.

## Before you start

First, enable required services:

```sh
gcloud services enable \
  workflows.googleapis.com
```

Give the default compute service account the required roles:

```sh
PROJECT_ID=your-project-id
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role roles/logging.logWriter \
    --role roles/bigquery.jobUser
```

## Define workflow

Create a [workflow-parallel.yaml](workflow-parallel.yaml) to define the workflow.

In the `init` step, initialize `results` map to keep track of the results and
tables we want to read from:

```yaml
main:
    steps:
    - init:
        assign:
            - results : {} # result from each iteration keyed by table name
            - tables:
                - 201201h
                - 201202h
                - 201203h
                - 201204h
                - 201205h
```

Next, we define a `runQueries` step with `parallel` keyword with a for loop.
Each iteration of the for loop runs in parallel. We also define `results` as a
shared variable so each parallel iteration can access it.

In each loop, we run a BigQuery job, extract the result and save it to the
`results` map:

```yaml
    - runQueries:
        parallel:
            shared: [results]
            for:
                value: table
                in: ${tables}
                steps:
                - logTable:
                    call: sys.log
                    args:
                        text: ${"Running query for table " + table}
                - runQuery:
                    call: googleapis.bigquery.v2.jobs.query
                    args:
                        projectId: ${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
                        body:
                            useLegacySql: false
                            useQueryCache: false
                            timeoutMs: 30000
                            # Find top 100 titles with most views on Wikipedia
                            query: ${
                                "SELECT TITLE, SUM(views)
                                FROM `bigquery-samples.wikipedia_pageviews." + table + "`
                                WHERE LENGTH(TITLE) > 10
                                GROUP BY TITLE
                                ORDER BY SUM(VIEWS) DESC
                                LIMIT 100"
                                }
                    result: queryResult
                - returnResult:
                    assign:
                        # Return the top title from each table
                        - results[table]: {}
                        - results[table].title: ${queryResult.rows[0].f[0].v}
                        - results[table].views: ${queryResult.rows[0].f[1].v}
```

In the last step, we return the `results` map:

```yaml
    - returnResults:
        return: ${results}
```

You can see the full [workflow-parallel.yaml](workflow-parallel.yaml).

## Deploy and run workflow

Deploy workflow:

```sh
gcloud workflows deploy bigquery-parallel \
    --source=workflow-parallel.yaml
```

Run the workflow:

```sh
gcloud workflows run bigquery-parallel
```

Each BigQuery job takes about 20 seconds. Since, they all run in parallel, you
should see the result from all in about 20 seconds. Thanks to the parallel
iteration!

```json
{
  "201201h": {
    "title": "Special:Search",
    "views": "14591339"
  },
  "201202h": {
    "title": "Special:Search",
    "views": "132765420"
  },
  "201203h": {
    "title": "Special:Search",
    "views": "123316818"
  },
  "201204h": {
    "title": "Special:Search",
    "views": "116830614"
  },
  "201205h": {
    "title": "Special:Search",
    "views": "131357063"
  }
}
```

## Compare with non-parallel version

You can deploy and execute [workflow-serial.yaml](workflow-serial.yaml) to
compare the parallel version of the workflow with the non-parallel version.

Deploy workflow:

```sh
gcloud workflows deploy bigquery-serial \
    --source=workflow-serial.yaml
```

Run the workflow:

```sh
gcloud workflows run bigquery-serial
```

This should take about 100 seconds (5 x 20 seconds).
