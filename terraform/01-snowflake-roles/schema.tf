resource "snowflake_schema" "tags" {
  count = length(var.tags) > 0 ? 1 : 0

  database = snowflake_database.tags[0].id
  name     = "TAGS"
  comment  = var.comment
}