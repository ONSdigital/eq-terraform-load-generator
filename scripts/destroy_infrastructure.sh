#!/usr/bin/env bash

set -euxo pipefail

TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-eq-terraform-load-generator-tfstate}"

tfenv use "$(< .terraform-version)"

terraform init --upgrade --backend-config prefix=${TF_VAR_project_id} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

# Do not delete the bucket.
terraform state rm google_storage_bucket.benchmark-output-storage

# Destroy infrastructure
terraform destroy --auto-approve

# Import bucket resouce back into the state
terraform import google_storage_bucket.benchmark-output-storage ${TF_VAR_project_id}-benchmark-outputs
