from __future__ import print_function
from googleapiclient.discovery import build
import json
import sys

from google.oauth2 import service_account
import googleapiclient.discovery

import argparse
import os

dlp = build('dlp', 'v2')


def inspect_gcs_file(request):

    request_json = request.get_json()
    project = request_json['project']
    bucket = request_json['bucket']
    filename = request_json['filename']
    info_types = [{"name": "PERSON_NAME"}, {"name": "ORGANIZATION_NAME"}, {"name": "LAST_NAME"}, {"name": "URL"}, {"name": "CREDIT_CARD_NUMBER"}, {"name": "DOMAIN_NAME"}, {
        "name": "EMAIL_ADDRESS"}, {"name": "ETHNIC_GROUP"}, {"name": "FIRST_NAME"}, {"name": "LAST_NAME"}, {"name": "GCP_CREDENTIALS"}, {"name": "PHONE_NUMBER"}]
    min_likelihood = 'LIKELIHOOD_UNSPECIFIED'
    max_findings = None
    max_findings = None

    if not info_types:
        info_types = ["FIRST_NAME", "LAST_NAME", "EMAIL_ADDRESS"]

    inspect_config = {
        "info_types": info_types,
        "min_likelihood": min_likelihood,
        "limits": {"max_findings_per_request": max_findings},
    }

    # Construct a storage_config containing the file's URL.
    url = "gs://{}/{}".format(bucket, filename)
    storage_config = {"cloud_storage_options": {"file_set": {"url": url}}}

    # Convert the project id into full resource ids.
    parent = f"projects/{project}"

    # Construct the inspect_job, which defines the entire inspect content task.
    inspect_job = {
        "inspectConfig": inspect_config,
        "storageConfig": storage_config
        # "actions": actions,
    }

    body = {"inspectJob": inspect_job}

    operation = dlp.projects().dlpJobs().create(
        parent=parent, body=body).execute()

    # print("Inspection operation started: {}".format(operation.get("name")))

    return operation
