# Create and Access Secrets in Secret Manager

In this example you'll see how to use the [Workflow Connector to Secret Manger](https://cloud.google.com/workflows/docs/reference/googleapis/secretmanager/Overview) to **create** and **access** `string` secrets in Secret Manager.

More specifically, you will use Secret Manager's [create](https://cloud.google.com/workflows/docs/reference/googleapis/secretmanager/v1/projects.secrets/create) and [addVersionString](https://cloud.google.com/workflows/docs/reference/googleapis/secretmanager/v1/projects.secrets/addVersionString) methods to create a secret, and [accessString](https://cloud.google.com/workflows/docs/reference/googleapis/secretmanager/v1/projects.secrets.versions/accessString) method to read the value of a secret.

## Create a Secret

First, you need to specify the GCP project where you want to store the secret. You can use the `GOOGLE_CLOUD_PROJECT_ID` environment variable to get the current project ID.

```yaml
- Get Project ID:
    call: sys.get_env
    args:
      name: GOOGLE_CLOUD_PROJECT_ID
    result: project_id
```

Then, you can create a secret with the `projects.secrets.create` method. This method creates a new secret containing no **SecretVersions**.

```yaml
- Create Secret:
    call: googleapis.secretmanager.v1.projects.secrets.create
    args:
      parent: ${"projects/" + project_id}
      secretId: ${secret_id}
      body:
        replication:
          automatic: {}
```

Finally, you can add a new **SecretVersion** to the created secret and fill it with the secret value.

```yaml
- Add Version To Secret:
    call: googleapis.secretmanager.v1.projects.secrets.addVersionString
    args:
      project_id: ${project_id}
      secret_id: ${secret_id}
      data: ${secret_value}
```

> Notice that the `secret_id` and `secret_value` are simple variables that you can either hard-code or retrieve from the workflow's input.

## Access a Secret

To access the value of a secret, you can use the `projects.secrets.versions.accessString` method.

```yaml
- Access Secret String:
    call: googleapis.secretmanager.v1.projects.secrets.versions.accessString
    args:
      project_id: ${project_id}
      secret_id: ${secret_id}
      version: ${version}
    result: secret_value
```

> The `version` is optional and defaults to the **latest** version. If you want to access a specific version, you can specify it.
