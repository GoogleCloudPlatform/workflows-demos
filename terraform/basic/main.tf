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

# [START workflows_api_enable]
resource "google_project_service" "workflows" {
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}
# [END workflows_api_enable]

# [START workflows_serviceaccount_create]
resource "google_service_account" "workflows_service_account" {
  account_id   = "sample-workflows-sa"
  display_name = "Sample Workflows Service Account"
}
# [END workflows_serviceaccount_create]

# [START workflows_workflow_deploy]
resource "google_workflows_workflow" "workflows_example" {
  name            = "sample-workflow"
  region          = "us-central1"
  description     = "A sample workflow"
  service_account = google_service_account.workflows_service_account.id
  source_contents = <<-EOF
  # This is a sample workflow, feel free to replace it with your source code
  #
  # This workflow does the following:
  # - reads current time and date information from an external API and stores
  #   the response in CurrentDateTime variable
  # - retrieves a list of Wikipedia articles related to the day of the week
  #   from CurrentDateTime
  # - returns the list of articles as an output of the workflow
  # FYI, In terraform you need to escape the $$ or it will cause errors.

  - getCurrentTime:
      call: http.get
      args:
          url: https://us-central1-workflowsample.cloudfunctions.net/datetime
      result: CurrentDateTime
  - readWikipedia:
      call: http.get
      args:
          url: https://en.wikipedia.org/w/api.php
          query:
              action: opensearch
              search: $${CurrentDateTime.body.dayOfTheWeek}
      result: WikiResult
  - returnOutput:
      return: $${WikiResult.body[1]}
EOF

  depends_on = [google_project_service.workflows]
}
# [END workflows_workflow_deploy]
