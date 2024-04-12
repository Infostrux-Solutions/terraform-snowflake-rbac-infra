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

output "grants_debug" {
  value = local.warehouse_grants_wo_ownership
}