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

* [Service chaining](service-chaining)
* [Connector - Compute](connector-compute)
* Eventarc and Workflows Integration
  * [Eventarc AuditLog-Cloud Storage and Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/blob/main/eventarc-workflows-integration/eventarc-auditlog-storage)
  * [Eventarc Pub/Sub and Workflows](https://github.com/GoogleCloudPlatform/eventarc-samples/blob/main/eventarc-workflows-integration/eventarc-pubsub)
* Terraform samples
  * [Basic Terraform](terraform/basic)
  * [Terraform with imported YAML](terraform/import-yaml)
  * [Terraform with multiple imported YAMLs](terraform/import-multiple-yamls)
* [Run a DLP job when a file is uploaded to GCS](gcs-dlp)
-------

This is not an official Google product.
