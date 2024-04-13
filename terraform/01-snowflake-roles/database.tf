resource "snowflake_database" "tags" {
  count = length(var.tags) > 0 ? 1 : 0

  name    = "GOVERNANCE"
  comment = var.comment
}