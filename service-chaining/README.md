# Service chaining

In this sample, you will orchestrate multiple Cloud Functions, Cloud Run and
external services in a workflow.

## Cloud Function - Random number

Inside [randomgen](randomgen) folder, deploy a function that generates a random number:

```sh
gcloud functions deploy randomgen \
    --gen2 \
    --runtime python39 \
    --trigger-http \
    --entry-point randomgen \
    --source . \
    --allow-unauthenticated
```

Test:

```sh
curl https://us-central1-workflows-atamel.cloudfunctions.net/randomgen
```

## Cloud Function - Multiply

Inside [multiply](multiply) folder, deploy a function that multiplies a given number:

```sh
gcloud functions deploy multiply \
    --gen2 \
    --runtime python39 \
    --trigger-http \
    --entry-point multiply \
    --source . \
    --allow-unauthenticated
```

Test:

```sh
curl -X POST https://us-central1-workflows-atamel.cloudfunctions.net/multiply \
    -H "content-type: application/json" \
    -d '{"input":5}'
```

## External Function - MathJS

For an external function, use [MathJS](https://api.mathjs.org/).

Test:

```sh
curl https://api.mathjs.org/v4/?expr=log(56)
```

## Cloud Run - Floor

Inside [floor](floor) folder, deploy an authenticated Cloud Run service that floors a number.

Build the container:

```sh
export SERVICE_NAME=floor
gcloud builds submit --tag gcr.io/${PROJECT_ID}/${SERVICE_NAME}
```

Deploy:

```sh
gcloud run deploy ${SERVICE_NAME} \
  --image gcr.io/${PROJECT_ID}/${${SERVICE_NAME}} \
  --platform managed \
  --no-allow-unauthenticated
```

Test:

```sh
curl -X POST https://floor-wvdg6hhtla-ew.a.run.app \
    -H "content-type: application/json" \
    -d '{"input": "6.86"}'
```

## Service account for Workflows

Create a service account for Workflows:

```sh
export SERVICE_ACCOUNT=workflows-sa
gcloud iam service-accounts create ${SERVICE_ACCOUNT}
```

Grant `run.invoker` role to the service account:

```sh
export PROJECT_ID=$(gcloud config get-value project)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role "roles/run.invoker"
```

## Workflow

Deploy workflow:

```sh
gcloud workflows deploy workflow \
    --source=workflow.yaml \
    --service-account=${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com
```

Execute workflow:

```sh
gcloud workflows execute workflow
```

-------

This is not an official Google product.
