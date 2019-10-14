#!/usr/bin/env bash

set -e

ENV=$1
TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-census-eq-terraform-tfstate}"

terraform init --upgrade --backend-config prefix=${ENV} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

# This will get destroyed as part of deleting the project
terraform state rm google_compute_network.k8s

# Destroy infrastructure
terraform destroy -auto-approve