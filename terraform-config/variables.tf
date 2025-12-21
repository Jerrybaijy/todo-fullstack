variable "project_id" {
  description = "Google Cloud 项目的 ID"
  type        = string
  default     = "project-60addf72-be9c-4c26-8db"
}

variable "region" {
  description = "GCP 资源的默认部署区域"
  type        = string
  default     = "asia-east2"
}

variable "zone" {
  description = "GKE 节点的具体可用区"
  type        = string
  default     = "asia-east2-a"
}
