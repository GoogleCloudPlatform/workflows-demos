# Workflows Samples

![Workflows Logo](Workflows-128-color.png)

[Workflows](https://cloud.google.com/workflows) allow you to orchestrate and
automate Google Cloud and HTTP-based API services with serverless workflows.

This repository contains a collection of samples for Workflows for various use
cases.

## Slides

There's a
[presentation](https://speakerdeck.com/meteatamel/serverless-orchestration-with-workflows)
that explains Workflows.

<a href="https://speakerdeck.com/meteatamel/serverless-orchestration-with-workflows">
    <img alt="Workflows presentation" src="serverless-orchestration-with-workflows.png" width="50%" height="50%">
</a>

## Samples

* [Workflows syntax cheat sheet](syntax-cheat-sheet/workflow.yaml)
* [Create, start, stop VM using Compute Connector](connector-compute)
* [Data Loss Prevention workflow](gcs-dlp)
* [Service chaining](service-chaining)
* Eventarc and Workflows
  * [Eventarc (Cloud Storage) and Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/blob/main/eventarc-workflows-integration/eventarc-storage)
  * [Eventarc (AuditLog-Cloud Storage), Cloud Run and Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/blob/main/eventarc-workflows-integration/eventarc-auditlog-storage-cloudrun)
  * [Eventarc (Pub/Sub) and Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/blob/main/eventarc-workflows-integration/eventarc-pubsub)
  * [Eventarc (Pub/Sub), Cloud Run and Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/blob/main/eventarc-workflows-integration/eventarc-pubsub-cloudrun)
  * [Workflows and Eventarc (Pub/Sub)](workflows-eventarc-integration/workflows-pubsub)
  * [Image processing pipeline v2 - Eventarc (Cloud Storage) + Cloud Run + Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/tree/main/processing-pipelines/image-v2)
  * [Image processing pipeline v3 - Eventarc (Cloud Storage) + Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/tree/main/processing-pipelines/image-v3)
* Terraform samples
  * [Basic Terraform](terraform/basic)
  * [Terraform with imported YAML](terraform/import-yaml)
  * [Terraform with multiple imported YAMLs](terraform/import-multiple-yamls)
* Machine Learning and iteration samples
  * [Batch Translation using Translation API connector](batch-translation)
  * [Reddit sentiment analysis using Language API connector and iteration syntax](reddit-sentiment)
  * [Twitter sentiment analysis using Language API connector and iteration syntax](twitter-sentiment)
* Callback samples
  * [Basic callback endpoint sample](callback-basic)
  * [Human validation of text translation via Workflows callback](callback-translation)
  * [Manager approval of expense reports thanks to Workflows callbacks](https://github.com/GoogleCloudPlatform/smart-expenses)

-------

This is not an official Google product.
