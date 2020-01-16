#!/usr/bin/env bash

set -e

if [[ -z "$PROJECT_ID" ]]; then
  echo "Missing PROJECT_ID variable"
  exit 1
fi

if [[ -z "$RUNNER_URL" ]]; then
  echo "Missing RUNNER_URL to test"
  exit 1
fi

# Deploy infrastructure
PROJECT_ID=${PROJECT_ID} scripts/deploy_infrastructure.sh

REGION=$(terraform output region)
GCS_OUTPUT_BUCKET=$(terraform output benchmark-output-storage)

REGION=${REGION} RUNNER_URL=${RUNNER_URL} GCS_OUTPUT_BUCKET=${GCS_OUTPUT_BUCKET} ./scripts/deploy_benchmark.sh

echo
echo "Testing Survey Runner URL: ${RUNNER_URL}"
