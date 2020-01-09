#!/usr/bin/env bash

set -euxo pipefail

TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-eq-terraform-load-generator-tfstate}"

tfenv use "$(< .terraform-version)"
terraform init --upgrade --backend-config prefix=${TF_VAR_project_id} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

echo "Using existing project_id: $TF_VAR_project_id"

if terraform state list | grep "google_project.project"; then
    echo "State contains a google project. Not importing"
else
    echo "State does not contain a google project. Importing $TF_VAR_project_id"
    terraform import -var "project_id=${TF_VAR_project_id}" google_project.project $TF_VAR_project_id
fi

# Roll out infrastructure
terraform apply -auto-approve -var "project_id=${TF_VAR_project_id}"
