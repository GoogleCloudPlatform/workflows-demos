/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  project = var.project_id
}

# Enable Workflows API
resource "google_project_service" "workflows" {
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}

# Create a service account for Workflows
resource "google_service_account" "workflows_service_account" {
  account_id   = "workflows-service-account"
  display_name = "Workflows Service Account"
}

# Define and deploy a workflow
resource "google_workflows_workflow" "workflows_example" {
  name            = "sample-workflow"
  region          = var.region
  description     = "A sample workflow"
  service_account = google_service_account.workflows_service_account.id
  # Imported main workflow with its subworkflow YAML files.
  source_contents = join("", [
    templatefile(
      "${path.module}/workflow.yaml",{}
    ),

    templatefile(
      "${path.module}/subworkflow.yaml",{}
    )])

  depends_on = [google_project_service.workflows]
}