# Call VertexAI Gemini Pro from Workflows in parallel

In this sample, you'll see how to call Vertex AI's Gemini Pro
in parallel from Workflows. More specifically, you'll gather histories of
a list of countries in parallel and return the combined histories in a map.

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

See [country-histories.yaml](./country-histories.yaml) or [country-histories-connector.yaml](./country-histories-connector.yaml) for details.

Deploy:

```sh
gcloud workflows deploy country-histories-gemini-pro --source=country-histories.yaml
gcloud workflows deploy country-histories-connector-gemini-pro --source=country-histories-connector.yaml
```

Run:

```sh
gcloud workflows run country-histories-gemini-pro --data='{"countries":["Argentina", "Brazil", "Cyprus", "Denmark", "England","Finland", "Greece", "Honduras", "Italy", "Japan", "Korea","Latvia", "Morocco", "Nepal", "Oman"]}'

gcloud workflows run country-histories-connector-gemini-pro --data='{"countries":["Argentina", "Brazil", "Cyprus", "Denmark", "England","Finland", "Greece", "Honduras", "Italy", "Japan", "Korea","Latvia", "Morocco", "Nepal", "Oman"]}'
```

You should see an output similar to the following:

![execution output](./execution-output.png)
