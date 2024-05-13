terraform {
  required_version = ">= 1.7.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.28.0, < 6.0.0"
    }
  }
}
