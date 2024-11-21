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

output "functional_roles" {
  value = [
    for role in snowflake_role.functional_role : role.name
  ]
}

output "functional_role_grants" {
  value = [
    for role in snowflake_grant_account_role.functional_role : join("", [role.role_name, " ▶ ", role.parent_role_name])
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

output "object_roles" {
  value = [
    for role in snowflake_role.object_role : role.name
  ]
}

output "users" {
  value = [
    for user in snowflake_user.user : user.login_name
  ]
}
