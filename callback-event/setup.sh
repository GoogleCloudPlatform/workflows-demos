#!/bin/bash

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

REGION=us-central1

echo "Get the project id"
PROJECT_ID=$(gcloud config get-value project)

echo "Enable required services"
gcloud services enable \
  appengine.googleapis.com \
  eventarc.googleapis.com \
  firestore.googleapis.com \
  pubsub.googleapis.com \
  workflows.googleapis.com

echo "Create an App Engine app (required for Firestore)"
gcloud app create --region=us-central

echo "Create a Firestore database"
gcloud firestore databases create --region=us-central

echo "Create a Pub/Sub topic"
TOPIC=topic-callback
gcloud pubsub topics create $TOPIC

echo "Create a Cloud Storage bucket"
BUCKET=$PROJECT_ID-bucket-callback
gsutil mb -l $REGION gs://$BUCKET

echo "Deploy a callback-event-listener workflow"
WORKFLOW_NAME=callback-event-listener
gcloud workflows deploy $WORKFLOW_NAME \
  --source=$WORKFLOW_NAME.yaml \
  --location=$REGION

echo "Create a service account for Eventarc triggers to use to invoke Workflows"
SERVICE_ACCOUNT=eventarc-workflows

gcloud iam service-accounts create $SERVICE_ACCOUNT \
  --display-name="Eventarc Workflows service account"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/eventarc.eventReceiver

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/workflows.invoker

echo "Grant the pubsub.publisher role to the Cloud Storage service account needed for Eventarc's Cloud Storage trigger"
SERVICE_ACCOUNT_STORAGE="$(gsutil kms serviceaccount -p $PROJECT_ID)"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_STORAGE \
    --role roles/pubsub.publisher

echo "Create an Eventarc trigger to listen for events from the Pub/Sub topic and route to callback-event-listener"
gcloud eventarc triggers create trigger-pubsub-events-listener \
  --location=$REGION \
  --destination-workflow=$WORKFLOW_NAME \
  --destination-workflow-location=$REGION \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --transport-topic=$TOPIC \
  --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com

echo "Create an Eventarc trigger to listen for events from the Cloud Storage bucket and route to callback-event-listener"
gcloud eventarc triggers create trigger-storage-events-listener \
  --location=$REGION \
  --destination-workflow=$WORKFLOW_NAME \
  --destination-workflow-location=$REGION \
  --event-filters="type=google.cloud.storage.object.v1.finalized" \
  --event-filters="bucket=$BUCKET" \
  --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com

echo "Deploy a callback-event-sample workflow"
WORKFLOW_NAME=callback-event-sample
gcloud workflows deploy $WORKFLOW_NAME \
  --source=$WORKFLOW_NAME.yaml \
  --location=$REGION