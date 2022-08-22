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

echo "Create an Eventarc trigger to listen for events from a Pub/Sub topic and route to $WORKFLOW_NAME workflow"
TRIGGER_NAME=$WORKFLOW_NAME-pubsub
gcloud eventarc triggers create $TRIGGER_NAME \
  --location=$REGION \
  --destination-workflow=$WORKFLOW_NAME \
  --destination-workflow-location=$REGION \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com

echo "Get the id of the underlying topic"
TOPIC=$(basename $(gcloud eventarc triggers describe $TRIGGER_NAME --format='value(transport.pubsub.topic)' --location=$REGION))

echo "Publish a message to the topic: $TOPIC"
gcloud pubsub topics publish $TOPIC --message="Hello World"