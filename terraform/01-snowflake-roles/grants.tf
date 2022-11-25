resource "snowflake_database_grant" "tag_admin_usage" {
  count = length(var.tags) > 0 ? 1 : 0

  database_name = snowflake_database.tags[0].name

  privilege = "USAGE"
  roles     = [module.tag_admin[0].name]

  with_grant_option = true
}

resource "snowflake_schema_grant" "tag_admin_usage" {
  count = length(var.tags) > 0 ? 1 : 0

  database_name = snowflake_database.tags[0].name
  schema_name   = snowflake_schema.tags[0].name

  privilege = "USAGE"
  roles     = [module.tag_admin[0].name]

  with_grant_option = true
}

resource "snowflake_schema_grant" "tag_admin_create_tag" {
  count = length(var.tags) > 0 ? 1 : 0

  database_name = snowflake_database.tags[0].name
  schema_name   = snowflake_schema.tags[0].name

  privilege = "CREATE TAG"
  roles     = [module.tag_admin[0].name]

  with_grant_option = true
}

resource "snowflake_account_grant" "tag_admin_apply" {
  count = length(var.tags) > 0 ? 1 : 0

  privilege = "APPLY TAG"
  roles     = [module.tag_admin[0].name]

  with_grant_option = false
}

resource "snowflake_account_grant" "execute_task" {
  count = length(var.tags) > 0 ? 1 : 0

  roles     = ["SYSADMIN"]
  privilege = "EXECUTE TASK"

  with_grant_option = true
}

resource "snowflake_role_grants" "tag_admin" {
  count = length(var.tags) > 0 ? 1 : 0

  role_name = module.tag_admin[0].name
  roles     = ["SYSADMIN"]

  enable_multiple_grants = true
}