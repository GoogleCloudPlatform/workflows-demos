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
