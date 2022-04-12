# Basic callback endpoint sample

In this sample, you will see to create a callback endpoint within your workflow
that can receive HTTP `GET` or `POST` requests and in a later step wait for a request to arrive
at that endpoint.

## Enable services

First, enable required services:

```sh
gcloud services enable workflows.googleapis.com
```

## Define workflow

Create a [workflow-get.yaml](workflow-get.yaml) and
[worklow-post.yaml](workflow-post.yaml] to define workflows accepting HTTP `GET`
or `POST`.

In the `create_callback` step, create an endpoint with `GET`:

```yaml
- create_callback:
    call: events.create_callback_endpoint
    args:
        http_callback_method: "GET"
    result: callback_details
```

Or you could create an endpoint with `POST`:

```yaml
- create_callback:
    call: events.create_callback_endpoint
    args:
        http_callback_method: "POST"
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

Deploy workflows:

```sh
gcloud workflows deploy callback-basic-get --source=workflow-get.yaml
gcloud workflows deploy callback-basic-post --source=workflow-post.yaml
```

Run workflows:

```sh
gcloud workflows run callback-basic-get
gcloud workflows run callback-basic-post
```

The workflow should be in waiting state right now. Check the logs to find the
url of the callback.

## Test

Assuming that you have `Workflows Editor` or `Workflows Admin` roles, you can
call the workflow with `gcloud`.

To test the workflow waiting for `GET`:

```sh
CALLBACK_URL=https://workflowexecutions.googleapis.com/v1/projects/...
curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" $CALLBACK_URL
```

To test the workflow waiting for `POST`:

```sh
CALLBACK_URL=https://workflowexecutions.googleapis.com/v1/projects/...
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $(gcloud auth print-access-token)" -d '{"foo" : "bar"}' $CALLBACK_URL
```

You should see the workflow execution succeed.
