locals {
  database_tags = flatten([
    for database in snowflake_database.database : [
      for tag, value in var.default_tags : {
        key       = upper(join("_", [db, tag]))
        database  = upper(join("_", [local.object_prefix, db]))
        tag_name  = "GOVERNANCE.TAGS.${tag}"
        tag_value = value
      }
    ]
  ])
  warehouse_tags = flatten([
    for warehouse in snowflake_warehouse.warehouse : [
      for tag, value in var.default_tags : {
        key       = upper(join("_", [stage, tag]))
        tag_name  = "GOVERNANCE.TAGS.${tag}"
        tag_value = value
      }
    ]
  ])
}

resource "snowflake_tag_association" "database_tags" {
  for_each = {
    for unique in local.database_tags : unique.key => unique
  }

  depends_on = [snowflake_database.database]

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

  object_identifier {
    name = module.sf_warehouse[each.value.stage].id
  }
  object_type = "WAREHOUSE"
  tag_id      = each.value.tag_name
  tag_value   = each.value.tag_value
}