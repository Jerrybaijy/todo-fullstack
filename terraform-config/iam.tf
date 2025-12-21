# --- 权限配置 (Workload Identity 绑定) ---

# 创建一个专门给 Pod 用的 GCP 服务账号
resource "google_service_account" "sql_proxy_sa" {
  account_id   = "sql-proxy-sa"
  display_name = "Service Account for SQL Auth Proxy"
}

# 给该账号授予 Cloud SQL Client 权限
resource "google_project_iam_member" "sql_client_role" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.sql_proxy_sa.email}"
}

# 允许 K8s 服务账号使用该 GCP 服务账号
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.sql_proxy_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[todo/todo-k8s-sa]"
}