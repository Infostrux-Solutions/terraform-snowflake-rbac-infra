resource "snowflake_warehouse" "warehouse" {
  name           = var.name
  comment        = var.comment
  warehouse_size = var.warehouse_size

  min_cluster_count = var.min_cluster_count
  max_cluster_count = var.max_cluster_count
  
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