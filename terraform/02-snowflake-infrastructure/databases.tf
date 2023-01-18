resource "snowflake_database" "database" {
  for_each = var.dbs_and_roles

  name    = upper(join("_", [var.customer, var.environment, each.key]))
  comment = "created by terraform"

  dynamic "tag" {
    for_each = merge(var.default_tags, { "DATA_LAYER" = title(lower(split("_", each.key)[0])) })

    content {
      name     = tag.key
      value    = tag.value
      database = "DB_TAGS"
      schema   = "TAGS"
    }
  }
}