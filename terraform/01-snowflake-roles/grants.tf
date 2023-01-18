resource "snowflake_database_grant" "tag_admin_usage" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  database_name = snowflake_database.tags[0].name

  privilege = "USAGE"
  roles     = [snowflake_role.tag_admin[0].name, snowflake_role.tag_securityadmin[0].name]

  with_grant_option = true
}

resource "snowflake_schema_grant" "tag_admin_usage" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  database_name = snowflake_database.tags[0].name
  schema_name   = snowflake_schema.tags[0].name

  privilege = "USAGE"
  roles     = [snowflake_role.tag_admin[0].name, snowflake_role.tag_securityadmin[0].name]

  with_grant_option = true
}

resource "snowflake_schema_grant" "tag_admin_create_tag" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  database_name = snowflake_database.tags[0].name
  schema_name   = snowflake_schema.tags[0].name

  privilege = "CREATE TAG"
  roles     = [snowflake_role.tag_admin[0].name]

  with_grant_option = true
}

resource "snowflake_account_grant" "tag_admin_apply" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.accountadmin

  privilege = "APPLY TAG"
  roles     = [snowflake_role.tag_admin[0].name, snowflake_role.tag_securityadmin[0].name]

  with_grant_option      = false
  enable_multiple_grants = true
}

resource "snowflake_role_grants" "tag_admin" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  role_name = snowflake_role.tag_admin[0].name
  roles     = ["SYSADMIN"]

  enable_multiple_grants = true
}

resource "snowflake_account_grant" "execute_task" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  roles     = ["SYSADMIN"]
  privilege = "EXECUTE TASK"

  with_grant_option      = true
  enable_multiple_grants = true
}

resource "snowflake_role_grants" "securityadmin" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  role_name = "SECURITYADMIN"
  roles     = [snowflake_role.tag_securityadmin[0].name]

  enable_multiple_grants = true
}

resource "snowflake_role_grants" "tag_securityadmin" {
  count = length(var.tags) > 0 ? 1 : 0

  provider = snowflake.securityadmin

  depends_on = [snowflake_database_grant.tag_admin_usage, snowflake_schema_grant.tag_admin_usage, snowflake_account_grant.tag_admin_apply, snowflake_role_grants.tag_admin]

  role_name = snowflake_role.tag_securityadmin[0].name
  users     = [var.snowflake_username]

  enable_multiple_grants = true
}
