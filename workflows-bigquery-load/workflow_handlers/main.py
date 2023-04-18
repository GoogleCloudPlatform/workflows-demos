# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""This module contains various Cloud Functions to execute BigQuery jobs.

These functions are triggered by Google Cloud Workflows
"""

import uuid
import base64
import json
import time
import enum
import sys
import logging
import os

from google.cloud import firestore
from google.cloud import bigquery
from google.cloud import firestore

project_id = os.environ["GCP_PROJECT"]
headers = {"Content-Type": "application/json"}


class JobState(enum.Enum):
  # Defines states of a jobs
  CREATED = 0
  RUNNING = 1
  SUCCESS = 2
  FAILURE = 3


class JobType(enum.Enum):
  # Defines types of jobs
  LOAD_JOB = 0
  QUERY_JOB = 1


@firestore.transactional
def get_load_job(transaction, ref):
  """
    Get attributes of a job from Firestore

    :params transaction: Firestore transaction
    :type transaction: google.cloud.firestore_v1.transaction.Transaction
    :params ref: Job object reference
    :type ref: google.cloud.firestore_v1.document.DocumentReference
    """
  snapshot = ref.get(transaction=transaction)
  status = snapshot.get("status")
  if status != JobState.CREATED.value:
    logging.info("Job is already being processed: %s", ref.id)
    return None
  status = JobState.RUNNING

  try:
    logging.debug("Starting job %s", ref.id)
    transaction.update(ref, {"status": status.value})
    table_name = snapshot.get("table_name")

    return (
        snapshot.get("files"),
        snapshot.get("table_name"),
        snapshot.get("region"),
    )
  except Exception as e:
    logging.error(
        "Unable to start job %s :: %d :: %d",
        ref.id,
        snapshot.get("status"),
        ref.get(["status"]).get("status"),
        exc_info=True,
    )
    return None


@firestore.transactional
def change_job_status(transaction, ref, state):
  """
    Update the state of the job

    :params transaction: Firestore transaction
    :type transaction: google.cloud.firestore_v1.transaction.Transaction
    :params ref: Job object reference
    :type ref: google.cloud.firestore_v1.document.DocumentReference
    :params state: Job state
    :type state: JobState
    """
  try:
    val = state.value
    snapshot = ref.get(transaction=transaction)
    if snapshot.get("status") != val:
      transaction.update(ref, {"status": val})
  except Exception as e:
    logging.error(
        "Unable to update job status: %s :: %d",
        ref.id,
        state.value,
        exc_info=True)
    raise e


def load_job(s_job_id):
  """
    Create a new BigQuery load job for Avro files and start it asynchronously

    :params s_job_id: Job ID
    :type s_job_id: str
    """
  try:
    db = firestore.Client(project=project_id)
    doc = db.collection("jobs").document(s_job_id)

    transaction = db.transaction()
    files, table_name, region = get_load_job(transaction, doc)

    if files is None or len(files) < 1:
      logging.info("No files in job. Skipping job: %s", s_job_id)
      change_job_status(transaction, doc, JobState.SUCCESS)
      return None

    job_id = bigquery.job._JobReference(s_job_id, project_id, region)
    table_ref = bigquery.TableReference.from_string(table_name)
    config = bigquery.job.LoadJobConfig(
        create_disposition=bigquery.job.CreateDisposition.CREATE_IF_NEEDED,
        write_disposition=bigquery.job.WriteDisposition.WRITE_TRUNCATE,
        source_format="AVRO",
        use_avro_logical_types=True,
    )
    client = bigquery.Client(project=project_id)
    job = bigquery.job.LoadJob(job_id, files, table_ref, client, config)
    job._begin()
    change_job_status(transaction, doc, JobState.RUNNING)
    return s_job_id
  except Exception as e:
    change_job_status(transaction, doc, JobState.FAILURE)
    logging.error("Error starting load job %s", s_job_id, exc_info=True)
    raise e


def start_query_job(s_job_id):
  """
    Create a new BigQuery query job and start it asynchronously

    :params s_job_id: Job ID
    :type s_job_id: str
    """
  client = bigquery.Client(project=project_id)

  try:
    db = firestore.Client(project=project_id)

    doc = db.collection("jobs").document(s_job_id)
    transaction = db.transaction()
    job_attribs = doc.get(["qs", "region"])
    region = job_attribs.get("region")
    s_query = job_attribs.get("qs")

    job_id = bigquery.job._JobReference(s_job_id, project_id, region)
    job = bigquery.job.QueryJob(job_id, s_query, client)
    job._begin()
    change_job_status(transaction, doc, JobState.RUNNING)
    return s_job_id
  except Exception as e:
    logging.error("Unable to start query job %s", s_job_id, exc_info=True)
    raise e


def get_bigquery_job_status(s_job_id):
  """
    Poke BigQuery API to check the current status of a running job

    :params s_job_id: Job ID
    :type s_job_id: str
    """
  db = firestore.Client(project=project_id)

  doc = db.collection("jobs").document(s_job_id)
  job_fields = doc.get(["job_type", "region"])
  region = job_fields.get("region")
  job_type = JobType(int(job_fields.get("job_type")))

  client = bigquery.Client(project=project_id)
  job_id = bigquery.job._JobReference(s_job_id, project_id, region)
  job = None

  if job_type == JobType.QUERY_JOB:
    job = bigquery.job.QueryJob(job_id, "", client)
  elif job_type == JobType.LOAD_JOB:
    job = bigquery.job.LoadJob(job_id, None, None, client)
  state = JobState.RUNNING

  if not job.running():
    db = firestore.Client(project=project_id)
    doc = db.collection("jobs").document(s_job_id)

    if job.error_result != None:
      logging.info("Job failed: %s", s_job_id)
      state = JobState.FAILURE
    else:
      logging.info("Job completed: %s", s_job_id)
      if job_type == JobType.QUERY_JOB:
        try:
          rows = job.result()
          for row in rows:
            print(row)
        except:
          print("Error reading rows")
      state = JobState.SUCCESS

    transaction = db.transaction()
    change_job_status(transaction, doc, state)
  else:
    logging.debug(json.dumps(job))

  return state


##### HTTP Functions ####


def create_job(request):
  """
    Create a new job and associate files to import with it

    :params table_name: Load job destination table name
    :type table_name: str
    :params region: Load job BigQuery region
    :type region: str
    """

  job_id = str(uuid.uuid4())
  table_name = request.args.get("table_name")
  region = request.args.get("region")

  db = firestore.Client(project=project_id)
  files = db.collection("jobs").document("new").get(["files"
                                                    ]).to_dict()["files"]

  if files is not None and len(files) > 0:
    db.collection("jobs").document(job_id).set(
        {
            "table_name": table_name,
            "region": region,
            "job_type": JobType.LOAD_JOB.value,
            "files": firestore.ArrayUnion(files),
            "status": JobState.CREATED.value,
        },
        merge=True,
    )
    db.collection("jobs").document("new").update(
        {"files": firestore.ArrayRemove(files)})
  else:
    logging.info("No files to import")
    job_id = None

  return (json.dumps({"job_id": job_id}), 200, headers)


def create_query(request):
  """
    Create a new job to run a query

    :params qs: Query string
    :type qs: str
    :params region: Load job BigQuery region
    :type region: str
    """

  job_id = str(uuid.uuid4())
  qs = request.args.get("qs")
  region = request.args.get("region")

  db = firestore.Client(project=project_id)
  db.collection("jobs").document(job_id).set({
      "qs": qs,
      "region": region,
      "job_type": JobType.QUERY_JOB.value,
      "status": JobState.CREATED.value,
  })
  logging.debug("Created query job: %s", job_id)
  return (json.dumps({"job_id": job_id}), 200, headers)


def run_bigquery_job(request):
  """
    Start a BigQuery job and return the job id

    :params job_id: Job ID
    :type job_id: str
    """
  job_id = request.args.get("job_id")

  db = firestore.Client(project=project_id)
  doc = db.collection("jobs").document(job_id)
  job_fields = doc.get(["job_type"])
  job_type = JobType(int(job_fields.get("job_type")))

  if job_type == JobType.LOAD_JOB:
    # Start load job
    try:
      job_id = load_job(job_id)
      if job_id is not None:
        return (
            json.dumps({
                "job_id": job_id,
                "status": JobState.RUNNING.value
            }),
            200,
            headers,
        )
    except Exception as e:
      print("Error starting load job")
      print(e)
  elif job_type == JobType.QUERY_JOB:
    # Start query job
    try:
      job_id = start_query_job(job_id)
      if job_id is not None:
        return (
            json.dumps({
                "job_id": job_id,
                "status": JobState.RUNNING.value
            }),
            200,
            headers,
        )
    except Exception as e:
      print("Error starting query job")
      print(e)

  # Fail
  transaction = db.transaction()
  change_job_status(transaction, doc, JobState.FAILURE)
  return (
      json.dumps({
          "job_id": job_id,
          "status": JobState.FAILURE.value
      }),
      200,
      headers,
  )


def poll_bigquery_job(request):
  """
    Get current status of a job

    :params job_id: Job ID
    :type job_id: str
    """
  job_id = request.args.get("job_id")
  try:
    status = get_bigquery_job_status(job_id)
    if status is not None:
      return (
          json.dumps({
              "job_id": job_id,
              "status": status.value
          }),
          200,
          headers,
      )
  except Exception as e:
    logging.error("Error polling job %s", job_id, exc_info=True)
    print(e)

  return (json.dumps({"job_id": job_id, "status": 1}), 200, headers)
