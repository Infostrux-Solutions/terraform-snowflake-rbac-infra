locals {
  users = {
    for user, specs in local.users_yml.users : join("_", [local.object_prefix, user]) => specs
  }
}

resource "snowflake_user" "user" {
  for_each = local.users

  provider = snowflake.securityadmin

  name         = each.key
  login_name   = each.key
  display_name = each.key
  comment      = var.comment
  disabled     = false

  default_warehouse    = snowflake_warehouse.warehouse[each.value.warehouse].name
  default_role         = snowflake_role.environment_role[each.value.role].name
  must_change_password = false

  lifecycle {
    ignore_changes = [
      password,
      rsa_public_key,
      rsa_public_key_2
    ]
  }
}
