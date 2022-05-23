# Batch + Workflows - simple container

> **Note:** Google Batch service is feature in *preview*.
> Only allow-listed projects can currently take advantage of it. Please fill the
> following [form](https://docs.google.com/forms/d/e/1FAIpQLSdfwO0N4oTu14bW3yxJBAak4KMn8qqeArs2NuNBXDrcjG-g5Q/viewform)
> to get your project allow-listed before attempting this sample.

In this sample, you'll see how to run a simple container as a job in Batch service. You
will then automate the lifecycle of the Batch job using Workflows.

The Google Batch service provides an end to end fully-managed batch service,
which allows you to schedule, queue, and execute jobs on Google compute
instances. The service provisions resources, manages capacity and allows batch
workloads to run at scale.

## Before you begin

Make sure your project id is set in gcloud:

```sh
gcloud config set project PROJECT_ID
```

## Simple container

In this sample, you will schedule a batch job to run a simple container.

### Setup

Run [setup.sh](setup.sh) to enable required services and add right roles to your user account.

### Test

See [job.json](job.json) for the job definition. It runs 3 busybox containers
and echos some environment variables.

Run [test.sh](test.sh) to run the Batch job. Once the job is started, you should
see 3 Compute Engine VMs created and you can check the logs of the VMs to see
the outputted environment variables.

## Simple container with Workflows

### Setup

Run [setup-workflow.sh](setup-workflow.sh) to enable required services and
create a service account with the right roles for Workflows.

### Test

See [workflow.yaml](workflow.yaml) for the workflow definition. It creates a
batch job with the busybox containers, waits for the job to complete and then
deletes the job.

Run [test-workflow.sh](test-workflow.sh) to deploy and then execute the
workflow. You can check the result of the workflow execution in Google Cloud
console.