locals {
  databases = {
    for database, grants in local.database_yml.databases : database => grants
  }

  database_ownership = flatten([
    for database, grants in local.databases : [
      for role in grants.roles : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        role      = upper(join("_", [local.object_prefix, database, role]))
        privilege = sort([for p in setintersection(local.permissions_yml.permissions.database[role].databases, ["ownership"]) : upper(p)])
      } if contains(local.permissions_yml.permissions.database[role].databases, "ownership")
    ]
  ])

  database_grants_wo_ownership = flatten([
    for database, grants in local.databases : [
      for role in grants.roles : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        role      = upper(join("_", [local.object_prefix, database, role]))
        privilege = sort([for p in setsubtract(local.permissions_yml.permissions.database[role].databases, ["ownership"]) : upper(p)])
      }
    ]
  ])
}

resource "snowflake_database" "database" {
  for_each   = local.databases
  depends_on = [snowflake_grant_account_role.environment_role, snowflake_role.environment_role, snowflake_role.account_role, snowflake_role.access_role]

  name    = upper(join("_", [local.object_prefix, each.key]))
  comment = var.comment
}

resource "snowflake_grant_privileges_to_account_role" "database" {
  for_each = {
    for uni in local.database_grants_wo_ownership : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.database[each.value.database].id
  }
}

resource "snowflake_grant_ownership" "database" {
  for_each = {
    for uni in local.database_ownership : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  on {
    object_type = "DATABASE"
    object_name = snowflake_database.database[each.value.database].id
  }
}

resource "snowflake_grant_privileges_to_account_role" "snowflake_datadog" {
  count             = var.create_datadog_user ? 1 : 0
  account_role_name = snowflake_role.account_role["monitoring"].name
  privileges        = ["IMPORTED PRIVILEGES"]
  on_account_object {
    object_type = "DATABASE"
    object_name = "SNOWFLAKE"
  }
}