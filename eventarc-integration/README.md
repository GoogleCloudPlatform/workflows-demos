# Eventarc Integration

In this sample, you will see how to connect [Eventarc](https://cloud.google.com/eventarc/docs) events to [Workflows](https://cloud.google.com/workflows/docs).

More specifically, you will see how a Pub/Sub message to a topic triggers a Cloud Run service via Eventarc and the Cloud Run service in turn executes a workflow with the CloudEvent from Eventarc passed as an argument.

## Deploy a workflow

First, deploy a workflow that you want to execute. You can use the [eventarc-triggered-workflow.yaml](eventarc-triggered-workflow.yaml) as an example that simply logs out the received request.

Deploy workflow:

```sh
export WORKFLOW_NAME=eventarc-triggered-workflow
export REGION=us-central1
gcloud workflows deploy ${WORKFLOW_NAME} --source=${WORKFLOW_NAME}.yaml --location=${REGION}
```

## Deploy a Cloud Run service to trigger workflow

Next, deploy a Cloud Run service to trigger workflow. You can see the source code in [trigger-workflow](trigger-workflow) folder.

Build the container:

```sh
export PROJECT_ID=$(gcloud config get-value project)
export SERVICE_NAME=trigger-workflow
gcloud builds submit --tag gcr.io/${PROJECT_ID}/${SERVICE_NAME} .
```

Deploy the service:

```sh
gcloud run deploy ${SERVICE_NAME} \
  --image gcr.io/${PROJECT_ID}/${SERVICE_NAME} \
  --region=${REGION} \
  --allow-unauthenticated \
  --update-env-vars GOOGLE_CLOUD_PROJECT=${PROJECT_ID},WORKFLOW_REGION=${REGION},WORKFLOW_NAME=${WORKFLOW_NAME}
```

## Create a Pub/Sub Eventarc trigger

Create a Pub/Sub trigger:

```sh
gcloud eventarc triggers create trigger-${SERVICE_NAME} \
  --destination-run-service=${SERVICE_NAME} \
  --destination-run-region=${REGION} \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished"
```

Find out the Pub/Sub topic Eventarc created:

```sh
export TOPIC_ID=$(basename $(gcloud eventarc triggers describe trigger-${SERVICE_NAME} --format='value(transport.pubsub.topic)'))
```

## Trigger the workflow

Send a message to the Pub/Sub topic to trigger the workflow:

```sh
gcloud pubsub topics publish ${TOPIC_ID} --message="Hello there"
```

You should see that Workflow received the Pub/Sub message and decoded it in the logs.