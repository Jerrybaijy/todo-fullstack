output "cluster_endpoint" {
  value = google_container_cluster.my_cluster.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate
}

# 用于传递给 argocd 模块
output "workload_identity_gsa_email" {
  description = "Workload Identity GSA email"
  value       = google_service_account.workload_identity.email
  sensitive   = false
}

# 用于传递给 argocd 模块
output "app_ns" {
  description = "Kubernetes Namespace Name"
  value       = kubernetes_namespace_v1.app_ns.metadata[0].name
}

output "ksa_name" {
  description = "Kubernetes Service Account Name"
  value       = kubernetes_service_account_v1.my_ksa.metadata[0].name
}

output "gke_name" {
  description = "GKE name"
  value       = google_container_cluster.my_cluster.name
}
