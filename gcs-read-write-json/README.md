Although Workflows provides a 
[Google Cloud Storage connector](https://cloud.google.com/workflows/docs/reference/googleapis/storage/Overview), 
it is not yet possible to read and write files with its API.
However, it's possible to use GCS's REST [JSON API](https://cloud.google.com/storage/docs/json_api) 
directly for that purpose, from your workflow definition.

**Note:** Your workflow should be deployed with a service account that has *Google Cloud Storage Object Viewer* permission.

Write a JSON file into a GCS bucket
===

As shown in [gcs-write-workflow.yaml](gcs-read-write-json/gcs-write-workflow.yaml), 
you can write into the `data.json` file as follows:

```
    - write_to_gcs:
        call: http.post
        args:
            url: ${"https://storage.googleapis.com/upload/storage/v1/b/" + bucket + "/o"}
            auth:
                type: OAuth2
            query:
                name: data.json
            body:
                greeting: "Hello World"
                year: 2022
```

The body contains your structured data in YAML, but it is converted into JSON
as we write into a JSON file.

Read a JSON file from a GCS bucket
===

In order to read from a file in a GCS bucket, we take the same approach,
as shown in [gcs-read-workflow.yaml](gcs-read-write-json/gcs-read-workflow.yaml):

```
    - read_from_gcs:
        call: http.get
        args:
            url: ${"https://storage.googleapis.com/download/storage/v1/b/" + bucket + "/o/" + name}
            auth:
                type: OAuth2
            query:
                alt: media
        result: data_json_content
    - return_content:
        return: ${data_json_content.body}
```

The `data_json_content.body` value is an array or dictionary (your JSON data)
that you can use directly elsewhere in your workflow definition.

