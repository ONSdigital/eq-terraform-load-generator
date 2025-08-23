#!/usr/bin/env bash

set -euxo pipefail

TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-eq-terraform-load-generator-tfstate}"

terraform init --upgrade --backend-config prefix="${PROJECT_ID}" --backend-config bucket="${TERRAFORM_STATE_BUCKET}"

terraform state list
ps aux | grep terraform

# Do not delete the bucket.
echo "yes" | terraform force-unlock 1739200033416417
export TF_VAR_project_id="$PROJECT_ID"
terraform import google_storage_bucket.benchmark-output-storage "${PROJECT_ID}-outputs"
terraform state rm google_storage_bucket.benchmark-output-storage
# Destroy infrastructure
terraform destroy --auto-approve -var "project_id=${PROJECT_ID}"

# Import bucket resource back into the state
terraform import -var "project_id=${PROJECT_ID}" google_storage_bucket.benchmark-output-storage "${PROJECT_ID}"-outputs
