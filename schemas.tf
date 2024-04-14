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
        role      = upper(join("_", [local.object_prefix, role]))
      }
    ]
  ])

  schema_grants_wo_ownership = distinct(flatten([
    for database, grants in local.schemas : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = sort([for p in setsubtract(privilege, ["ownership"]) : upper(p)])
        role      = upper(join("_", [local.object_prefix, role]))
      }
    ]
  ]))
}

resource "snowflake_grant_privileges_to_account_role" "future_schemas" {
  for_each = {
    for uni in local.schema_grants_wo_ownership : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_ownership.views]

  account_role_name = each.value.role
  privileges        = each.value.privilege
  always_apply      = var.always_apply
  on_schema {
    future_schemas_in_database = snowflake_database.database[each.value.database].id
  }
}

resource "snowflake_grant_privileges_to_account_role" "all_schemas" {
  for_each = {
    for uni in local.schema_grants_wo_ownership : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_ownership.views]

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema {
    all_schemas_in_database = snowflake_database.database[each.value.database].id
  }
}

resource "snowflake_grant_ownership" "schemas" {
  for_each = {
    for uni in local.schema_grants : uni.unique => uni if contains(uni.privilege, "ownership")
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_account_role.role]

  account_role_name   = each.value.role
  outbound_privileges = "REVOKE"
  on {
    future {
      object_type_plural = "SCHEMAS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}
