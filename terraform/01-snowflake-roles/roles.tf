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
    snowflake = snowflake.accountadmin
  }

  source     = "../../modules/sf_role"
  depends_on = [snowflake_tag.tag]

  name           = upper(join("_", [var.environment, each.value]))
  grant_to_roles = upper(join("_", [var.environment, each.value]))

  tags = local.tags_list
}

module "parent_sf_role" {
  for_each = toset(var.parent_roles)

  providers = {
    snowflake = snowflake.accountadmin
  }

  source     = "../../modules/sf_role"
  depends_on = [snowflake_tag.tag]

  name           = upper(join("_", [each.value]))
  grant_to_roles = upper(join("_", [each.value]))

  tags = local.tags_list
}

module "tag_admin" {
  count = length(var.tags) > 0 ? 1 : 0

  providers = {
    snowflake = snowflake.accountadmin
  }

  depends_on = [snowflake_tag.tag]

  source         = "../../modules/sf_role"
  name           = "TAG_ADMIN"
  grant_to_roles = "TAG_ADMIN"

  tags = local.tags_list
}