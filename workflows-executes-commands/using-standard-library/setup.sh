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

echo "Get the project id and number"
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

echo "Enable the required services"

# cloudbuild.googleapis.com to run commands with Cloud Build
# container.googleapis.com to run kubectl commands
# workflows.gooleapis.com to orchestrate with Workflows
gcloud services enable \
  cloudbuild.googleapis.com \
  container.googleapis.com \
  workflows.googleapis.com

echo "Grant the necessary roles to the default compute service account"

# Service Account User role to successfully trigger Cloud Build.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser

# Cloud Build Editor role to create builds.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role=roles/cloudbuild.builds.editor

# Logs Writer role to allow Cloud Build to store execution output and errors.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role=roles/logging.logWriter

# Logs Viewer role to view logs.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role=roles/logging.viewer

echo "Deploy a workflow to run gcloud commands"

WORKFLOW_NAME=workflow-gcloud
echo "Deploy the workflow: $WORKFLOW_NAME"
gcloud workflows deploy $WORKFLOW_NAME \
    --source=$WORKFLOW_NAME.yaml

echo "Create a GKE cluster to run kubectl commands against"
gcloud container clusters create-auto helloworld-gke --region us-central1

echo "Deploy a workflow to run kubectl commands"
WORKFLOW_NAME=workflow-kubectl
echo "Deploy the workflow: $WORKFLOW_NAME"
gcloud workflows deploy $WORKFLOW_NAME \
    --source=$WORKFLOW_NAME.yaml