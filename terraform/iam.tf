# 获取当前 Project ID
data "google_project" "project" {}

# 创建 GSA
resource "google_service_account" "workload_identity" {
  account_id   = local.sa_id
  display_name = "GSA for Workload Identity"
}

# 为 GSA 分配 Cloud SQL Client 角色
resource "google_project_iam_member" "gsa_roles" {
  for_each = toset([
    "roles/cloudsql.client", # Cloud SQL Client
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}

# 创建 app_ns，防止因 app_ns 不存在而导致创建 KSA 失败
resource "kubernetes_namespace_v1" "app_ns" {
  metadata {
    name = local.app_ns
    annotations = {
      # 加注解，防止 Argo CD 删除该 Namespace
      "argocd.argoproj.io/sync-options" = "Delete=false"
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels # 忽略标签变化，防止 Argo CD 标签变更引起冲突
    ]
  }
}

# 创建 KSA，并绑定到 GSA
resource "kubernetes_service_account_v1" "my_ksa" {
  metadata {
    name      = local.ksa_name
    namespace = kubernetes_namespace_v1.app_ns.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.workload_identity.email
      # 加注解，防止 Argo CD 删除该 KSA
      "argocd.argoproj.io/sync-options" = "Delete=false"
    }
  }
}

# 允许 KSA 以 GSA 身份运行
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.workload_identity.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[${local.app_ns}/${local.ksa_name}]"
}

output "app_namespace" {
  description = "Kubernetes Namespace Name"
  value       = kubernetes_namespace_v1.app_ns.metadata[0].name
}

output "ksa_name" {
  description = "Kubernetes Service Account Name"
  value       = kubernetes_service_account_v1.my_ksa.metadata[0].name
}
