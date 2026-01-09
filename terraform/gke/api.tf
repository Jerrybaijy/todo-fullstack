locals {
  services = [
    "compute.googleapis.com",        # Compute Engine API
    "container.googleapis.com",      # Kubernetes Engine API
    "iam.googleapis.com",            # IAM API
    "iamcredentials.googleapis.com", # Workload Identity API
  ]
}

resource "google_project_service" "project_services" {
  for_each           = toset(local.services)
  service            = each.key
  disable_on_destroy = false
}
