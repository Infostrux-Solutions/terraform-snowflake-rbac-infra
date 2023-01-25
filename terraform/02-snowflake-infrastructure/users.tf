
resource "snowflake_user" "fivetran" {
  provider = snowflake.tag_securityadmin

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
