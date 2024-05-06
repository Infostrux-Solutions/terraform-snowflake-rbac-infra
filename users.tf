locals {
  dbt_username       = upper(join("_", [local.object_prefix, "dbt"]))
  fivetran_username  = upper(join("_", [local.object_prefix, "fivetran"]))
  datadog_username   = upper(join("_", [local.object_prefix, "datadog"]))
  reporting_username = upper(join("_", [local.object_prefix, "reporting"]))
}

resource "snowflake_user" "dbt" {
  count = var.create_dbt_user ? 1 : 0

  provider = snowflake.securityadmin

  name           = local.dbt_username
  login_name     = local.dbt_username
  rsa_public_key = var.snowflake_dbt_private_key
  display_name   = local.dbt_username
  comment        = var.comment
  disabled       = false

  default_warehouse = snowflake_warehouse.warehouse["transform"].name
  default_role      = snowflake_role.environment_role["transform"].name

  must_change_password = false
}

resource "snowflake_user" "fivetran" {
  count = var.create_fivetran_user ? 1 : 0

  provider = snowflake.securityadmin

  name         = local.fivetran_username
  login_name   = local.fivetran_username
  rsa_public_key     = var.snowflake_fivetran_private_key
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
  rsa_public_key     = var.snowflake_datadog_private_key
  display_name = local.datadog_username
  comment      = var.comment
  disabled     = false

  default_warehouse = snowflake_warehouse.warehouse["monitoring"].name
  default_role      = snowflake_role.environment_role["monitoring"].name

  must_change_password = false
}

resource "snowflake_user" "reporting" {
  count = var.create_reporting_user ? 1 : 0

  provider = snowflake.securityadmin

  name         = local.dbt_username
  login_name   = local.dbt_username
  rsa_public_key     = var.snowflake_reporting_private_key
  display_name = local.dbt_username
  comment      = var.comment
  disabled     = false

  default_warehouse = snowflake_warehouse.warehouse["analyst"].name
  default_role      = snowflake_role.environment_role["analyst"].name

  must_change_password = false
}