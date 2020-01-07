# EQ Load Generator

This folder contains the config for the EQ load generator infrastructure. It uses the eq-survey-runner-benchmark repo in order to configure a load test using http://locust.io.

* Terraform is used to create a network and K8s cluster in GCP (this defaults to a single machine)
* We then apply some K8 config to the cluster
* We then download eq-survey-runner-benchmark and run its k8s config.

## Prerequisites

1. Install [Terraform Version Manager](https://github.com/kamatama41/tfenv)

1. Install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts)

1. Login to your [google cloud console](https://console.cloud.google.com/), make sure you are using the correct account and accept any Terms of Service.

1. Login to the CLI with your Google account `gcloud auth login` and `gcloud auth application-default login`

1. Install kubectl with `gcloud components install kubectl`

1. Install Helm with `brew install kubernetes-helm` and then run `helm init --client-only`

1. Install Helm Tiller plugin for tillerless deploys `helm plugin install https://github.com/rimusz/helm-tiller`

## Creating an environment

### Development

Use a PROJECT_NAME name which follows the naming conventions here: https://cloud.google.com/storage/docs/naming

Rename `terraform.tfvars.example` to `terraform.tfvars` and fill in the values. (Ask a team member for help).

Create with `PROJECT_NAME=your-project-name RUNNER_URL=https://your-runner.gcp.dev.eq.ons.digital ./create.sh`

Destroy with `PROJECT_NAME=your-project-name ./destroy.sh`. This will destory all resources except the project itself and the assosciated storage bucket. To permenantly destroy the infrastructure, including the project and storage bucket, delete the project via the GCP UI.

If you are deploying to an existing environment, you can use the `IMPORT_EXISTING_PROJECT` and the `PROJECT_NAME` variable to show this:
```
IMPORT_EXISTING_PROJECT=true PROJECT_NAME=existing-project-id RUNNER_URL=https://your-runner.gcp.dev.eq.ons.digital ./create.sh
```

If you want to vary the default parameters Locust uses on start, you can specify them using the LOCUST_OPTS environment variable:
```
LOCUST_OPTS="-f locustfile.py -c 1000 -r 50 -L WARNING" RUNNER_URL=http://your-runner.gcp.dev.eq.ons.digital PROJECT_NAME=your-project-name ./create.sh
```
Will create an environment running locust with a web interface with 1000 clients and a hatch rate of 50, with a log level of warnings and above.

Terraform state will by default be stored in the `eq-terraform-load-generator-tfstate` bucket, this bucket can be overridden by setting the `TERRAFORM_STATE_BUCKET` environment variable

