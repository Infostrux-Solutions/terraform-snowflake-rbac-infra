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
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])

  table_grants_wo_ownership = distinct(flatten([
    for database, grants in local.tables : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = sort([for p in setsubtract(privilege, ["ownership"]) : upper(p)])
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ]))
}

resource "snowflake_grant_privileges_to_account_role" "future_tables" {
  for_each = {
    for uni in local.table_grants_wo_ownership : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_ownership.tables]

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "all_tables" {
  for_each = {
    for uni in local.table_grants_wo_ownership : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_ownership.tables]

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}

resource "snowflake_grant_ownership" "tables" {
  for_each = {
    for uni in local.table_grants : uni.unique => uni if contains(uni.privilege, "ownership")
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_account_role.role]

  account_role_name   = each.value.role
  outbound_privileges = "REVOKE"
  on {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}
