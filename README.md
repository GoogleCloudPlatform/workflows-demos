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

* [Create, start, stop VM using Compute Connector](connector-compute)
* [Data Loss Prevention workflow](gcs-dlp)
* [Service chaining](service-chaining)
* Eventarc and Workflows Integration
  * [Eventarc AuditLog-Cloud Storage and Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/blob/main/eventarc-workflows-integration/eventarc-auditlog-storage)
  * [Eventarc Pub/Sub and Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/blob/main/eventarc-workflows-integration/eventarc-pubsub)
  * [Workflows and Eventarc Pub/Sub](workflows-eventarc-integration/workflows-pubsub)
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

-------

This is not an official Google product.
