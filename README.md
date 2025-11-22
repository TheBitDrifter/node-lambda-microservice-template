# Node.js Lambda Microservice Template

This repository is a template for creating **Service-Oriented** Lambda applications. It supports multiple Lambda functions within a single service repository.

## Architecture

*   **Functions**: Located in `functions/`. Each file exports a `handler`.
*   **Infrastructure**: Managed by Terraform in `terraform/`.
*   **Deployment**: GitHub Actions zips the entire repo and deploys it.

## Managing Endpoints

### Adding a New Endpoint
1.  **Create Code**: Add a new file in `functions/` (e.g., `functions/create-user.js`).
2.  **Register in Terraform**: Add an entry to the `locals` block in `terraform/main.tf`:

    ```hcl
    locals {
      lambdas = {
        # ... existing functions ...
        "create-user" = {
          handler      = "functions/create-user.handler"
          path_pattern = "/${var.service_name}/create"
          method       = "POST"
        }
      }
    }
    ```

### Removing an Endpoint
1.  **Unregister**: Remove the entry from the `locals` block in `terraform/main.tf`.
2.  **Delete Code**: Delete the corresponding file from `functions/`.
3.  **Deploy**: Run the deployment workflow to apply changes (Terraform will destroy the removed Lambda).

## Deployment Setup (OIDC & Secrets)

Deployment is automated via GitHub Actions using **OIDC** for secure authentication.

### GitHub Secrets Configuration

Store the following **Secrets** in your repository settings (**Settings > Secrets and variables > Actions > Secrets**):

| Secret Name | Purpose | Value Example |
| :--- | :--- | :--- |
| **`AWS_OIDC_ROLE_ARN`** | The IAM role the workflow will assume for deployment permissions. | `arn:aws:iam::[ACCOUNT_ID]:role/GitHubActionsDeployer` |

### GitHub Variables Configuration

Store the following **Variables** in your repository settings (**Settings > Secrets and variables > Actions > Variables**):

| Variable Name | Purpose | Value Example |
| :--- | :--- | :--- |
| **`AWS_REGION`** | Specifies the deployment region. | `us-east-1` |
| **`S3_STATE_BUCKET_NAME`** | **The name of the S3 bucket created for Terraform state.** | `acme-tf-state-prod-2025` |
| **`DYNAMODB_LOCK_TABLE`** | **The name of the DynamoDB table for state locking.** | `acme-tf-locks` |
| **`SERVICE_ALIAS`** | **Unique identifier for this service (e.g., user-service).** | `user-service` |

## Deployment

Run the **Deploy Lambda Service** workflow from the Actions tab.

## Destroying the Service

To tear down the infrastructure:
1.  Go to the **Actions** tab.
2.  Select **Destroy Lambda Service**.
3.  Choose the environment to destroy.
4.  Run the workflow.
