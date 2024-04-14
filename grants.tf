locals {
  roles_yml = yamldecode(file("config/roles.yml"))

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

  provider   = snowflake.securityadmin
  depends_on = [snowflake_role.roles, snowflake_role.parent_roles]

  role_name        = each.value.role
  parent_role_name = each.value.parent
}

resource "snowflake_grant_privileges_to_account_role" "tag_admin_usage" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_role.tag_admin[0].name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = try(snowflake_database.tags[0].name, var.governance_database_name)
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_securityadmin_usage" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_role.tag_securityadmin[0].name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = try(snowflake_database.tags[0].name, var.governance_database_name)
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_admin_usage_create" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_role.tag_admin[0].name
  privileges        = ["USAGE", "CREATE TAG"]

  on_schema {
    schema_name = "\"${try(snowflake_database.tags[0].name, var.governance_database_name)}\".\"${try(snowflake_schema.tags[0].name, var.tags_schema_name)}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_securityadmin_usage_create" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_role.tag_securityadmin[0].name
  privileges        = ["USAGE", "CREATE TAG"]

  on_schema {
    schema_name = "\"${try(snowflake_database.tags[0].name, var.governance_database_name)}\".\"${try(snowflake_schema.tags[0].name, var.tags_schema_name)}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_admin_apply" {
  provider = snowflake.accountadmin

  privileges        = ["APPLY TAG"]
  account_role_name = snowflake_role.tag_admin[0].name
  on_account        = true
}

resource "snowflake_grant_privileges_to_account_role" "tag_securityadmin_apply" {
  provider = snowflake.accountadmin

  privileges        = ["APPLY TAG"]
  account_role_name = snowflake_role.tag_securityadmin[0].name
  on_account        = true
}

resource "snowflake_grant_account_role" "tag_admin" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  role_name        = snowflake_role.tag_admin[0].name
  parent_role_name = "SYSADMIN"
}

resource "snowflake_grant_account_role" "tag_securityadmin" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  role_name        = snowflake_role.tag_securityadmin[0].name
  parent_role_name = "SECURITYADMIN"
}