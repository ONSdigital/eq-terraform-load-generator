#!/usr/bin/env bash

set -e

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Missing PROJECT_NAME variable"
  exit 1
fi

# Destroy infrastructure
TF_VAR_project_name=${PROJECT_NAME} scripts/destroy_infrastructure.sh
