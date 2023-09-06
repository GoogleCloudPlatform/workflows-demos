#!/usr/bin/env python3

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

import base64
import json
import os

import google.auth
from google.cloud import storage

storage_client = storage.Client()

_, PROJECT_ID = google.auth.default()

INPUT_BUCKET = os.environ.get("INPUT_BUCKET", f"message-payload-{PROJECT_ID}")
INPUT_FILE = os.environ.get("INPUT_FILE")
if INPUT_FILE is None:
    raise ValueError(f"Environment variable 'INPUT_FILE' is not defined.")

# Process a Cloud Storage object.
def process():

    print(f"Processing message payload gs://{INPUT_BUCKET}/{INPUT_FILE}")

    # Download the Cloud Storage object
    bucket = storage_client.bucket(INPUT_BUCKET)
    blob = bucket.blob(INPUT_FILE)

    # Load the message payload
    content = blob.download_as_string().decode("utf-8")
    payload = json.loads(content)
    print(f"Payload: {payload}")


if __name__ == "__main__":
    process()
