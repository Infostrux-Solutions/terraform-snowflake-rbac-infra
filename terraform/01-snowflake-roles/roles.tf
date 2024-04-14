locals {
  object_prefix = join("_", [var.customer, var.environment])

  roles = {
    for role, roles in local.roles_yml.roles : role => roles
  }

  parent_roles = distinct(flatten([
    for role, parent_roles in local.roles : [
      for parent_role in parent_roles : [
        var.create_parent_roles ? upper(parent_role) : null
      ]
    ]
  ]))

  tags_list = flatten([
    for key, value in var.default_tags : {
      name     = key
      value    = value
      database = try(snowflake_database.tags[0].name, "GOVERNANCE")
      schema   = try(snowflake_schema.tags[0].name, "TAGS")
    }
  ])
}

resource "snowflake_role" "roles" {
  for_each = local.roles

  provider = snowflake.securityadmin

  name    = upper(join("_", [local.object_prefix, each.value.role]))
  comment = var.comment
}

resource "snowflake_role" "parent_roles" {
  for_each = toset(local.parent_roles)
  provider = snowflake.securityadmin

  name    = upper(each.value)
  comment = var.comment
}

resource "snowflake_role" "tag_admin" {
  count    = length(var.tags) > 0 ? 1 : 0
  provider = snowflake.securityadmin

  name = "TAG_ADMIN"

  depends_on = [snowflake_tag.tag]
}

resource "snowflake_role" "tag_securityadmin" {
  count    = length(var.tags) > 0 ? 1 : 0
  provider = snowflake.securityadmin

  name = "TAG_SECURITYADMIN"

  depends_on = [snowflake_tag.tag]
}
