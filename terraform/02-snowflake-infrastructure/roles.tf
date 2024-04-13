locals {
  roles_yml = yamldecode(file("config/roles.yml"))

  roles = {
    for role, roles in local.roles_yml.roles : role => roles
  }

  role_grants = flatten([
    for role, parents in local.roles : [
      for parent in parents : {
        unique = join("_", [role, parent])
        role   = upper(join("_", [local.object_prefix, role]))
        parent = upper(parent)
      }
    ]
  ])
}

resource "snowflake_grant_account_role" "role" {
  for_each = {
    for uni in local.role_grants : uni.unique => uni
  }

  provider = snowflake.securityadmin

  role_name        = each.value.role
  parent_role_name = each.value.parent
}

resource "snowflake_grant_account_role" "fivetran" {
  count = var.create_fivetran_user ? 1 : 0

  provider = snowflake.securityadmin

  role_name = upper(join("_", [local.object_prefix, "INGESTION"]))
  user_name = snowflake_user.fivetran[0].name
}

resource "snowflake_grant_account_role" "datadog" {
  count = var.create_datadog_user ? 1 : 0

  provider = snowflake.securityadmin

  role_name = upper(join("_", [local.object_prefix, "MONITORING"]))
  user_name = snowflake_user.datadog[0].name
}
