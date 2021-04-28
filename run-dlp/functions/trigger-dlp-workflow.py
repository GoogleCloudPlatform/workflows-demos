from googleapiclient.discovery import build
import json
import sys

from google.oauth2 import service_account
import googleapiclient.discovery

workflow_service = build('workflowexecutions', 'v1')


def trigger_gcs_dlp(event, context):
    request_json = request.get_json()
    parent = request_json['parent']
    body = {"argument": json.dumps(event)}
    
    workflow = workflow_service.projects().locations().workflows().executions().create(
        parent=parent, body=body).execute()

    return workflow
