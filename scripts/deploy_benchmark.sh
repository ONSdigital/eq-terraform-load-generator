#!/usr/bin/env bash

set -e

RUNNER_URL=$1
current_dir=$(dirname "${BASH_SOURCE[0]}")
parent_dir=$(dirname "${current_dir}")
path_to_parent="$( cd "${parent_dir}" && pwd )"
temp_dir="${path_to_parent}"/temp

# Delete temp dir if it exists
rm -rf "${temp_dir}"

# Clone Launcher Repo
git clone --branch eq-3425-terraform-benchmark --depth 1 https://github.com/ONSdigital/eq-survey-runner-benchmark.git "${temp_dir}"/eq-survey-runner-benchmark

cd ${temp_dir}/eq-survey-runner-benchmark

helm tiller run \
    helm upgrade --install \
    runner-benchmark \
    k8s/helm \
    --set host=${RUNNER_URL} \
    --set image.repository=${DOCKER_REGISTRY}/eq-survey-runner-benchmark \
    --set image.tag=${IMAGE_TAG}

# Delete repo
rm -rf "${temp_dir}"