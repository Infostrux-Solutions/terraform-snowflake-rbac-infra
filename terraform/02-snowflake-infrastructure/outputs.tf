output "database_names" {
  value = [
    for db in snowflake_database.database : db.name
  ]
}

output "warehouse_names" {
  value = [
    for wh in snowflake_warehouse.warehouse : wh.name
  ]
}