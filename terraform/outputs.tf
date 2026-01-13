output "outputs" {
  value = {
    argocd_loadbalancer_ip    = module.argocd.argocd_loadbalancer_ip
    cloud_sql_connection_name = module.cloud-sql.cloud_sql_connection_name
    sql_instance_name         = module.cloud-sql.sql_instance_name
    database_name             = module.cloud-sql.database_name
    ksa_name                  = module.gke.ksa_name
    gke_name                  = module.gke.gke_name
  }
}

output "sensitive_outputs" {
  value = {
    argocd_initial_admin_password = module.argocd.argocd_initial_admin_password
  }
  sensitive = true
}
