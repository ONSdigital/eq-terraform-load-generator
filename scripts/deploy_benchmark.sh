#!/usr/bin/env bash

set -e

TEMP_DIR=$(mktemp -d)

# Clone benchmark repo
git clone --branch main --depth 1 https://github.com/ONSdigital/eq-survey-runner-benchmark.git "${TEMP_DIR}"/eq-survey-runner-benchmark

cd ${TEMP_DIR}/eq-survey-runner-benchmark

# Login to cluster
gcloud container clusters get-credentials runner-benchmark --region ${REGION} --project ${PROJECT_ID}

helm tiller run \
    helm upgrade --install \
    runner-benchmark \
    k8s/helm \
    --set host=${RUNNER_URL} \
    --set locustOptions="--no-web -c 1 -r 1 -t 1m --csv=output -L WARNING" \
    --set container.image=eu.gcr.io/census-eq-ci/eq-survey-runner-benchmark:latest \
    --set output.bucket=${GCS_OUTPUT_BUCKET}

rm -rf "${TEMP_DIR}"
