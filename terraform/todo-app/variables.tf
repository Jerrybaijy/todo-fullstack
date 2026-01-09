variable "prefix" {
  type        = string
  description = "Project prefix"
}

locals {
  project_name   = "${var.prefix}-gcp"
  app_name       = "${var.prefix}-app"
  chart_name     = "${var.prefix}-chart"
  chart_repo_url = "registry.gitlab.com/jerrybai/${local.project_name}"
}

variable "argocd_ns" {
  type        = string
  description = "Argo CD Namespace"
}

variable "app_ns" {
  type        = string
  description = "Kubernetes Namespace for the Application"
}
