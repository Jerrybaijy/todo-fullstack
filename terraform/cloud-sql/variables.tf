# --- Prefix ---
variable "prefix" {
  type        = string
  description = "Project prefix"
}

locals {
  db_instance    = "${var.prefix}-db-instance"
  db_name        = "${var.prefix}_db"
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