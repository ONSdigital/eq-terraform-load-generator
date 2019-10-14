#!/usr/bin/env bash

set -e

if [[ -z "$ENV" ]]; then
  echo "Missing ENV variable"
  exit 1
fi

# Deploy infrastructure
scripts/deploy_infrastructure.sh ${ENV}

RUNNER_URL=${RUNNER_URL}

scripts/deploy_benchmark.sh ${RUNNER_URL}

echo
echo "Testing Survey Runner URL: ${RUNNER_URL}"
