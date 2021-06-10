# Basic callback endpoint sample

In this sample, you will see to create a callback endpoint within your workflow
that can receive HTTP requests and in a later step wait for a request to arrive
at that endpoint.

**Note that this feature is currently in private preview**

## Enable services

First, enable required services:

```sh
gcloud services enable \
  workflows.googleapis.com
```

## Define workflow

Create a [workflow.yaml](workflow.yaml) to define the workflow:

In the `create_callback` step, create an endpoint:

```yaml
- create_callback:
    call: events.create_callback_endpoint
    args:
        http_callback_method: "GET"
    result: callback_details
```

In the second step, print the `url` for the callback endpoint:

```yaml
- print_callback_details:
    call: sys.log
    args:
        severity: "INFO"
        text: ${"Listening for callbacks on " + callback_details.url}
```

In the third step, wait for the callback to be called with a timeout:

```yaml
- await_callback:
    call: events.await_callback
    args:
        callback: ${callback_details}
        timeout: 3600
    result: callback_request
```

In the last step, print the callback result:

```yaml
- print_callback_result:
    return: ${callback_request.http_request}
```

## Deploy and execute workflow

Deploy workflow:

```sh
gcloud workflows deploy callback-basic \
    --source=workflow.yaml
```

Execute workflow:

```sh
gcloud workflows execute callback-basic
```

The workflow should be in waiting state right now. Check the logs to find the
url of the callback.

## Test

Assuming that you have `Workflows Editor` or `Workflows Admin` roles, you can
call the workflow with `gcloud`:

```sh
curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" https://workflowexecutions.googleapis.com/v1/projects/...
```

You should see the worklow execution succeed.
