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
scripts/deploy_infrastructure.sh ${PROJECT_NAME}

PROJECT_ID=$(terraform output google_project_id)
REGION=$(terraform output region)
# Login to cluster
gcloud container clusters get-credentials runner-benchmark --region ${REGION} --project ${PROJECT_ID}

GCS_OUTPUT_BUCKET=$(terraform output benchmark-output-storage)
scripts/deploy_benchmark.sh ${RUNNER_URL} ${GCS_OUTPUT_BUCKET}

echo
echo "Testing Survey Runner URL: ${RUNNER_URL}"
