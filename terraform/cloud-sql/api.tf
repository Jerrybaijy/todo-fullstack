locals {
  services = [
    "sqladmin.googleapis.com", # Cloud SQL API
    "iam.googleapis.com",      # IAM API
  ]
}

resource "google_project_service" "project_services" {
  for_each           = toset(local.services)
  service            = each.key
  disable_on_destroy = false
}
