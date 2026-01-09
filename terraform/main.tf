# 调用 cloud-sql 模块
module "cloud-sql" {
  source = "./cloud-sql"

  # 传递根模块的变量
  prefix               = var.prefix
  project_id           = var.project_id
  region               = var.region
  mysql_root_password  = var.mysql_root_password
  mysql_jerry_password = var.mysql_jerry_password
}

# 调用 gke 模块
module "gke" {
  source = "./gke"

  # 传递根模块的变量
  prefix     = var.prefix
  project_id = var.project_id
  region     = var.region
}

# 调用 argocd 模块
module "argocd" {
  source     = "./argocd"
  depends_on = [module.gke]

  # 传递根模块的变量
  my_external_ip = var.my_external_ip
}

# 调用 todo-app 模块
module "todo-app" {
  source = "./todo-app"
  depends_on = [
    module.argocd,
    module.cloud-sql
  ]

  # 传递其它模块的输出
  argocd_ns = module.argocd.argocd_ns
  app_ns    = module.gke.app_ns

  # 传递根模块的变量
  prefix = var.prefix
}
