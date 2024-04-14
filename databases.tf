locals {
  object_prefix = join("_", [var.customer, var.environment])
  database_yml  = yamldecode(file("config/databases.yml"))

  databases = {
    for database, grants in local.database_yml.databases : database => grants
  }

  database_grants = flatten([
    for database, grants in local.databases : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = privilege
        role      = upper(join("_", [local.object_prefix, role]))
      }
    ]
  ])

  database_grants_wo_ownership = flatten([
    for database, grants in local.databases : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = sort([for p in setsubtract(privilege, ["ownership"]) : upper(p)])
        role      = upper(join("_", [local.object_prefix, role]))
      }
    ]
  ])
}

resource "snowflake_database" "database" {
  for_each   = local.databases
  depends_on = [snowflake_grant_account_role.role, snowflake_role.roles, snowflake_role.parent_roles]

  name    = upper(join("_", [local.object_prefix, each.key]))
  comment = var.comment
}

resource "snowflake_grant_privileges_to_account_role" "database" {
  for_each = {
    for uni in local.database_grants_wo_ownership : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_account_role.role, snowflake_grant_ownership.database]

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.database[each.value.database].id
  }
}

resource "snowflake_grant_ownership" "database" {
  for_each = {
    for uni in local.database_grants : uni.unique => uni if contains(uni.privilege, "ownership")
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_account_role.role]

  account_role_name = each.value.role
  on {
    object_type = "DATABASE"
    object_name = snowflake_database.database[each.value.database].id
  }
}