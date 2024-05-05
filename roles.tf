locals {
  environment_roles = {
    for role, roles in local.roles_yml.environment_roles : role => roles
  }

  account_roles = {
    for role, roles in local.roles_yml.account_roles : role => roles
  }

  account_roles_wo_sysadmin = {
    for role, roles in local.account_roles : role => roles if !contains([role], "sysadmin")
  }

  access_roles = flatten([
    for database, specs in local.databases : [
      for role in specs.roles : join("_", [database, role])
    ]
  ])

  tags_list = flatten([
    for key, value in var.default_tags : {
      name     = key
      value    = value
      database = try(snowflake_database.tags[0].name, "GOVERNANCE")
      schema   = try(snowflake_schema.tags[0].name, "TAGS")
    }
  ])
}

resource "snowflake_role" "access_role" {
  for_each = toset(local.access_roles)

  provider = snowflake.securityadmin

  name    = upper(join("_", [local.object_prefix, each.key]))
  comment = var.comment
}

resource "snowflake_role" "environment_role" {
  for_each = local.environment_roles

  provider = snowflake.securityadmin

  name    = upper(join("_", [local.object_prefix, each.key]))
  comment = var.comment
}

resource "snowflake_role" "account_role" {
  for_each = local.account_roles_wo_sysadmin
  provider = snowflake.securityadmin

  name    = upper(each.key)
  comment = var.comment
}

resource "snowflake_role" "tag_admin" {
  count    = local.create_tags
  provider = snowflake.securityadmin

  name = var.tag_admin_role

  depends_on = [snowflake_tag.tag]
}

