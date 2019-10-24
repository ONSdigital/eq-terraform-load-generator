#!/usr/bin/env bash

set -ex

PROJECT_NAME=$1
TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-eq-terraform-load-generator-tfstate}"
IMPORT_EXISTING_PROJECT="${IMPORT_EXISTING_PROJECT:-false}"

terraform init --upgrade --backend-config prefix=${PROJECT_NAME} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

if [ "$IMPORT_EXISTING_PROJECT" = true ]; then
    echo "Using existing project_id: $PROJECT_NAME"

    if terraform state list | grep -q "google_project.project"; then
        echo "State contains a google project. Not importing"
    else
        echo "State does not contain a google project. Importing $PROJECT_NAME"
        terraform import google_project.project $PROJECT_NAME
    fi
fi

# Roll out infrastructure
terraform apply -auto-approve -var "project_name=${PROJECT_NAME}"

PROJECT_ID=$(terraform output google_project_id)
REGION=$(terraform output region)

# Login to cluster
gcloud container clusters get-credentials runner-benchmark --region ${REGION} --project ${PROJECT_ID}