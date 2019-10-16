#!/usr/bin/env bash

set -e

if [[ -z "$ENV" ]]; then
  echo "Missing ENV variable"
  exit 1
fi

if [[ -z "$RUNNER_URL" ]]; then
  echo "Missing RUNNER_URL to test"
  exit 1
fi

# Deploy infrastructure
scripts/deploy_infrastructure.sh ${ENV}

scripts/deploy_benchmark.sh ${RUNNER_URL}

echo
echo "Testing Survey Runner URL: ${RUNNER_URL}"
