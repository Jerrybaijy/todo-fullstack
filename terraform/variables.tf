# --- Prefix ---
variable "prefix" {
  type        = string
  description = "Project prefix"
  default     = "todo"
}

locals {
  gke_name       = "${var.prefix}-cluster"
  node_pool_name = "${var.prefix}-node-pool"
  app_ns         = "${var.prefix}-ns"
  sa_id          = "${var.prefix}-sa-id"
  ksa_name       = "${var.prefix}-ksa"
  db_instance    = "${var.prefix}-db-instance"
  db_name        = "${var.prefix}_db"
  project_name   = "${var.prefix}-fullstack"
  app_name       = "${var.prefix}-app"
  chart_name     = "${var.prefix}-chart"
  chart_repo     = "registry.gitlab.com/jerrybai/${local.project_name}"
}

# --- GCP ---
variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "project-60addf72-be9c-4c26-8db"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "asia-east2"
}

variable "zone" {
  type        = string
  description = "GCP Zone"
  default     = "asia-east2-a"
}

# --- Cloud SQL ---
variable "mysql_root_password" {
  type        = string
  description = "MySQL root user password"
  sensitive   = true
}

variable "mysql_jerry_password" {
  type        = string
  description = "MySQL jerry user password"
  sensitive   = true
}

# --- Argo CD ---
variable "my_external_ip" {
  type        = string
  description = "My external IP access to Argo CD"
  sensitive   = true
}
