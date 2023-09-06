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

JOB_NAME=message-payload-job
NUM_TASKS=1

IMAGE_NAME=gcr.io/${PROJECT_ID}/${JOB_NAME}

INPUT_BUCKET=message-payload-${PROJECT_ID}

echo "Configure gcloud to use $REGION for Cloud Run"
gcloud config set run/region ${REGION}

echo "Enabling required services"
gcloud services enable \
    run.googleapis.com \
    cloudbuild.googleapis.com

echo "Build sample into a container"
gcloud builds submit --pack image=$IMAGE_NAME

echo "Creating input bucket $INPUT_BUCKET"
gsutil mb gs://${INPUT_BUCKET}

# Delete job if it already exists.
gcloud run jobs delete ${JOB_NAME} --quiet

echo "Creating ${JOB_NAME} using $IMAGE_NAME, ${NUM_TASKS} tasks, bucket $INPUT_BUCKET"
gcloud run jobs create ${JOB_NAME} \
    --image $IMAGE_NAME \
    --command python \
    --args process.py \
    --tasks $NUM_TASKS \
    --set-env-vars=INPUT_BUCKET=$INPUT_BUCKET
