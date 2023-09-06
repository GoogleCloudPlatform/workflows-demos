#!/bin/bash

# Copyright 2023 Google LLC
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

export PROJECT_ID=$(gcloud config get project)
export REGION=${REGION:=us-central1} # default us-central1 region if not defined

echo "Enable required services"
gcloud services enable \
  workflows.googleapis.com

WORKFLOW_NAME=message-payload-workflow
echo "Deploy workflow: $WORKFLOW_NAME"
gcloud workflows deploy $WORKFLOW_NAME \
  --source=workflow.yaml \
  --location=$REGION
