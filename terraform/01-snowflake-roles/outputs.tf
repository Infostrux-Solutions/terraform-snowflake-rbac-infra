output "roles" {
  value = [
    for role in snowflake_role.roles : role.name
  ]
}

output "parent_roles" {
  value = [
    for role in snowflake_role.parent_roles : role.name
  ]
}