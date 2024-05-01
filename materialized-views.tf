locals {
  materialized_view_grants = flatten([
    for database, grants in local.databases : [
      for role in grants.roles : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        role      = upper(join("_", [local.object_prefix, database, role]))
        privilege = sort([for p in setintersection(local.permissions_yml.permissions.database[role].materialized_views, ["ownership"]) : upper(p)])
      }
    ]
  ])

  materialized_view_grants_wo_ownership = flatten([
    for database, grants in local.databases : [
      for role in grants.roles : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        role      = upper(join("_", [local.object_prefix, database, role]))
        privilege = sort([for p in setsubtract(local.permissions_yml.permissions.database[role].materialized_views, ["ownership"]) : upper(p)])
      }
    ]
  ])
}

resource "snowflake_grant_privileges_to_account_role" "future_materialized_views" {
  for_each = {
    for uni in local.materialized_view_grants_wo_ownership : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema_object {
    future {
      object_type_plural = "MATERIALIZED VIEWS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "all_materialized_views" {
  for_each = {
    for uni in local.materialized_view_grants_wo_ownership : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  privileges        = each.value.privilege
  always_apply      = var.always_apply
  on_schema_object {
    all {
      object_type_plural = "MATERIALIZED VIEWS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}

resource "snowflake_grant_ownership" "materialized_views" {
  for_each = {
    for uni in local.materialized_view_grants : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name   = each.value.role
  outbound_privileges = "REVOKE"
  on {
    future {
      object_type_plural = "MATERIALIZED VIEWS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}