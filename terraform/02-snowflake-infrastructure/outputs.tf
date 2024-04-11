output "database_names" {
  value = [
    for db in snowflake_database.database : db.name
  ]
}