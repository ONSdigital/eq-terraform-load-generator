#!/usr/bin/env bash

set -euxo pipefail

TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-eq-terraform-load-generator-tfstate}"

tfenv use "$(< .terraform-version)"
terraform init --upgrade --backend-config prefix=${TF_VAR_project_name} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

echo "Using existing project_id: $TF_VAR_project_name"

if terraform state list | grep "google_project.project"; then
    echo "State contains a google project. Not importing"
else
    echo "State does not contain a google project. Importing $TF_VAR_project_name"
    terraform import -var "project_name=${TF_VAR_project_name}" google_project.project $TF_VAR_project_name
fi

# Roll out infrastructure
terraform apply -auto-approve -var "project_name=${TF_VAR_project_name}"
