module "sf_warehouse" {
  source   = "../../modules/sf_warehouse"
  for_each = var.warehouses_and_roles

  name           = upper(join("_", [var.customer, var.environment, each.key]))
  warehouse_size = var.snowflake_warehouse_size

  tags        = merge(var.default_tags, { "WAREHOUSE_PURPOSE" = var.warehouse_tags[each.key] })
  tags_db     = "DB_TAGS"
  tags_schema = "TAGS"
}