resource "snowflake_database" "tags" {
  count = length(var.tags) > 0 ? 1 : 0

  name    = "DB_TAGS"
  comment = "created by terraform"
}