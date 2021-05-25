# Create, start, stop VM using Compute Connector

In this sample, you will see how to use [Workflows
Connectors](https://cloud.google.com/workflows/docs/reference/googleapis/).

More specifically, you will use Compute Engine Connector's
[insert](https://cloud.google.com/workflows/docs/reference/googleapis/compute/v1/instances/insert)
to create and start a VM and
[stop](https://cloud.google.com/workflows/docs/reference/googleapis/compute/v1/instances/stop)
to stop the running VM.

## Create a VM - Compute Engine API

Before trying Workflows, let's take a look at how to create a VM with Compute
Engine
[insert](https://cloud.google.com/compute/docs/reference/rest/v1/instances/insert)
API directly for project `workflows-atamel` in zone `europe-west1-b`:

```sh
POST https://compute.googleapis.com/compute/v1/projects/workflows-atamel/zones/europe-west1-b/instances?key=[YOUR_API_KEY] HTTP/1.1

Authorization: Bearer [YOUR_ACCESS_TOKEN]
Accept: application/json
Content-Type: application/json

{
  "name": "my-vm1",
  "machineType": "projects/workflows-atamel/zones/europe-west1-b/machineTypes/e2-small",
  "disks": [
    {
      "initializeParams": {
        "sourceImage": "projects/debian-cloud/global/images/debian-10-buster-v20210316"
      },
      "boot": true,
      "autoDelete": true
    }
  ],
  "networkInterfaces": [
    {
      "network": "global/networks/default"
    }
  ]
}
```

## Create a VM - Workflows without connector

First, let's try creating the same VM with Workflows but without the compute
connector.

You can see the [create-vm.yaml](create-vm.yaml) for the workflow definition
that makes the `http.post` call with `OAuth2` authentication. You will also
realize that there's an `assert_running` step that needs to check whether the VM
has started and if not, the workflow sleeps and checks again in 3 seconds.

Deploy workflow:

```sh
gcloud workflows deploy create-vm --source=create-vm.yaml
```

Execute workflow:

```sh
gcloud workflows execute create-vm --data='{"instanceName":"my-vm"}'
```

## Stop a VM - Workflows without connector

Next, stop the VM with Workflows but without the compute connector.

You can see the [stop-vm.yaml](stop-vm.yaml) for the workflow definition
that makes the `http.post` call with `OAuth2` authentication.

The workflow uses the default retry policy for HTTP calls: retry requests on
status codes 429 Too Many Requests, 502 Bad Gateway, and 503 Service Unavailable.

The `instances.stop` API is a long running operation. This workflow polls the
operation status periodically until either the operation is successfully
completed or an error occurs.

Deploy workflow:

```sh
gcloud workflows deploy stop-vm --source=stop-vm.yaml
```

Execute workflow:

```sh
gcloud workflows execute stop-vm --data='{"instanceName":"my-vm"}'
```

## Create a VM - Workflows with compute connector

Next, let's try creating the same VM with Workflows and the compute connector.

You can see the [create-vm-connector.yaml](create-vm-connector.yaml) for the
workflow definition. You'll realize that `assert_running` step does not need to
sleep anymore because the connector does the job of waiting for the VM to be
created.

Deploy workflow:

```sh
gcloud workflows deploy create-vm-connector --source=create-vm-connector.yaml
```

Execute workflow:

```sh
gcloud workflows execute create-vm-connector --data='{"instanceName":"my-vm"}'
```

## Create and stop a VM - Workflows with compute connector

Finally, let's try to stop the created & running VM with the connector.

You can see the [create-stop-vm-connector.yaml](create-stop-vm-connector.yaml)
for the workflow definition.

Deploy workflow:

```sh
gcloud workflows deploy create-stop-vm-connector --source=create-stop-vm-connector.yaml
```

Execute workflow:

```sh
gcloud workflows execute create-stop-vm-connector --data='{"instanceName":"my-vm"}'
```
