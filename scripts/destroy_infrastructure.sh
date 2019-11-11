#!/usr/bin/env bash

set -e

TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-eq-terraform-load-generator-tfstate}"

terraform init --upgrade --backend-config prefix=${PROJECT_NAME} -var "project_name=${PROJECT_NAME}" --backend-config bucket=${TERRAFORM_STATE_BUCKET}

# This will get destroyed as part of deleting the project
terraform state rm google_compute_network.k8s

# Destroy infrastructure
terraform destroy -auto-approve -var "project_name=${PROJECT_NAME}"