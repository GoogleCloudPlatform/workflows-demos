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
"""This module generates Avro files with random data in the given schema.

These files are then exported to a given Cloud Storage bucket.
"""

import json
import random
import time
import argparse
import logging
import strgen
import avro
import os
from avro.datafile import DataFileWriter, DataFileReader
from avro.io import DatumWriter, DatumReader
from google.cloud import storage

logging.basicConfig(level=logging.DEBUG)

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--project", help="GCP Project", required=True)
parser.add_argument("-o", "--output", help="GCS bucket", required=True)
parser.add_argument("-x", "--prefix", help="Output file prefix", required=True)
parser.add_argument("-n", "--num", type=int, help="", required=True)
parser.add_argument("-f", "--files", type=int, help="", required=True)

# Schema of the BigQuery table
schema = {
    "name":
        "avro.example.Word",
    "type":
        "record",
    "fields": [
        {
            "name": "word",
            "type": "string"
        },
        {
            "name": "count",
            "type": "int"
        },
        {
            "name": "corpus",
            "type": "string"
        },
        {
            "name": "corpus_date",
            "type": "int"
        },
    ],
}
schema_parsed = avro.schema.Parse(json.dumps(schema))

args = parser.parse_args()

num_records = args.num
num_files = args.files

id_start = random.randint(1, 1000000)

# Generate files with random content
for file_index in range(0, num_files):
  file_name = "%s_%d.avro" % (args.prefix, file_index)
  with open(file_name, "wb") as f:
    writer = DataFileWriter(f, DatumWriter(), schema_parsed)
    for record_num in range(0, num_records):
      word = str(strgen.StringGenerator("[\d\w]{10}").render())
      corpus = str(strgen.StringGenerator("[\d\w]{10}").render())
      count = random.randint(0, 1000)
      corpus_date = random.randint(1000000, 1900000)
      writer.append({
          "word": word,
          "count": count,
          "corpus": corpus,
          "corpus_date": corpus_date,
      })
    writer.close()

# Copy to GCS and remove local files
storage_client = storage.Client(project=args.project)
bucket = storage_client.get_bucket(args.output)

for file_index in range(0, num_files):
  file_name = "%s_%d.avro" % (args.prefix, file_index)
  blob = bucket.blob(file_name)
  blob.upload_from_filename(file_name)
  os.remove(file_name)
