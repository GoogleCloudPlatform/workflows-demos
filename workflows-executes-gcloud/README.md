# Workflows executes gcloud commands

This example shows how to execute gcloud commands from Workflows via Cloud
Build.

## Create a workflow

Create a [workflow.yaml](workflow.yaml):

```yaml
main:
  steps:
  - list_workflows:
      call: gcloud
      args:
          args: "workflows list"
      result: r
  - done:
      return: ${r}

gcloud:
  params: [args]
  steps:
  - gcloud:
      call: googleapis.cloudbuild.v1.projects.builds.create
      args:
          projectId: ${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
          parent: ${"projects/" + sys.get_env("GOOGLE_CLOUD_PROJECT_ID") + "/locations/global"}
          body:
              serviceAccount: ${sys.get_env("GOOGLE_CLOUD_SERVICE_ACCOUNT_NAME")}
              options:
                  logging: CLOUD_LOGGING_ONLY
              steps:
              - name: gcr.io/google.com/cloudsdktool/cloud-sdk
                entrypoint: /bin/bash
                # TODO: Should use $BUILDER_OUTPUT for "/builder/ouputs", but couldn't get substitution to work
                args: ${["-c", "gcloud " + args + " > /builder/outputs/output"]}
      result: r
  - return:
      return: ${text.decode(base64.decode(r.metadata.build.results.buildStepOutputs[0]))}
```

## Deploy the workflow

Make sure you have a Google Cloud project and the project id is set in `gcloud`:

```sh
PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID
```

Run [setup.sh](setup.sh) to enable required services, assign necessary roles and
deploy the workflow defined in [workflow.yaml](workflow.yaml).

## Run the workflow

You're now ready to test the end-to-end flow.

Run the workflow from Google Cloud Console or `gcloud`:

```sh
gcloud workflows run workflows-executes-gcloud
```
