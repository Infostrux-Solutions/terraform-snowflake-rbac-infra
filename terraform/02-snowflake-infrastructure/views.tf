locals {
  view_yml = yamldecode(file("config/views.yml"))

  views = {
    for database, grants in local.view_yml.views : database => grants
  }

  view_grants = flatten([
    for database, grants in local.views : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = privilege
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])

  view_grants_wo_ownership = flatten([
    for database, grants in local.views : [
      for role, privilege in grants : {
        unique    = join("_", [database, trimspace(role)])
        database  = database
        privilege = sort(setsubtract(privilege, ["ownership"]))
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])
}

resource "snowflake_grant_privileges_to_account_role" "views" {
  for_each = {
    for uni in local.view_grants_wo_ownership : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}
/*
resource "snowflake_grant_ownership" "views" {
  for_each = {
    for uni in local.view_grants : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name   = each.value.role
  outbound_privileges = "REVOKE"
  on {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}
*/