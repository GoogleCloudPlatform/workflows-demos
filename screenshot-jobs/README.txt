1. User uploads a txt file with a list of urls to Cloud Storage
2. This triggers an event via Eventarc to Workflows
3. Workflows picks the event, reads the urls from the file
4. Workflows creates a new job with the urls and number of tasks
5. Workflows runs and waits for the job to complete
6. Workflows deletes the txt file and the job


BUCKET=screenshot-jobs-$PROJECT_ID
gsutil mb gs://$BUCKET


WORKFLOW_NAME=screenshot-jobs-workflow
gcloud workflows deploy $WORKFLOW_NAME --source=workflow.yaml

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --role roles/workflows.invoker \
  --member serviceAccount:screenshot-sa@$PROJECT_ID.iam.gserviceaccount.com

gcloud eventarc triggers create screenshot-jobs-trigger \
  --location=us \
  --destination-workflow=$WORKFLOW_NAME \
  --destination-workflow-location=us-central1 \
  --event-filters="type=google.cloud.storage.object.v1.finalized" \
  --event-filters="bucket=$BUCKET" \
  --service-account=screenshot-sa@$PROJECT_ID.iam.gserviceaccount.com

gsutil cp job1.txt gs://$BUCKET