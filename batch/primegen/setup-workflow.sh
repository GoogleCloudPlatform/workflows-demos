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

echo "Get the project id"
PROJECT_ID=$(gcloud config get-value project)

echo "Enable necessary APIs"
gcloud services enable \
  artifactregistry.googleapis.com \
  batch.googleapis.com \
  cloudbuild.googleapis.com
  workflowexecutions.googleapis.com \
  workflows.googleapis.com

echo "Create a repository for containers"
REGION=us-central1
gcloud artifacts repositories create containers --repository-format=docker --location=$REGION

echo "Build the container"
gcloud builds submit -t $REGION-docker.pkg.dev/$PROJECT_ID/containers/primegen-service:v1 PrimeGenService/

SERVICE_ACCOUNT=workflows-batch-sa
echo "Create a service account: $SERVICE_ACCOUNT for Workflows"
gcloud iam service-accounts create $SERVICE_ACCOUNT

echo "Add necessary roles to the service account"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/batch.jobsAdmin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/logging.logWriter