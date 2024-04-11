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
        role      = role
      }
    ]
  ])

  database_grants_wo_ownership = flatten([
    for database, grants in local.databases : [
      for role, privilege in grants : {
        unique    = join("_", [databases, trimspace(role)])
        database  = database
        privilege = setsubtract(privilege, ["ownership"])
        role      = role
      }
    ]
  ])
}

resource "snowflake_database" "database" {
  for_each = local.databases

  name    = upper(join("_", [var.customer, var.environment, each.key]))
  comment = "created by terraform"
}

resource "snowflake_grant_privileges_to_account_role" "database" {
  for_each = {
    for uni in local.database_grants_wo_ownership : uni.unique => uni
  }

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

  account_role_name = each.value.role
  on {
    object_type = "DATABASE"
    object_name = snowflake_database.database[each.value.database].id
  }
}
