locals {
  user_type = {
    person         = "PERSON"
    service        = "SERVICE"
    legacy_service = "LEGACY_SERVICE"
  }
  all_users = {
    for entry in [
      for user, specs in local.users_yml.users : merge(
        specs,
        {
          type     = upper(coalesce(lookup(specs, "type", null), "<EMPTY>"))
          existing = coalesce(lookup(specs, "existing", null), false)
          username = upper(coalesce(lookup(specs, "existing", null), false) ? user : join("_", [local.object_prefix, user]))
        }
      )
    ] : entry.username => entry ## enforce username to be unique
  }
  new_users = {
    for user, specs in local.all_users : user => specs if !specs.existing && !contains([local.user_type.service, local.user_type.legacy_service], specs.type)
  }
  new_service_users = {
    for user, specs in local.all_users : user => specs if !specs.existing && specs.type == local.user_type.service
  }
  new_legacy_service_users = {
    for user, specs in local.all_users : user => specs if !specs.existing && specs.type == local.user_type.legacy_service
  }
}

resource "snowflake_user" "user" {
  for_each = local.new_users

  provider = snowflake.useradmin

  name         = each.key
  login_name   = each.key
  display_name = each.key
  comment      = var.comment
  disabled     = false

  default_warehouse    = snowflake_warehouse.warehouse[each.value.warehouse].name
  default_role         = snowflake_account_role.functional_role[each.value.role].name
  must_change_password = false

  lifecycle {
    ignore_changes = [
      password,
      rsa_public_key,
      rsa_public_key_2
    ]
  }
}

resource "snowflake_service_user" "user" {
  for_each = local.new_service_users

  provider = snowflake.useradmin

  name         = each.key
  login_name   = each.key
  display_name = each.key
  comment      = var.comment
  disabled     = false

  default_warehouse = snowflake_warehouse.warehouse[each.value.warehouse].name
  default_role      = snowflake_account_role.functional_role[each.value.role].name

  lifecycle {
    ignore_changes = [
      rsa_public_key,
      rsa_public_key_2
    ]
  }
}

resource "snowflake_legacy_service_user" "user" {
  for_each = local.new_legacy_service_users

  provider = snowflake.useradmin

  name         = each.key
  login_name   = each.key
  display_name = each.key
  comment      = var.comment
  disabled     = false

  default_warehouse    = snowflake_warehouse.warehouse[each.value.warehouse].name
  default_role         = snowflake_account_role.functional_role[each.value.role].name
  must_change_password = false

  lifecycle {
    ignore_changes = [
      password,
      rsa_public_key,
      rsa_public_key_2
    ]
  }
}
