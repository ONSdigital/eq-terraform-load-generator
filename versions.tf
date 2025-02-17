terraform {
  required_version = ">= 1.9.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.44.0, < 6.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.44.0, < 6.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
  }
}
