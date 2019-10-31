#!/usr/bin/env bash

set -e

RUNNER_URL=$1
GCS_OUTPUT_BUCKET=$2
TEMP_DIR=$(mktemp -d)

# Clone Launcher Repo
git clone --branch store_results_in_storge_bucket --depth 1 https://github.com/ONSdigital/eq-survey-runner-benchmark.git "${TEMP_DIR}"/eq-survey-runner-benchmark

cd ${TEMP_DIR}/eq-survey-runner-benchmark

helm tiller run \
    helm upgrade --install \
    runner-benchmark \
    k8s/helm \
    --set host=${RUNNER_URL} \
    --set locustOptions="--no-web -c 1 -r 1 -t 1m --csv=output -L WARNING" \
    --set container.image=eu.gcr.io/census-eq-ci/eq-survey-runner-benchmark:store-output \
    --set gcsOutputBucket=${GCS_OUTPUT_BUCKET}

rm -rf "${TEMP_DIR}"