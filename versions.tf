terraform {
  required_version = ">= 1.9.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.29.0, < 7.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.29.0, < 7.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.1, < 4.0.0"
    }
  }
}
