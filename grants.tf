locals {
  environment_role_grants = flatten([
    for parent, children in local.environment_roles : [
      for child in children : {
        unique = join("_", [parent, child])
        parent = upper(join("_", [local.object_prefix, parent]))
        child  = upper(join("_", [local.object_prefix, child]))
      }
    ]
  ])

  account_role_grants = flatten([
    for parent, children in local.account_roles : [
      for child in children : {
        unique = join("_", [parent, child])
        parent = upper(parent)
        child  = upper(join("_", [local.object_prefix, child]))
      }
    ]
  ])
}

resource "snowflake_grant_account_role" "environment_role" {
  for_each = {
    for uni in local.environment_role_grants : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_role.environment_role, snowflake_role.account_role]

  role_name        = each.value.child
  parent_role_name = each.value.parent
}

resource "snowflake_grant_account_role" "account_role" {
  for_each = {
    for uni in local.account_role_grants : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_role.environment_role, snowflake_role.account_role]

  role_name        = each.value.child
  parent_role_name = each.value.parent
}

resource "snowflake_grant_account_role" "fivetran" {
  count = var.create_fivetran_user ? 1 : 0

  provider = snowflake.securityadmin

  role_name = snowflake_role.environment_role["ingestion"].name
  user_name = snowflake_user.fivetran[0].name
}

resource "snowflake_grant_account_role" "datadog" {
  count = var.create_datadog_user ? 1 : 0

  provider   = snowflake.securityadmin
  depends_on = [snowflake_role.environment_role]

  role_name = snowflake_role.environment_role["monitoring"].name
  user_name = snowflake_user.datadog[0].name
}

resource "snowflake_grant_privileges_to_account_role" "tag_database" {
  provider = snowflake.securityadmin

  account_role_name = try(snowflake_role.tag_admin[0].name, "TAG_ADMIN")
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = try(snowflake_database.tags[0].name, var.governance_database_name)
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_schema" {
  count = length(var.tags) > 0 ? 1 : 0
  provider = snowflake.securityadmin

  account_role_name = try(snowflake_role.tag_admin[0].name, "TAG_ADMIN")
  privileges        = ["USAGE", "CREATE TAG"]

  on_schema {
    schema_name = "\"${try(snowflake_database.tags[0].name, var.governance_database_name)}\".\"${try(snowflake_schema.tags[0].name, var.tags_schema_name)}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_admin" {
  count = length(var.tags) > 0 ? 1 : 0
  provider = snowflake.accountadmin

  privileges        = ["APPLY TAG"]
  account_role_name = try(snowflake_role.tag_admin[0].name, "TAG_ADMIN")
  on_account        = true
}

resource "snowflake_grant_account_role" "tag_admin" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  role_name        = try(snowflake_role.tag_admin[0].name, "TAG_ADMIN")
  parent_role_name = "SYSADMIN"
}
