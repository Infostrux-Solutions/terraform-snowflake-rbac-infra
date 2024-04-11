locals {
  roles_yml = yamldecode(file("config/roles.yml"))

  roles = {
    for role, roles in local.roles_yml.roles : role => roles
  }

  role_grants = flatten([
    for role, parents in local.roles : [
      for parent in parents : {
        unique = join("_", [role, parent])
        role   = role
        parent = parent
      }
    ]
  ])
}

resource "snowflake_grant_account_role" "role" {
  for_each = {
    for uni in local.role_grants : uni.unique => uni
  }

  provider = snowflake.tag_securityadmin

  role_name        = each.value.role
  parent_role_name = each.value.parent
}

resource "snowflake_role_grants" "fivetran" {
  count = var.create_fivetran_user ? 1 : 0

  provider = snowflake.tag_securityadmin

  role_name = upper(join("_", [var.customer, var.environment, "INGESTION"]))
  users     = [snowflake_user.fivetran[0].name]

  enable_multiple_grants = true
}

resource "snowflake_role_grants" "datadog" {
  count = var.create_datadog_user ? 1 : 0

  provider = snowflake.tag_securityadmin

  role_name = upper(join("_", [var.customer, var.environment, "MONITORING"]))
  users     = [snowflake_user.datadog[0].name]

  enable_multiple_grants = true
}
