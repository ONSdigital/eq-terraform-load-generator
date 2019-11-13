#!/usr/bin/env bash

set -e

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Missing PROJECT_NAME variable"
  exit 1
fi

if [[ -z "$RUNNER_URL" ]]; then
  echo "Missing RUNNER_URL to test"
  exit 1
fi

# Deploy infrastructure
PROJECT_NAME=${PROJECT_NAME} scripts/deploy_infrastructure.sh

PROJECT_ID=$(terraform output google_project_id)
REGION=$(terraform output region)
GCS_OUTPUT_BUCKET=$(terraform output benchmark-output-storage)

PROJECT_ID=${PROJECT_ID} REGION=${REGION} RUNNER_URL=${RUNNER_URL} GCS_OUTPUT_BUCKET=${GCS_OUTPUT_BUCKET} ./scripts/deploy_benchmark.sh

echo
echo "Testing Survey Runner URL: ${RUNNER_URL}"
