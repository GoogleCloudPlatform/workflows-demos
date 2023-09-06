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
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=${REGION:=us-central1} # default us-central1 region if not defined

echo "Enable required services"
gcloud services enable \
  eventarc.googleapis.com \
  pubsub.googleapis.com

TOPIC_NAME=message-payload-topic
echo "Create a Pub/Sub topic: $TOPIC_NAME"
gcloud pubsub topics create ${TOPIC_NAME}

WORKFLOW_NAME=message-payload-workflow
echo "Create an Eventarc trigger to listen for events from Pub/Sub topic ${TOPIC_NAME} and route to $WORKFLOW_NAME"
TRIGGER_NAME=message-payload-trigger
gcloud eventarc triggers create $TRIGGER_NAME \
  --location=$REGION \
  --destination-workflow=$WORKFLOW_NAME \
  --destination-workflow-location=$REGION \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --transport-topic=projects/$PROJECT_ID/topics/$TOPIC_NAME