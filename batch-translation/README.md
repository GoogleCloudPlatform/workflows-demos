# Batch Translation using Cloud Translation API connector

In this sample, you will see how to use [Cloud Translation API
connector](https://cloud.google.com/workflows/docs/reference/googleapis/translate/Overview)
to batch translate a number of text files in an input bucket into multiple
languages and save to an output bucket.

## Enable services

First, enable required services:

```sh
gcloud services enable \
  workflows.googleapis.com \
  translate.googleapis.com
```

## Create input bucket and files to translate

Create a Cloud Storage bucket that will hold the files to translate:

```sh
export BUCKET_INPUT=${GOOGLE_CLOUD_PROJECT}-input-files
gcloud storage buckets create gs://${BUCKET_INPUT}
```

Create two files in English to translate (or you can use your own files) and
upload to the input bucket:

```sh
echo "Dr. Watson, come here" > file1.txt
gcloud storage cp file1.txt gs://${BUCKET_INPUT}
echo "Hello World" > file2.txt
gcloud storage cp file2.txt gs://${BUCKET_INPUT}
```

## Define workflow

Create a `workflow.yaml` to define the workflow.

In the init step, assign some variables:

```yaml
main:
  steps:
  - init:
      assign:
      - projectId: ${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
      - location: ${sys.get_env("GOOGLE_CLOUD_LOCATION")}
      - inputBucketName: ${projectId + "-input-files"}
      - outputBucketName: ${projectId + "-output-files-" + string(int(sys.now()))}
```

In the second step, create a unique output bucket for translated texts:

```yaml
  - createOutputBucket:
        call: googleapis.storage.v1.buckets.insert
        args:
          query:
            project: ${projectId}
          body:
            name: ${outputBucketName}
```

Last step is to kick off the batch translation from the files in the input
bucket and save the results to the newly created output bucket. We are
translating English to Spanish and French using the Translation API connector:

```yaml
  - batchTranslateText:
      call: googleapis.translate.v3beta1.projects.locations.batchTranslateText
      args:
          parent: ${"projects/" + projectId + "/locations/" + location}
          body:
              inputConfigs:
                gcsSource:
                  inputUri: ${"gs://" + inputBucketName + "/*"}
              outputConfig:
                  gcsDestination:
                    outputUriPrefix: ${"gs://" + outputBucketName + "/"}
              sourceLanguageCode: "en"
              targetLanguageCodes: ["es", "fr"]
      result: batchTranslateTextResult
```

You can see the full [workflow.yaml](workflow.yaml).

## Deploy and execute workflow

Deploy workflow:

```sh
gcloud workflows deploy batch-translation \
    --source=workflow.yaml
```

Execute workflow:

```sh
gcloud workflows execute batch-translation
```

After a couple of minutes, you should see a new output bucket with translated
files!
