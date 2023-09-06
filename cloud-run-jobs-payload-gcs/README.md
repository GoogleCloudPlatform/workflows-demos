# Execute a Cloud Run job using Workflows and event payload from Cloud Storage

This sample demonstrates how to execute a Cloud Run job with event payload saved in
Cloud Storage.

More specifically:

1. A Pub/Sub message is sent to a topic.
1. Eventarc routes the message to Workflows.
1. Workflows saves the message payload as a file in Cloud Storage bucket.
1. Workflows executes a Cloud Run job with the bucket and file information of
   the message payload.
1. Cloud Run job reads the message payload and simply prints it.

Saving the event payload to Cloud Storage allows someone to encrypt event data
with CMEK (although we don't show CMEK setup here).

## Create a Cloud Run job

Change to the directory that contains the sample code:

```sh
cd message-payload-job
```

Create the Cloud Run job by running the deployment script:

```sh
./deploy-job.sh
```

The job processes message payload files created in a Cloud Storage bucket
`gs://message-payload-[PROJECT_ID]`.

## Deploy the workflow

The sample workflow in [workflows.yaml](./workflows/workflow.yaml) accepts an
event as a parameter and saves events payload to Cloud Storage. Then, it executes
Cloud Run job to process that payload.

Deploy the workflow:

```sh
./deploy-workflow.sh
```

## Create a trigger

Create an Eventarc trigger that executes the workflow whenever a Pub/Sub message
is sent to a topic.

Create the trigger:

```sh
./create_trigger.sh
```

## Test

Test the end-to-end system by sending a message to the Pub/Sub topic:

```sh
TOPIC_NAME=message-payload-topic
gcloud pubsub topics publish $TOPIC_NAME --message="Hello World"
```

Confirm that the Cloud Run job ran as expected by viewing the job executions:

```sh
JOB_NAME=message-payload-job
gcloud run jobs executions list --job=$JOB_NAME
```

You should also see in logs that the message payload file was processed:

```sh
Processing message payload gs://message-payload-serverless-atamel/8237795530994075.data.json
Payload: {'message': {'data': 'SGVsbG8gV29ybGQ=', 'messageId': '8237795530994075', 'publishTime': '2023-09-06T10:59:29.732Z'}, 'subscription': 'projects/serverless-atamel/subscriptions/eventarc-us-central1-message-payload-trigger-sub-438'}
```
