#!/usr/bin/env bash

set -ex

tfenv use "$(< .terraform-version)"
terraform init --upgrade --backend-config prefix=${PROJECT_NAME} --backend-config bucket=${TERRAFORM_STATE_BUCKET}

if [ "$IMPORT_EXISTING_PROJECT" = true ]; then
    echo "Using existing project_id: $PROJECT_NAME"

    if terraform state list | grep -q "google_project.project"; then
        echo "State contains a google project. Not importing"
    else
        echo "State does not contain a google project. Importing $PROJECT_NAME"
        terraform import -var "project_name=${PROJECT_NAME}" google_project.project $PROJECT_NAME
    fi
fi

# Roll out infrastructure
terraform apply -auto-approve -var "project_name=${PROJECT_NAME}"
