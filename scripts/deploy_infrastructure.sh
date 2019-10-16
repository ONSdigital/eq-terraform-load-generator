#!/usr/bin/env bash

set -ex

ENV=$1
TERRAFORM_STATE_BUCKET="${TERRAFORM_STATE_BUCKET:-census-eq-terraform-tfstate}"

terraform init --upgrade --backend-config prefix=${ENV} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

if [ ! -z $EXISTING_PROJECT_ID ]; then
    echo "Using existing project_id: $EXISTING_PROJECT_ID"

    if terraform state list | grep -q "google_project.project"; then
        echo "State contains a google project. Not importing"
    else
        echo "State does not contain a google project. Importing $EXISTING_PROJECT_ID"
        terraform import google_project.project $EXISTING_PROJECT_ID
    fi
fi

# Roll out infrastructure
terraform apply -auto-approve

PROJECT_ID=$(terraform output google_project_id)
REGION=$(terraform output region)

# Login to cluster
gcloud container clusters get-credentials runner-benchmark --region ${REGION} --project ${PROJECT_ID}

kubectl create configmap benchmark-config \
  --dry-run -o yaml | kubectl apply -f -
