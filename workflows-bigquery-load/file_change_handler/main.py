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

from google.cloud import firestore
import os

project_id = os.environ["GCP_PROJECT"]


def handle_new_file(event, context):
  """
    Appends the name of the file added to the Cloud Storage bucket
    in the "files" array of the "new" document in Firestore.

    :params event: Event payload
    :type event: dict
    :params context: Event metadata
    :type context: google.cloud.functions.Context
    """
  file_path = "gs://%s/%s" % (event["bucket"], event["name"])
  db = firestore.Client(project=project_id)
  db.collection("jobs").document("new").set(
      {"files": firestore.ArrayUnion([file_path])}, merge=True)
  print("Added file: %s" % file_path)
