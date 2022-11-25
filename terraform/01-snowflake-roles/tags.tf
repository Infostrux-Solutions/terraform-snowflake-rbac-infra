resource "snowflake_tag" "tag" {
  for_each   = var.tags
  depends_on = [snowflake_database.tags, snowflake_schema.tags]

  name     = each.key
  database = snowflake_database.tags[0].name
  schema   = snowflake_schema.tags[0].name

  comment        = "created by terraform"
  allowed_values = each.value
}