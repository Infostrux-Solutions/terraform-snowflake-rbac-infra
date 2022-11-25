resource "snowflake_warehouse" "warehouse" {
  name           = var.name
  comment        = var.comment
  warehouse_size = var.warehouse_size

  dynamic "tag" {
    for_each = var.tags

    content {
      name     = tag.key
      value    = tag.value
      database = var.tags_db
      schema   = var.tags_schema
    }
  }
}