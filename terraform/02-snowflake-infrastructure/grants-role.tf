locals {
  role_to_roles_list = flatten([
    for out_role, roles in var.role_to_roles : {
      role  = upper(join("_", [var.customer, var.environment, out_role]))
      roles = roles
    }
  ])
}

resource "snowflake_role_grants" "role" {
  for_each = {
    for uni in local.role_to_roles_list : uni.role => uni
  }

  provider = snowflake.tag_securityadmin

  role_name = each.value.role
  roles     = each.value.roles

  enable_multiple_grants = true
}

resource "snowflake_role_grants" "fivetran" {
  count = var.snowflake_fivetran_password != "" ? 1 : 0

  provider = snowflake.tag_securityadmin

  role_name = upper(join("_", [var.customer, var.environment, "INGESTION"]))
  users     = [snowflake_user.fivetran[0].name]

  enable_multiple_grants = true
}

resource "snowflake_role_grants" "datadog" {
  count = var.snowflake_datadog_password != "" ? 1 : 0

  provider = snowflake.tag_securityadmin

  role_name = upper(join("_", [var.customer, var.environment, "MONITORING"]))
  users     = [snowflake_user.datadog[0].name]

  enable_multiple_grants = true
}
