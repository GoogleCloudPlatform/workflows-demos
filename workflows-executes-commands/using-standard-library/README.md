# Workflows executes commands (gcloud, kubectl) - using standard library

> **Note:** This sample uses the standard library for gcloud and kubectl which
> is currently in private preview that only allow-listed projects can access.

This example shows how to execute commands (such as gcluod, kubectl) from
Workflows via Cloud Build using the standard library.

## Create a workflow for gcloud

Take a look at [workflow-gcloud.yaml](workflow-gcloud.yaml) that executes a
given `gcloud` command in Cloud Build and returns the output of the execution.

## Create a workflow for kubectl

Take a look at [workflow-kubectl.yaml](workflow-kubectl.yaml) that executes a
given `kubectl` command in Cloud Build and returns the output of the execution.

## Deploy the workflows

Make sure you have a Google Cloud project and the project id is set in `gcloud`:

```sh
PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID
```

Run [setup.sh](setup.sh) to enable required services, assign necessary roles,
create a test GKE cluster to run `kubectl` commands against and deploy both workflows.

## Run the workflow for gcloud

Run the workflow from Google Cloud Console or `gcloud`:

```sh
gcloud workflows run workflow-gcloud
```

## Run the workflow for kubectl

Run the workflow from Google Cloud Console or `gcloud`:

```sh
gcloud workflows run workflow-kubectl
```
