locals {
  database_yml = yamldecode(file("config/databases.yml"))

  databases = {
    for database, grants in local.database_yml.databases : database => grants
  }

  database_grants = flatten([
    for database, grants in local.databases : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = privilege
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])

  database_grants_wo_ownership = flatten([
    for database, grants in local.databases : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = sort([for p in setsubtract(privilege, ["ownership"]) : upper(p)])
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])
}

resource "snowflake_database" "database" {
  for_each = local.databases

  name    = upper(join("_", [var.customer, var.environment, each.key]))
  comment = "created by terraform"

  depends_on = [snowflake_grant_account_role.role]
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

  provider = snowflake.securityadmin

  account_role_name   = each.value.role
  outbound_privileges = "REVOKE"
  on {
    object_type = "DATABASE"
    object_name = snowflake_database.database[each.value.database].id
  }

  depends_on = [snowflake_grant_account_role.role]
}
