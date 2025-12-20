# 1. 定义 Provider 和项目信息
provider "google" {
  project = var.project_id
  region  = var.region
}

# --- GKE 集群配置 ---

resource "google_container_cluster" "todo_cluster" {
  name     = "todo-cluster"
  location = var.zone # 使用 Region 实现高可用，或者改为 asia-east2-a 指定 Zone

  # 我们在这里删除默认节点池，并创建一个独立的节点池
  remove_default_node_pool = true
  initial_node_count       = 1

  # 启用 Workload Identity，这是安全连接的关键
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "todo-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.todo_cluster.name
  node_count = 2 # 对应 --num-nodes=2

  autoscaling {
    min_node_count = 1 # 对应 --min-nodes=1
    max_node_count = 5 # 对应 --max-nodes=5
  }

  node_config {
    machine_type = "e2-medium"   # 对应 --machine-type
    disk_type    = "pd-standard" # 对应 --disk-type
    disk_size_gb = 40            # 对应 --disk-size=40

    # 启用 GKE 节点的 Workload Identity 
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # 对应 --scopes=cloud-platform
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # 指定特定可用区 (对应 --node-locations=asia-east2-a)
    # 注意：如果 cluster location 是 region，通常不需要手动指定，GCP 会自动分配
  }
}

# --- Cloud SQL 配置 (移除 IP 白名单) ---

resource "google_sql_database_instance" "todo_db_instance" {
  name             = "todo-db-instance"
  database_version = "MYSQL_8_0" # 对应 --database-version
  region           = var.region

  settings {
    tier            = "db-n1-standard-2" # 对应 --tier
    disk_autoresize = true               # 对应 --storage-auto-increase
    disk_type       = "PD_SSD"
    disk_size       = 10 # 对应 --storage-size=10GB

    ip_configuration {
      ipv4_enabled = true # 启用公网 IP

      # 注意：这里我们移除了 authorized_networks 块
      # 即使 IP 变化，Auth Proxy 也能通过内部加密隧道连接
    }
  }

  # 防止误删（生产环境建议开启）
  deletion_protection = false
}

# 创建数据库 (对应 CREATE DATABASE todo_db)
resource "google_sql_database" "todo_db" {
  name      = "todo_db"
  instance  = google_sql_database_instance.todo_db_instance.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# 创建 root 用户密码 (对应 gcloud sql users set-password)
resource "google_sql_user" "root_user" {
  name     = "root"
  instance = google_sql_database_instance.todo_db_instance.name
  password = "123456"
  host     = "%"
}

# 创建应用用户 jerry (对应 CREATE USER 'jerry')
resource "google_sql_user" "jerry_user" {
  name     = "jerry"
  instance = google_sql_database_instance.todo_db_instance.name
  password = "000000"
  host     = "%"
}

# --- 权限配置 (Workload Identity 绑定) ---

# 1. 创建一个专门给 Pod 用的 GCP 服务账号
resource "google_service_account" "sql_proxy_sa" {
  account_id   = "sql-proxy-sa"
  display_name = "Service Account for SQL Auth Proxy"
}

# 2. 给该账号授予 Cloud SQL Client 权限
resource "google_project_iam_member" "sql_client_role" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.sql_proxy_sa.email}"
}

# 3. 允许 K8s 服务账号使用该 GCP 服务账号
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.sql_proxy_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[todo/todo-k8s-sa]"
}
