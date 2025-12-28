# 获取当前 Project ID
data "google_project" "project" {}

# 创建 GSA
resource "google_service_account" "workload_identity" {
  account_id   = local.sa_id
  display_name = "GSA for Workload Identity"
}

# 创建 namespace，防止因 namespace 不存在而导致创建 IAM 失败
resource "kubernetes_namespace_v1" "app_ns" {
  metadata {
    name = local.app_ns
  }
}

# 创建 KSA，并绑定到 GSA
resource "kubernetes_service_account_v1" "my_ksa" {
  metadata {
    name      = local.ksa_name
    namespace = kubernetes_namespace_v1.app_ns.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.workload_identity.email
    }
  }
}

# 允许 KSA 以 GSA 身份运行
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.workload_identity.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[${local.app_ns}/${local.ksa_name}]"
}

# 允许 GSA 访问 Cloud SQL
resource "google_project_iam_member" "mysql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}
