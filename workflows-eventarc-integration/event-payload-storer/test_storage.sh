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
WORKFLOW_NAME=event-payload-storer
SERVICE_ACCOUNT=eventarc-workflows

echo "Get the project id"
PROJECT_ID=$(gcloud config get-value project)

echo "Grant the pubsub.publisher role to the Cloud Storage service account needed for Eventarc's Cloud Storage trigger"
SERVICE_ACCOUNT_STORAGE="$(gsutil kms serviceaccount -p $PROJECT_ID)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_STORAGE \
    --role roles/pubsub.publisher

echo "Grant eventarc.eventReceiver role to service account: $SERVICE_ACCOUNT, needed for Cloud Storage trigger"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/eventarc.eventReceiver

echo "Create a Cloud Storage bucket"
BUCKET=$PROJECT_ID-bucket
gsutil mb -l $REGION gs://$BUCKET

echo "Create an Eventarc trigger to listen for events from a Cloud Storage bucket and route to $WORKFLOW_NAME workflow"
TRIGGER_NAME=$WORKFLOW_NAME-storage
gcloud eventarc triggers create $TRIGGER_NAME \
  --location=$REGION \
  --destination-workflow=$WORKFLOW_NAME \
  --destination-workflow-location=$REGION \
  --event-filters="type=google.cloud.storage.object.v1.finalized" \
  --event-filters="bucket=$BUCKET" \
  --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com

echo "Upload a file to the bucket: $BUCKET"
echo "Hello World" > random.txt
gsutil cp random.txt gs://$BUCKET/random.txt