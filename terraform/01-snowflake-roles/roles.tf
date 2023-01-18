locals {
  tags_list = flatten([
    for key, value in var.default_tags : {
      name     = key
      value    = value
      database = try(snowflake_database.tags[0].name, "DB_TAGS")
      schema   = try(snowflake_schema.tags[0].name, "TAGS")
    }
  ])
}

module "sf_role" {
  for_each = toset(var.roles)

  providers = {
    snowflake = snowflake.tag_securityadmin
  }

  source     = "../../modules/sf_role"
  depends_on = [snowflake_tag.tag, snowflake_role_grants.tag_securityadmin]

  name = upper(join("_", [var.customer, var.environment, each.value]))

  tags = local.tags_list
}

module "parent_sf_role" {
  for_each = toset(var.parent_roles)

  providers = {
    snowflake = snowflake.tag_securityadmin
  }

  source     = "../../modules/sf_role"
  depends_on = [snowflake_tag.tag, snowflake_role_grants.tag_securityadmin]

  name = upper(each.value)

  tags = local.tags_list
}

resource "snowflake_role" "tag_admin" {
  count = length(var.tags) > 0 ? 1 : 0

  name = "TAG_ADMIN"

  provider = snowflake.securityadmin

  depends_on = [snowflake_tag.tag]
}

resource "snowflake_role" "tag_securityadmin" {
  count = length(var.tags) > 0 ? 1 : 0

  name = "TAG_SECURITYADMIN"

  provider = snowflake.securityadmin

  depends_on = [snowflake_tag.tag]
}
