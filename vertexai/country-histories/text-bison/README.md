# Call VertexAI PaLM 2 for Text (text-bison) from Workflows in parallel

In this sample, you'll see how to call Vertex AI's PaLM 2 for Text (text-bison)
model in parallel from Workflows. More specifically, you'll gather histories of
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

## Gather and display histories of countries

See [workflow.yaml](./workflow.yaml). This workflow gathers histories of
a list of countries in parallel and return the combined histories in a map.

Deploy:

```sh
gcloud workflows deploy countries --source=countries.yaml
```

Run:

```sh
gcloud workflows run countries --data='{"countries":["Argentina", "Brazil", "Cyprus", "Denmark", "England","Finland", "Greece", "Honduras", "Italy", "Japan", "Korea","Latvia", "Morocco", "Nepal", "Oman"]}'
```

You should see an output similar to the following:

![execution output](./execution-output.png)