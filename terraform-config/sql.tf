# --- Cloud SQL 配置 ---

# 创建 Cloud SQL 实例
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
    }
  }

  # 关闭防止误删（生产环境建议开启）
  deletion_protection = false
}

# 创建 DATABASE
resource "google_sql_database" "todo_db" {
  name      = "todo_db"
  instance  = google_sql_database_instance.todo_db_instance.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# 创建 root 用户密码
resource "google_sql_user" "root_user" {
  name     = "root"
  instance = google_sql_database_instance.todo_db_instance.name
  password = "123456"
  host     = "%"
}

# 创建普通用户 jerry
resource "google_sql_user" "jerry_user" {
  name     = "jerry"
  instance = google_sql_database_instance.todo_db_instance.name
  password = "000000"
  host     = "%"
}
