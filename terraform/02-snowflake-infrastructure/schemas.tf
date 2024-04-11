locals {
  schema_yml = yamldecode(file("config/schemas.yml"))

  schemas = {
    for schema, grants in local.schema_yml.schemas : schema => grants
  }

  schema_grants = flatten([
    for schema, grants in local.schemas : [
      for role, privilege in grants : {
        unique    = join("_", [schema, trimspace(role)])
        schema    = schema
        privilege = privilege
        role      = role
      }
    ]
  ])

  schema_grants_wo_ownership = flatten([
    for schema, grants in local.schemas : [
      for role, privilege in grants : {
        unique    = join("_", [schemas, trimspace(role)])
        schema    = schema
        privilege = setsubtract(privilege, ["ownership"])
        role      = role
      }
    ]
  ])
}

resource "snowflake_grant_privileges_to_account_role" "schema" {
  for_each = {
    for uni in local.schema_grants_wo_ownership : uni.unique => uni
  }

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema {
    future_schemas_in_database = snowflake_database.database[each.value.database].id
  }
}

resource "snowflake_grant_ownership" "schema" {
  for_each = {
    for uni in local.database_grants : uni.unique => uni if contains(uni.privilege, "ownership")
  }

  account_role_name = each.value.role
  on {
    future {
      object_type_plural = "SCHEMAS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}
