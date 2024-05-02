locals {
  fivetran_username = upper(join("_", [local.object_prefix, "fivetran"]))
  datadog_username  = upper(join("_", [local.object_prefix, "datadog"]))
}

resource "snowflake_user" "fivetran" {
  count = var.create_fivetran_user ? 1 : 0

  provider = snowflake.securityadmin

  name         = local.fivetran_username
  login_name   = local.fivetran_username
  password     = var.snowflake_fivetran_password
  display_name = local.fivetran_username
  comment      = var.comment
  disabled     = false

  default_warehouse = snowflake_warehouse.warehouse["ingestion"].name
  default_role      = snowflake_role.environment_role["ingestion"].name

  must_change_password = false
}

resource "snowflake_user" "datadog" {
  count = var.create_datadog_user ? 1 : 0

  provider = snowflake.securityadmin

  name         = local.datadog_username
  login_name   = local.datadog_username
  password     = var.snowflake_datadog_password
  display_name = local.datadog_username
  comment      = var.comment
  disabled     = false

  default_warehouse = snowflake_warehouse.warehouse["monitoring"].name
  default_role      = snowflake_role.environment_role["monitoring"].name

  must_change_password = false
}
