locals {
  fivetran_username = upper(join("_", [var.customer, var.environment, "FIVETRAN"]))
  datadog_username  = upper(join("_", [var.customer, var.environment, "DATADOG"]))
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

  default_warehouse = upper(join("_", [var.customer, var.environment, "INGEST_WH"]))
  default_role      = upper(join("_", [var.customer, var.environment, "INGESTION"]))

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

  default_warehouse = upper(join("_", [var.customer, var.environment, "MONITORING_WH"]))
  default_role      = upper(join("_", [var.customer, var.environment, "MONITORING"]))

  must_change_password = false
}
