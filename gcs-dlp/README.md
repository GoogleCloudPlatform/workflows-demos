# Data Loss Prevention workflow
Responds to Google Cloud Storage(GCS) file upload and runs a Data Loss Prevention(DLP) job on the uploaded file. Reports to Pub/Sub if DLP was found. See detailed flow [here](flow.png).

## Main Steps
1. The workflow is triggered once a new object is uploaded to a GCS bucket.
2. The workflow creates and runs a DLP job to inspect the uploaded object.
3. The workflow periodically checks the status of the DLP job until the job is complete.
4. Once the DLP job completes, The workflow inspects the job results.
5. If the DLP job found any DLP issues, the workflow will post a message to Pub/Sub with the Job ID.

## Prerequisites
1. GCP project.
2. Service account with Cloud Functions Invoker, Pub/Sub Admin, and Workflows Admin permissions.
3. Pub/Sub topic (workflows-demo) and subscription.

## Usage
1. Deploy all functions in the 'functions' folder. Use the service account created in the Prerequisites section. 
2. Configure 'trigger-dlp-workflow' function to be triggered by a file upload to GCS.
3. Modify 'trigger-dlp-workflow.py' function by adjusting the 'parent' value to point to the workflow deployed in step #1 above. 
4. Modify 'dlp-gcs-file.yaml' by replacing the values in the 'initVariables' step to match your environment and by replacing the URLs to the functions.
5. Deploy dlp-gcs-workflow workflow using the dlp-gcs-workflow.yaml file. Use the service account created in the Prerequisites section.