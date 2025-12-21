# 定义 Provider 和项目信息
provider "google" {
  project = var.project_id
  region  = var.region
}