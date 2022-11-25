output "warehouse_names" {
  value = [
    for wh in module.sf_warehouse : wh.name
  ]
}

output "database_names" {
  value = [
    for db in snowflake_database.database : db.name
  ]
}

output "warehouse_grants" {
  value = [
    for grant in snowflake_warehouse_grant.warehouse : grant.id
  ]
}

output "database_grants" {
  value = [
    for grant in snowflake_database_grant.database : grant.id
  ]
}

output "schema_grants" {
  value = [
    for grant in snowflake_schema_grant.schema : grant.id
  ]
}

output "table_grants" {
  value = [
    for grant in snowflake_table_grant.table : grant.id
  ]
}

output "view_grants" {
  value = [
    for grant in snowflake_view_grant.view : grant.id
  ]
}

output "role_grants" {
  value = [
    for grant in snowflake_role_grants.role : grant.id
  ]
}