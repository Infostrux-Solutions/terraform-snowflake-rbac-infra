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