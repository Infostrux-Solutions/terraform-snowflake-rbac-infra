
resource "snowflake_user" "fivetran" {
  count = var.create_fivetran_user ? 1 : 0

  provider = snowflake.securityadmin

  name         = upper(join("_", [var.customer, var.environment, "FIVETRAN"]))
  login_name   = upper(join("_", [var.customer, var.environment, "FIVETRAN"]))
  password     = var.snowflake_fivetran_password
  display_name = upper(join(" ", [var.customer, var.environment, "FIVETRAN"]))
  comment      = "Created by terraform."
  disabled     = false

  default_warehouse = upper(join("_", [var.customer, var.environment, "INGEST_WH"]))
  default_role      = upper(join("_", [var.customer, var.environment, "INGESTION"]))

  must_change_password = false
}

resource "snowflake_user" "datadog" {
  count = var.create_datadog_user ? 1 : 0

  provider = snowflake.securityadmin

  name         = upper(join("_", [var.customer, var.environment, "DATADOG"]))
  login_name   = upper(join("_", [var.customer, var.environment, "DATADOG"]))
  password     = var.snowflake_datadog_password
  display_name = upper(join(" ", [var.customer, var.environment, "DATADOG"]))
  comment      = "Created by terraform."
  disabled     = false

  default_warehouse = upper(join("_", [var.customer, var.environment, "MONITORING_WH"]))
  default_role      = upper(join("_", [var.customer, var.environment, "MONITORING"]))

  must_change_password = false
}
