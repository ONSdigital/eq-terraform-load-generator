#!/usr/bin/env bash

set -e

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Missing PROJECT_NAME variable"
  exit 1
fi

# Destroy infrastructure
scripts/destroy_infrastructure.sh ${PROJECT_NAME}
