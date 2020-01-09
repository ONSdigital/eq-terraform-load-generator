#!/usr/bin/env bash

set -e

if [[ -z "$PROJECT_ID" ]]; then
  echo "Missing PROJECT_ID variable"
  exit 1
fi

# Destroy infrastructure
TF_VAR_project_id=${PROJECT_ID} scripts/destroy_infrastructure.sh
