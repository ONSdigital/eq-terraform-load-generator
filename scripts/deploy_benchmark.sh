#!/usr/bin/env bash

set -e

RUNNER_URL=$1
TEMP_DIR=$(mktemp -d)

# Clone Launcher Repo
git clone --branch master --depth 1 https://github.com/ONSdigital/eq-survey-runner-benchmark.git "${TEMP_DIR}"/eq-survey-runner-benchmark

cd ${TEMP_DIR}/eq-survey-runner-benchmark

helm tiller run \
    helm upgrade --install \
    runner-benchmark \
    k8s/helm \
    --set host=${RUNNER_URL} \
    --set container.image=eu.gcr.io/census-eq-ci/eq-survey-runner-benchmark:latest

rm -rf "${TEMP_DIR}"