#!/usr/bin/env bash

set -euxo pipefail

TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-eq-terraform-load-generator-tfstate}"

tfenv use "$(< .terraform-version)"
terraform init --upgrade --backend-config prefix=${TF_VAR_project_id} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

echo "Using existing project_id: $TF_VAR_project_id"

# Roll out infrastructure
terraform apply -auto-approve -var "project_id=${TF_VAR_project_id}"
