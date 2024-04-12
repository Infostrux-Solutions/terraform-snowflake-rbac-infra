resource "snowflake_grant_privileges_to_account_role" "tag_admin_usage" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_role.tag_admin[0].name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.tags[0].name
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_secadmin_usage" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_role.tag_securityadmin[0].name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.tags[0].name
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_admin_usage_create" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_role.tag_admin[0].name
  privileges        = ["USAGE", "CREATE TAG"]

  on_schema {
    schema_name = "\"${snowflake_database.tags[0].name}\".\"${snowflake_schema.tags[0].name}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_secadmin_usage_create" {
  provider = snowflake.securityadmin

  account_role_name = snowflake_role.tag_securityadmin[0].name
  privileges        = ["USAGE", "CREATE TAG"]

  on_schema {
    schema_name = "\"${snowflake_database.tags[0].name}\".\"${snowflake_schema.tags[0].name}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_admin_apply" {
  provider = snowflake.accountadmin

  privileges        = ["APPLY TAG"]
  account_role_name = snowflake_role.tag_admin[0].name
  on_account        = true
}

resource "snowflake_grant_privileges_to_account_role" "tag_secadmin_apply" {
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

resource "snowflake_grant_account_role" "tag_secadmin" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  role_name        = snowflake_role.tag_securityadmin[0].name
  parent_role_name = "SECURITYADMIN"
}

resource "snowflake_grant_privileges_to_account_role" "tag_secadmin_exec" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.accountadmin

  privileges        = ["EXECUTE TASK"]
  account_role_name = "SYSADMIN"
  on_account        = true
}