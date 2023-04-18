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

// ---------Start Project specific variables---------

variable "region" {
  type = string
  default = "us-central1"
}

variable "zone" {
  type = string
  default = "us-central1-c"
}

variable "project_id" {
  type = string
}

provider "google" {
  region  = var.region
  zone    = var.zone
}
// ----------End Project specific variables----------


// ---------Start Create functions zip file----------
resource "null_resource" "mk-zip" {
 triggers = {
    file1 = "${sha1(file("workflow_handlers/main.py"))}"
    file2 = "${sha1(file("workflow_handlers/requirements.txt"))}"
    file3 = "${sha1(file("file_change_handler/main.py"))}"
    file4 = "${sha1(file("file_change_handler/requirements.txt"))}"
  }
  provisioner "local-exec" {
    command = "./build.sh"
    interpreter = ["bash"]
    working_dir = "${path.module}"
  }
}
// ----------End Create functions zip file-----------

// --------------Start Service Accounts--------------

// File change trigger
// Firebase write
resource "google_service_account" "gcf_fb_sa" {
  account_id   = "file-change-handler"
  display_name = "File change trigger"
  project = var.project_id
}

// Workflow execution
// GCF triggers
resource "google_service_account" "wf_sa" {
  account_id   = "workflow-runner"
  display_name = "Workflow excutor"
  project = var.project_id
}

// GCF runners
// BQ job runners
// GCS read
resource "google_service_account" "gcf_wf_sa" {
  account_id   = "function-runner"
  display_name = "Workflow execution functions"
  project = var.project_id
}

resource "google_storage_bucket" "demo_bucket" {
  name          = "${var.project_id}-ordersbucket"
  project       = var.project_id
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

// Firebase user role
resource google_project_iam_member "firestore_user" {
  role   = "roles/datastore.user"
  member = "serviceAccount:${google_service_account.gcf_fb_sa.email}"
  project = var.project_id
}

resource google_project_iam_member "firestore_user_2" {
  role   = "roles/datastore.user"
  member = "serviceAccount:${google_service_account.gcf_wf_sa.email}"
  project = var.project_id
}

// BigQuery user role
resource google_project_iam_member "bigquery_jobs_user" {
  role   = "roles/bigquery.user"
  member = "serviceAccount:${google_service_account.gcf_wf_sa.email}"
  project = var.project_id
}

resource "google_storage_bucket_iam_binding" "storage_user" {
  bucket = google_storage_bucket.demo_bucket.name
  role = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.gcf_wf_sa.email}"]
}

resource google_project_iam_member "workflow_user" {
  role   = "roles/workflows.editor"
  member = "serviceAccount:${google_service_account.wf_sa.email}"
  project = var.project_id
}

resource google_project_iam_member "bigquery_editor" {
  role   = "roles/bigquery.dataEditor"
  member = "serviceAccount:${google_service_account.gcf_wf_sa.email}"
  project = var.project_id
}
// ---------------End Service Accounts---------------

// ------------------Start BigQuery------------------

// Create dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "serverless_elt_dataset"
  friendly_name               = "Orders example"
  description                 = "This is a demo dataset"
  location                    = "US"
  project = var.project_id

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "word_count"
  project = var.project_id
  deletion_protection=false

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "word",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Word"
  },
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Occurances"
  },
  {
    "name": "corpus",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Corpus"
  },
  {
    "name": "corpus_date",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Date"
  }
]
EOF
}
// -------------------End BigQuery-------------------

// -------------------Start Storage------------------

// Set up cloud functions
// Trigger from GCS bucket

