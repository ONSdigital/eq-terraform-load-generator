#!/usr/bin/env bash

set -euxo pipefail

tfenv use "$(< .terraform-version)"

terraform init --upgrade --backend-config prefix=${PROJECT_NAME} -var "project_name=${PROJECT_NAME}" --backend-config bucket=${LOAD_GENERATOR_TF_STATE_BUCKET}

# Do not delete the project or bucket.
terraform state rm google_project.project
terraform state rm google_storage_bucket.benchmark-output-storage

# Destroy infrastructure
terraform destroy --auto-approve -var "project_name=${PROJECT_NAME}"

# Import project and bucket resouce back into the state
terraform import google_project.project "$PROJECT_ID"
terraform import google_storage_bucket.benchmark-output-storage ${PROJECT_ID}-benchmark-outputs
