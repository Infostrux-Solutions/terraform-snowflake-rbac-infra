output "databases" {
  value = [
    for database in snowflake_database.database : database.name
  ]
}

output "warehouses" {
  value = [
    for warehouse in snowflake_warehouse.warehouse : warehouse.name
  ]
}

output "environment_roles" {
  value = [
    for role in snowflake_role.environment_role : role.name
  ]
}

output "environment_role_grants" {
  value = [
    for role in snowflake_grant_account_role.environment_role : join("", [role.role_name, " ▶ ", role.parent_role_name])
  ]
}

output "account_roles" {
  value = [
    for role in snowflake_role.account_role : role.name
  ]
}

output "account_role_grants" {
  value = [
    for role in snowflake_grant_account_role.account_role : join("", [role.role_name, " ▶ ", role.parent_role_name])
  ]
}
