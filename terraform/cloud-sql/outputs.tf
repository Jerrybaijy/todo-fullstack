output "cloud_sql_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.mysql_instance.connection_name
}

output "sql_instance_name" {
  description = "Cloud SQL 实例的名称"
  value       = google_sql_database_instance.mysql_instance.name
}

output "database_name" {
  description = "Cloud SQL database name"
  value       = google_sql_database.my_db.name
}