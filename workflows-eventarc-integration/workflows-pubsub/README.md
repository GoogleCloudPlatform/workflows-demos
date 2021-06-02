# Workflows and Eventarc Pub/Sub Integration

In this sample, you will see how to connect
[Workflows](https://cloud.google.com/workflows/docs) to
[Eventarc](https://cloud.google.com/eventarc/docs).

More specifically, you will see how Workflows can send a Pub/Sub message to a
topic that triggers a Cloud Run service via Eventarc.

## Deploy a Cloud Run service to receive events

First, deploy a Cloud Run service to receive events from Eventarc.

Set some vars:

```sh
export SERVICE_NAME=hello
export REGION=us-central1
export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)
gcloud config set run/region ${REGION}
gcloud config set run/platform managed
```

Deploy to Cloud Run:

```sh
gcloud run deploy ${SERVICE_NAME} \
  --image gcr.io/cloudrun/hello \
  --allow-unauthenticated
```

## Create and connect a Pub/Sub topic to the Cloud Run service

Create a Pub/Sub topic to use between Workflows and Eventarc + Cloud Run:

```sh
export TOPIC_ID=workflows-to-eventarc-topic
gcloud pubsub topics create workflows-to-eventarc-topic
```

Connect the Pub/Sub topic to the Cloud Run service by creating an Eventarc Pub/Sub
trigger:

```sh
gcloud config set eventarc/location ${REGION}
gcloud eventarc triggers create ${SERVICE_NAME}-trigger \
  --destination-run-service=${SERVICE_NAME} \
  --destination-run-region=${REGION} \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --transport-topic=projects/${GOOGLE_CLOUD_PROJECT}/topics/${TOPIC_ID}
```

## Define workflow

Create a [workflow.yaml](workflow.yaml) to define the workflow. It simply
publishes a Pub/Sub message to the `workflows-to-eventarc-topic` topic:

```yaml
- init:
    assign:
      - project: ${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
      - topic: "workflows-to-eventarc-topic"
      - message: "Hello world!"
- publish:
    call: googleapis.pubsub.v1.projects.topics.publish
    args:
      topic: ${"projects/" + project + "/topics/" + topic}
      body:
        messages:
          - data: ${base64.encode(text.encode(message))}
    result: publish_result
- last:
    return: ${publish_result}
```

## Deploy and execute workflow

Deploy the workflow:

```sh
gcloud workflows deploy workflows-to-eventarc \
    --source=workflow.yaml
```

Execute workflow:

```sh
gcloud workflows execute workflows-to-eventarc
```

After a few seconds, you should see the Hello World Pub/Sub message received by
the Cloud Run service via Eventarc:

```sh
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME}" \
    | grep "Hello world"
```