// Code bucket
resource "google_storage_bucket" "gcf-bucket" {
  name = "${var.project_id}-function-code"
  project = var.project_id
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "gcf-archive" {
  name = "file-handler.zip"
  bucket = google_storage_bucket.gcf-bucket.name
  source = "./build/file-handler.zip"
}

resource "google_storage_bucket_object" "gcf-workflow-archive" {
  name = "workflow-functions.zip"
  bucket = google_storage_bucket.gcf-bucket.name
  source = "./build/workflow-functions.zip"
}

resource "google_cloudfunctions_function" "change_handler" {
  name = "file_add_handler"
  description = "Add file name to Firestore new collection"
  project = var.project_id
  runtime = "python37"
  available_memory_mb   = 128
  timeout = 540
  source_archive_bucket = google_storage_bucket.gcf-bucket.name
  source_archive_object = google_storage_bucket_object.gcf-archive.name
  service_account_email = google_service_account.gcf_fb_sa.email

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource = google_storage_bucket.demo_bucket.name
  }
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  entry_point = "handle_new_file"

}
// --------------------End Storage--------------------

// --------------Start Workflow handler---------------

// Create job
resource "google_cloudfunctions_function" "create-job" {
  name                  = "create_job"
  description           = "Create a new job and associate files to load"
  project               = var.project_id
  runtime               = "python37"
  available_memory_mb   = 128
  timeout               = 540
  source_archive_bucket = google_storage_bucket.gcf-bucket.name
  source_archive_object = google_storage_bucket_object.gcf-workflow-archive.name
  service_account_email = google_service_account.gcf_wf_sa.email
  trigger_http          = true
  entry_point           = "create_job"
}

// IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "create-runner" {
  project        = google_cloudfunctions_function.create-job.project
  region         = google_cloudfunctions_function.create-job.region
  cloud_function = google_cloudfunctions_function.create-job.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.wf_sa.email}"
}

// Create query
resource "google_cloudfunctions_function" "create-query" {
  name                  = "create_query"
  description           = "Create a new BigQuery query job"
  project               = var.project_id
  runtime               = "python37"
  available_memory_mb   = 128
  timeout               = 540
  source_archive_bucket = google_storage_bucket.gcf-bucket.name
  source_archive_object = google_storage_bucket_object.gcf-workflow-archive.name
  service_account_email = google_service_account.gcf_wf_sa.email
  trigger_http          = true
  entry_point           = "create_query"
}

// IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "query-creator" {
  project        = google_cloudfunctions_function.create-query.project
  region         = google_cloudfunctions_function.create-query.region
  cloud_function = google_cloudfunctions_function.create-query.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.wf_sa.email}"
}

// Poll BigQuery job
resource "google_cloudfunctions_function" "poll-bigquery-job" {
  name                  = "poll_bigquery_job"
  description           = "Poll the status of a BigQuery job"
  project               = var.project_id
  runtime               = "python37"
  available_memory_mb   = 128
  timeout = 540
  source_archive_bucket = google_storage_bucket.gcf-bucket.name
  source_archive_object = google_storage_bucket_object.gcf-workflow-archive.name
  service_account_email = google_service_account.gcf_wf_sa.email
  trigger_http          = true
  entry_point           = "poll_bigquery_job"
}

// IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "poll-runner" {
  project        = google_cloudfunctions_function.poll-bigquery-job.project
  region         = google_cloudfunctions_function.poll-bigquery-job.region
  cloud_function = google_cloudfunctions_function.poll-bigquery-job.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.wf_sa.email}"
}

// Create Query job
resource "google_cloudfunctions_function" "run-bigquery-job" {
  name                  = "run_bigquery_job"
  description           = "Start a BigQuery load/query job"
  project               = var.project_id
  runtime               = "python37"
  available_memory_mb   = 128
  timeout = 540
  source_archive_bucket = google_storage_bucket.gcf-bucket.name
  source_archive_object = google_storage_bucket_object.gcf-workflow-archive.name
  service_account_email = google_service_account.gcf_wf_sa.email
  trigger_http          = true
  entry_point           = "run_bigquery_job"
}

// IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "query-runner" {
  project        = google_cloudfunctions_function.run-bigquery-job.project
  region         = google_cloudfunctions_function.run-bigquery-job.region
  cloud_function = google_cloudfunctions_function.run-bigquery-job.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.wf_sa.email}"
}

// ---------------End Workflow handler----------------
