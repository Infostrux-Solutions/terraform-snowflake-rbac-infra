locals {
  views_role_list = flatten([
    for stage, perm in var.views_and_roles : [
      for perm, roles_opt in perm : {
        unique       = upper(join("_", [stage, trimspace(perm)]))
        stage        = stage
        perm         = perm
        grant_option = try(roles_opt["WITH_GRANT_OPTION"], true)
        on_future    = try(roles_opt["ON_FUTURE"], true)
        role = tolist([
          for role in try(roles_opt["ROLES"], roles_opt) :
          upper(join("_", [var.customer, var.environment, role]))
        ])
      }
    ]
  ])
}

resource "snowflake_view_grant" "view" {
  for_each = {
    for uni in local.views_role_list : uni.unique => uni
  }

  provider = snowflake.tag_securityadmin

  database_name = snowflake_database.database[each.value.stage].id

  privilege = each.value.perm
  roles     = each.value.role

  on_future         = each.value.on_future
  with_grant_option = each.value.grant_option
}
