# Call VertexAI Gemini Pro Vision from Workflows to describe an image

In this sample, you'll see how to call Vertex AI's Gemini Pro Vision
from Workflows. More specifically, you'll use Gemini Pro Vision to describe an
image in a Cloud Storage bucket.

![scones](./scones.jpg)

## Before you start

Make sure you have the right IAM permissions for the default compute service
account that Workflows will use:

```sh
PROJECT_ID=genai-atamel
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format "value(projectNumber)")

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role roles/aiplatform.user
```

## Workflow

See [describe-image.yaml](./describe-image.yaml) or
[describe-image-connector.yaml](./describe-image-connector.yaml) for details.

Deploy:

```sh
gcloud workflows deploy describe-image --source=describe-image.yaml
gcloud workflows deploy describe-image-connector --source=describe-image-connector.yaml
```

Run:

```sh
gcloud workflows run describe-image  --data='{"image_url":"gs://generativeai-downloads/images/scones.jpg"}'
gcloud workflows run describe-image-connector  --data='{"image_url":"gs://generativeai-downloads/images/scones.jpg"}'
```

You should see an output similar to the following:

```log
{
  "image_description": "The picture shows a table with a white tablecloth. On the table are two cups of coffee, a bowl of blueberries, and five scones. The scones are round and have blueberries on top. There are also some pink flowers on the table. The background is a dark blue color.",
  "image_url": "gs://generativeai-downloads/images/scones.jpg"
}
```
