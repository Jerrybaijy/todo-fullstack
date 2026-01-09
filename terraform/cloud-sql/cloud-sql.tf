# 创建 Cloud SQL 实例
resource "google_sql_database_instance" "mysql_instance" {
  name             = local.db_instance
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier            = "db-f1-micro" # 测试环境使用的最小规格
    disk_type       = "PD_SSD"
    disk_size       = 10   # 初始 10GB
    disk_autoresize = true # 自动扩容

    # 开启公网 IP，但会通过 IAM 权限锁定访问，仅允许通过授权代理访问
    ip_configuration {
      ipv4_enabled = true
    }
  }

  # 关闭误删保护（生产环境不应设置此参数）
  deletion_protection = false
}

# 创建 DATABASE
resource "google_sql_database" "my_db" {
  name      = local.db_name
  instance  = google_sql_database_instance.mysql_instance.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# 创建 root 用户
resource "google_sql_user" "root_user" {
  name     = "root"
  instance = google_sql_database_instance.mysql_instance.name
  password = var.mysql_root_password
  host     = "%"
}

# 创建普通账户
resource "google_sql_user" "jerry_user" {
  name     = "jerry"
  instance = google_sql_database_instance.mysql_instance.name
  password = var.mysql_jerry_password
  host     = "%"
}
