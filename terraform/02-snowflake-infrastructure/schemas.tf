locals {
  schema_yml = yamldecode(file("config/schemas.yml"))

  schemas = {
    for database, grants in local.schema_yml.schemas : database => grants
  }

  schema_grants = flatten([
    for database, grants in local.schemas : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = privilege
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])

  schema_grants_wo_ownership = flatten([
    for database, grants in local.schemas : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = sort(setsubtract(privilege, ["ownership"]))
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])
}

resource "snowflake_grant_privileges_to_account_role" "schema" {
  for_each = {
    for uni in local.schema_grants_wo_ownership : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema {
    future_schemas_in_database = snowflake_database.database[each.value.database].id
  }
}
/*
resource "snowflake_grant_ownership" "schema" {
  for_each = {
    for uni in local.database_grants : uni.unique => uni if contains(uni.privilege, "ownership")
  }

  provider = snowflake.securityadmin

  account_role_name   = each.value.role
  outbound_privileges = "REVOKE"
  on {
    future {
      object_type_plural = "SCHEMAS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}
*/