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

echo "Enable required services"
gcloud services enable \
  cloudbuild.googleapis.com \
  iam.googleapis.com \
  workflows.googleapis.com

echo "Grant the cloudbuild.builds.editor role to the default compute service account"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role=roles/cloudbuild.builds.editor

WORKFLOW_NAME=workflow-gcloud
echo "Deploy the workflow: $WORKFLOW_NAME"
gcloud workflows deploy $WORKFLOW_NAME \
    --source=$WORKFLOW_NAME.yaml

WORKFLOW_NAME=workflow-kubectl
echo "Deploy the workflow: $WORKFLOW_NAME"
gcloud workflows deploy $WORKFLOW_NAME \
    --source=$WORKFLOW_NAME.yaml