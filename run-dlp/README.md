# run-dlp
Responds to GCS file upload and runs a DLP job on the uploaded file. Reports to PubSub if DLP was found

## Main Steps
1. See detailed flow in the images folder.
2. The workflow is triggered once a new object is uploaded to a GCS bucket.
3. The workflow creates and runs a DLP job to inspect the uploaded object.
4. The workflow periodically checks the status of the DLP job until the job is complete.
5. Once the DLP job completes, The workflow inspects the job results.
6. If the DLP job found any DLP issues, the workflow will post a message to PubSub with the Job ID.

## Prerequisites
1. GCP project.
2. Service account with Cloud Functions Invoker, Pub/Sub Admin, and Workflows Admin permissions.
3. PubSub topic and subscription.

## Usage
1. Deploy all functions in the 'functions' folder. Use the service account created in the Prerequisites section. 
2. Configure 'trigger-dlp-workflow' function to be triggered by a file upload to GCS.
3. Modify 'trigger-dlp-workflow.py' function by adjusting the 'parent' value to point to the workflow deployed in step #1 above. 
4. Modify 'dlp-gcs-file.yaml' by replacing the values in the 'initVariables' step to match your environment and by replacing the URLs to the functions.
5. Deploy dlp-gcs-file workflow using the dlp-gcs-file.yaml file. Use the service account created in the Prerequisites section.