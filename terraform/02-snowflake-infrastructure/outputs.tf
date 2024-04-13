output "database_names" {
  value = [
    for database in snowflake_database.database : database.name
  ]
}

output "warehouse_names" {
  value = [
    for warehouse in snowflake_warehouse.warehouse : warehouse.name
  ]
}

output "role_grants" {
  value = [
    for role in snowflake_grant_account_role.role : join("", [role.role_name, " ▶ ", role.parent_role_name])
  ]
}