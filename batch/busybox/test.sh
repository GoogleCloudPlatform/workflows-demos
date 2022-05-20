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

#alias gcurl='curl --header "Content-Type: application/json" --header "Authorization: Bearer $(gcloud auth print-access-token)"'

BATCH_API=batch.googleapis.com/v1alpha1
REGION=us-central1

JOB_ID=job-busybox-$RANDOM
echo "Create and run a job: $JOB_ID"
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --data @job.json https://$BATCH_API/projects/$PROJECT_ID/locations/$REGION/jobs?job_id=$JOB_ID