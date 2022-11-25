resource "snowflake_role" "role" {
  name    = var.name
  comment = var.comment

  dynamic "tag" {
    for_each = var.tags

    content {
      name     = tag.value.name
      value    = tag.value.value
      database = tag.value.database
      schema   = tag.value.schema
    }
  }
}