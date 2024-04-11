locals {
  view_yml = yamldecode(file("config/views.yml"))

  views = {
    for view, grants in local.view_yml.views : view => grants
  }

  view_grants = flatten([
    for view, grants in local.views : [
      for role, privilege in grants : {
        unique    = join("_", [view, trimspace(role)])
        view      = view
        privilege = privilege
        role      = role
      }
    ]
  ])

  view_grants_wo_ownership = flatten([
    for view, grants in local.views : [
      for role, privilege in grants : {
        unique    = join("_", [views, trimspace(role)])
        view      = view
        privilege = setsubtract(privilege, ["ownership"])
        role      = role
      }
    ]
  ])
}

resource "snowflake_grant_privileges_to_account_role" "dynamic_views" {
  for_each = {
    for uni in local.view_grants_wo_ownership : uni.unique => uni
  }

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}

resource "snowflake_grant_ownership" "dynamic_views" {
  for_each = {
    for uni in local.view_grants : uni.unique => uni
  }

  account_role_name = each.value.role
  on {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.database[each.value.database].id
    }
  }
}