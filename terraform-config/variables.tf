variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "project-60addf72-be9c-4c26-8db"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-east2"
}

variable "zone" {
  description = "GKE Zone"
  type        = string
  default     = "asia-east2-a"
}
