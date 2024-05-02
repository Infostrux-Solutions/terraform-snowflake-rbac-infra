locals {
  object_prefix   = join("_", [var.environment, var.project])
  create_tags     = length(var.tags) > 0 ? 1 : 0
  roles_yml       = yamldecode(file("config/roles.yml"))
  permissions_yml = yamldecode(file("config/permissions.yml"))
  database_yml    = yamldecode(file("config/databases.yml"))
  warehouse_yml   = yamldecode(file("config/warehouses.yml"))
}