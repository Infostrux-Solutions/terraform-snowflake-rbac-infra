locals {
  table_yml = yamldecode(file("config/tables.yml"))

  tables = {
    for database, grants in local.table_yml.tables : database => grants
  }

  table_grants = flatten([
    for database, grants in local.tables : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = privilege
        role      = role
      }
    ]
  ])

  table_grants_wo_ownership = flatten([
    for database, grants in local.tables : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = setsubtract(privilege, ["ownership"])
        role      = role
      }
    ]
  ])
}

resource "snowflake_grant_privileges_to_account_role" "dynamic_tables" {
  for_each = {
    for uni in local.table_grants_wo_ownership : uni.unique => uni
  }

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}

resource "snowflake_grant_ownership" "dynamic_tables" {
  for_each = {
    for uni in local.table_grants : uni.unique => uni
  }

  account_role_name = each.value.role
  on {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}