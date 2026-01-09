# --- Prefix ---
variable "prefix" {
  type        = string
  description = "Project prefix"
}

locals {
  gke_name          = "${var.prefix}-cluster"
  node_pool_name    = "${var.prefix}-node-pool"
  app_ns            = "${var.prefix}-ns"
  workload_identity = "${var.prefix}-workload-identity"
  ksa_name          = "${var.prefix}-ksa"
}

# --- GCP ---
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
}
