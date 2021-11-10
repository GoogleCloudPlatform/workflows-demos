# Basic Terraform

This sample shows how to use Terraform's [google_workflows_workflow](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/workflows_workflow)
resource to deploy a Workflow.

More specifically, this sample:

1. Enables Workflows API.
1. Creates a service account for Workflows to use.
1. Deploys a workflow using Terraform.
1. Executes the workflow with gcloud.

## Terraform

You can see [main.tf](main.tf) for the definition.

1. Initialize terraform:

    ```sh
    terraform init
    ```

1. See the planned changes:

    ```sh
    terraform plan -var="project_id=YOUR-PROJECT-ID"
    ```

1. Create workflow:

    ```sh
    terraform apply -var="project_id=YOUR-PROJECT-ID"
    ```

1. Once workflow is created, you can see it in the list:

    ```sh
    gcloud workflows list --location YOUR-GCP-REGION
    ```

1. Cleanup:

    ```sh
    terraform destroy -var="project_id=YOUR-PROJECT-ID"
    ```

## Execute

You can optionally execute the workflow using gcloud:

```sh
gcloud workflows execute sample-workflow
```
