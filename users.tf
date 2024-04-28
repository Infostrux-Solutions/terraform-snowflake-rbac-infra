locals {
  fivetran_username = upper(join("_", [local.object_prefix, "FIVETRAN"]))
  datadog_username  = upper(join("_", [local.object_prefix, "DATADOG"]))
}

resource "snowflake_user" "fivetran" {
  count = var.create_fivetran_user ? 1 : 0

  provider = snowflake.useradmin

  name         = local.fivetran_username
  login_name   = local.fivetran_username
  password     = var.snowflake_fivetran_password
  display_name = local.fivetran_username
  comment      = var.comment
  disabled     = false

  default_warehouse = upper(join("_", [local.object_prefix, "INGEST_WH"]))
  default_role      = upper(join("_", [local.object_prefix, "INGESTION"]))

  must_change_password = false
}

resource "snowflake_user" "datadog" {
  count = var.create_datadog_user ? 1 : 0

  provider = snowflake.useradmin

  name         = local.datadog_username
  login_name   = local.datadog_username
  password     = var.snowflake_datadog_password
  display_name = local.datadog_username
  comment      = var.comment
  disabled     = false

  default_warehouse = upper(join("_", [local.object_prefix, "MONITORING_WH"]))
  default_role      = upper(join("_", [local.object_prefix, "MONITORING"]))

  must_change_password = false
}
