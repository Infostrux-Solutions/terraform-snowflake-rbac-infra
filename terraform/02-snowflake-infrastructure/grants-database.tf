locals {
  dbs_role_list = flatten([
    for stage, perm in var.dbs_and_roles : [
      for perm, roles_opt in perm : {
        unique       = upper(join("_", [stage, trimspace(perm)]))
        stage        = stage
        perm         = perm
        grant_option = try(roles_opt["WITH_GRANT_OPTION"], true)
        role = tolist([
          for role in try(roles_opt["ROLES"], roles_opt) :
          upper(join("_", [var.customer, var.environment, role]))
        ])
      }
    ]
  ])
}

resource "snowflake_database_grant" "database" {
  for_each = {
    for uni in local.dbs_role_list : uni.unique => uni
  }

  provider = snowflake.tag_securityadmin

  database_name = snowflake_database.database[each.value.stage].id

  privilege = each.value.perm
  roles     = each.value.role

  with_grant_option = each.value.grant_option
}

resource "snowflake_database_grant" "datadog_imported_privileges" {
  database_name = "SNOWFLAKE"

  privilege = "IMPORTED PRIVILEGES"
  roles     = [upper(join("_", [var.customer, var.environment, "MONITORING"]))]
}
