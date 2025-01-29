locals {
  functional_role_grants = flatten([
    for parent, children in local.functional_roles : [
      for child in children : {
        unique = join("_", [parent, child])
        parent = upper(join("_", [local.object_prefix, parent]))
        child  = upper(join("_", [local.object_prefix, child]))
      }
    ]
  ])

  account_role_grants = flatten([
    for parent, children in local.account_roles : [
      for child in children : {
        unique = join("_", [parent, child])
        parent = upper(parent)
        child  = upper(join("_", [local.object_prefix, child]))
      }
    ]
  ])

  user_role_grants = flatten([
    for username, user in local.all_users : [
      for role in user.roles : {
        unique = join("_", [username, role])
        username = upper(coalesce(
          # must be one of snowflake_user, snowflake_service_user, snowflake_legacy_service_user or existing user
          try(snowflake_user.user[username].name, null),
          try(snowflake_service_user.user[username].name, null),
          try(snowflake_legacy_service_user.user[username].name, null),
          user.username
        ))
        role = role
      }
    ]
  ])
}

resource "snowflake_grant_account_role" "functional_role" {
  for_each = {
    for uni in local.functional_role_grants : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_account_role.functional_role, snowflake_account_role.account_role]

  role_name        = each.value.child
  parent_role_name = each.value.parent
}

resource "snowflake_grant_account_role" "account_role" {
  for_each = {
    for uni in local.account_role_grants : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_account_role.functional_role, snowflake_account_role.account_role]

  role_name        = each.value.child
  parent_role_name = each.value.parent
}

resource "snowflake_grant_account_role" "user" {
  for_each = {
    for uni in local.user_role_grants : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_account_role.functional_role]

  role_name = snowflake_account_role.functional_role[each.value.role].name
  user_name = each.value.username
}

resource "snowflake_grant_privileges_to_account_role" "tag_database" {
  count    = local.create_tags
  provider = snowflake.securityadmin

  account_role_name = snowflake_account_role.tag_admin[0].name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = try(snowflake_database.tags[0].name, var.governance_database_name)
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_schema" {
  count    = local.create_tags
  provider = snowflake.securityadmin

  account_role_name = snowflake_account_role.tag_admin[0].name
  privileges        = ["USAGE", "CREATE TAG"]

  on_schema {
    schema_name = "\"${try(snowflake_database.tags[0].name, var.governance_database_name)}\".\"${try(snowflake_schema.tags[0].name, var.tags_schema_name)}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "tag_admin" {
  count    = local.create_tags
  provider = snowflake.accountadmin

  privileges        = ["APPLY TAG"]
  account_role_name = snowflake_account_role.tag_admin[0].name
  on_account        = true
}

resource "snowflake_grant_account_role" "tag_admin" {
  count = local.create_tags

  provider = snowflake.securityadmin

  role_name        = snowflake_account_role.tag_admin[0].name
  parent_role_name = "SYSADMIN"
}
