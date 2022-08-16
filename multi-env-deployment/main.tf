/**
 * Copyright 2022 Google LLC
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

variable "project_id" {
  type = string
}

variable "url1" {
  type = string
}

variable "url2" {
  type = string
}

locals {
  env = ["staging", "prod"]
}

# Define and deploy staging and prod workflows
resource "google_workflows_workflow" "multi-env3-workflows" {
  for_each = toset(local.env)

  name            = "multi-env3-${each.key}"
  project         = var.project_id
  region          = "us-central1"
  source_contents = templatefile("${path.module}/workflow3.yaml", { url1 : "${var.url1}-${each.key}", url2 : "${var.url2}-${each.key}" })
}
