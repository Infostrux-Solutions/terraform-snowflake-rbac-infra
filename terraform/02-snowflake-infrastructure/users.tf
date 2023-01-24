
resource "snowflake_user" "fivetran" {
  name         = upper(join("_", [var.environment, "FIVETRAN"]))
  login_name   = upper(join("_", [var.environment, "FIVETRAN"]))
  password     = var.snowflake_fivetran_password
  display_name = upper(join(" ", [var.environment, "FIVETRAN_USER"]))
  comment      = "Created by terraform."
  disabled     = false

  default_warehouse = upper(join("_", [var.environment, "INGESTION"]))
  default_role      = upper(join("_", [var.environment, "SYSADMIN"]))

  must_change_password = false
}
