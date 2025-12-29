terraform {
  required_providers {
    google = {
      version = "~> 7.14.0"
      source  = "hashicorp/google"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.0"
    }
  }
}
