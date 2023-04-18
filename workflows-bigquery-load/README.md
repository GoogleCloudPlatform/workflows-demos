# Load data from Cloud Storage to BigQuery using Workflows

This guide explains how to orchestrate a serverless scheduled data load from [Cloud Storage](https://cloud.google.com/storage) and transform the data in [BigQuery](https://cloud.google.com/bigquery) using [Workflows](https://cloud.google.com/workflows), [Cloud Functions](https://cloud.google.com/functions), and [Firestore](https://cloud.google.com/firestore).

For detailed steps, refer to the tutorial: [Load data from Cloud Storage to BigQuery using Workflows](https://cloud.google.com/workflows/docs/tutorials/load-data-from-cloud-storage-to-bigquery-using-workflows).

Contents of this repository:

* `main.tf`: Terraform template to set up the demo.
* `file_change_handler`: Cloud Function trigger (Python 3.7) to handle [`object finalized`](https://cloud.google.com/functions/docs/calling/storage#object_finalize) events from Cloud Storage.
* `workflow_handlers`: Cloud Functions to handle BigQuery jobs and the workflow YAML.
* `generator`: Script (Python 3.7) to generate AVRO files and upload to a Cloud Storage bucket.
