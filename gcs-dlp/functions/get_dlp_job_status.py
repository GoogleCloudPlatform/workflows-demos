# Copyright 2021 Google LLC
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

# Sample input: '{"createTime":"2021-02-12T09:03:18.603Z","inspectDetails":{"requestedOptions":{"jobConfig":{"inspectConfig":{"infoTypes":[{"name":"PERSON_NAME"},{"name":"ORGANIZATION_NAME"},{"name":"LAST_NAME"},{"name":"URL"},{"name":"CREDIT_CARD_NUMBER"},{"name":"DOMAIN_NAME"},{"name":"EMAIL_ADDRESS"},{"name":"ETHNIC_GROUP"},{"name":"FIRST_NAME"},{"name":"LAST_NAME"},{"name":"GCP_CREDENTIALS"},{"name":"PHONE_NUMBER"}],"limits":{},"minLikelihood":"POSSIBLE"},"storageConfig":{"cloudStorageOptions":{"fileSet":{"url":"gs://uri-test-dlp/keep.txt"}}}},"snapshotInspectTemplate":{}},"result":{}},"name":"projects/uri-test/dlpJobs/i-5391960528861101614","state":"PENDING","type":"INSPECT_JOB"}'
from __future__ import print_function
from googleapiclient.discovery import build
import json
import sys

from google.oauth2 import service_account
import googleapiclient.discovery


import argparse
import os


dlp = build('dlp', 'v2')


def get_dlp_job_status(request):
    request_json = request.get_json()
    JobName = request_json['name']

    operation = dlp.projects().dlpJobs().get(
        name=JobName).execute()

    # print("Inspection operation started: {}".format(operation.get("state")))

    return operation
