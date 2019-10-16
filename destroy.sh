#!/usr/bin/env bash

set -e

if [[ -z "$ENV" ]]; then
  echo "Missing ENV variable"
  exit 1
fi

# Destroy infrastructure
scripts/destroy_infrastructure.sh ${ENV}
