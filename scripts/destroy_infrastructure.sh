#!/usr/bin/env bash

set -euxo pipefail

TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-eq-terraform-load-generator-tfstate}"

tfenv use "$(< .terraform-version)"

terraform init --upgrade --backend-config prefix=${TF_VAR_project_name} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

# Do not delete the project or bucket.
terraform state rm google_project.project
terraform state rm google_storage_bucket.benchmark-output-storage

# Destroy infrastructure
terraform destroy --auto-approve

# Import project and bucket resouce back into the state
terraform import google_project.project "$PROJECT_ID"
terraform import google_storage_bucket.benchmark-output-storage ${PROJECT_ID}-benchmark-outputs
