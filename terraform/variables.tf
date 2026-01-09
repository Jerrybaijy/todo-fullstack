# --- Prefix ---
variable "prefix" {
  type        = string
  description = "Project prefix"
  default     = "todo"
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
