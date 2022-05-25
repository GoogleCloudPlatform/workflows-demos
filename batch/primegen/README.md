# Batch - prime number generator container

> **Note:** Google Batch service is feature in *preview*.
> Only allow-listed projects can currently take advantage of it. Please fill the
> following [form](https://docs.google.com/forms/d/e/1FAIpQLSdfwO0N4oTu14bW3yxJBAak4KMn8qqeArs2NuNBXDrcjG-g5Q/viewform)
> to get your project allow-listed before attempting this sample.

In this sample, you'll see how to run a prime number generator container as a
job in Batch service. You will automate the lifecycle of the Batch job using Workflows.

The Google Batch service provides an end to end fully-managed batch service,
which allows you to schedule, queue, and execute jobs on Google compute
instances. The service provisions resources, manages capacity and allows batch
workloads to run at scale.

## Before you begin

Make sure your project id is set in gcloud:

```sh
gcloud config set project PROJECT_ID
```

## Prime number generator container

In this sample, you will schedule a batch job to run a prime number generator
container. You can see the code of the container in
[PrimeGenService](PrimeGenService) folder.

### Setup

Run [setup.sh](setup.sh) to enable required services, create a service acount
for the right roles for Workflows and build and save the container.

### Test

See [workflow.yaml](workflow.yaml) for the workflow definition. It creates a
batch job with the container, waits for the job to complete and then
deletes the job.

Run [test.sh](test.sh) to deploy and then execute the workflow. You can check
the result of the workflow execution in Google Cloud console.
