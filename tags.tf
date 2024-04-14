locals {
  database_tags = flatten([
    for database in snowflake_database.database : [
      for tag, value in var.default_tags : {
        key       = upper(join("_", [database.name, tag]))
        database  = database.name
        tag_name  = "${snowflake_database.tags[0].name}.${snowflake_schema.tags[0].name}.${tag}"
        tag_value = value
      }
    ]
  ])
  warehouse_tags = flatten([
    for warehouse in snowflake_warehouse.warehouse : [
      for tag, value in var.default_tags : {
        key       = upper(join("_", [warehouse.name, tag]))
        warehouse = warehouse.name
        tag_name  = "${snowflake_database.tags[0].name}.${snowflake_schema.tags[0].name}.${tag}"
        tag_value = value
      }
    ]
  ])
}

resource "snowflake_database" "tags" {
  count = length(var.tags) > 0 ? 1 : 0

  name    = "GOVERNANCE"
  comment = var.comment
}

resource "snowflake_schema" "tags" {
  count = length(var.tags) > 0 ? 1 : 0

  database = snowflake_database.tags[0].id
  name     = "TAGS"
  comment  = var.comment
}

resource "snowflake_tag" "tag" {
  for_each   = var.tags
  depends_on = [snowflake_database.tags, snowflake_schema.tags]

  name     = each.key
  database = snowflake_database.tags[0].name
  schema   = snowflake_schema.tags[0].name

  comment        = var.comment
  allowed_values = each.value
}

resource "snowflake_tag_association" "database_tags" {
  for_each = {
    for unique in local.database_tags : unique.key => unique
  }

  depends_on = [snowflake_tag.tag]

  object_identifier {
    name = each.value.database
  }
  object_type = "DATABASE"
  tag_id      = each.value.tag_name
  tag_value   = each.value.tag_value
}

resource "snowflake_tag_association" "warehouse_tags" {
  for_each = {
    for unique in local.warehouse_tags : unique.key => unique
  }

  depends_on = [snowflake_tag.tag]

  object_identifier {
    name = each.value.warehouse
  }
  object_type = "WAREHOUSE"
  tag_id      = each.value.tag_name
  tag_value   = each.value.tag_value
}