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
  eventarc.googleapis.com \
  pubsub.googleapis.com \
  workflows.googleapis.com

WORKFLOW_NAME=event-payload-storer
echo "Deploy workflow: $WORKFLOW_NAME"
gcloud workflows deploy $WORKFLOW_NAME \
  --source=$WORKFLOW_NAME.yaml \
  --location=$REGION

BUCKET=$PROJECT_ID-$WORKFLOW_NAME
echo "Create bucket: $BUCKET"
gsutil mb -l $REGION gs://$BUCKET

SERVICE_ACCOUNT=eventarc-workflows
echo "Create service account for Eventarc triggers to use to invoke Workflows: $SERVICE_ACCOUNT"
gcloud iam service-accounts create $SERVICE_ACCOUNT \
  --display-name="Eventarc Workflows service account"

echo "Grant workflows.invoker role to service account: $SERVICE_ACCOUNT"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/workflows.invoker