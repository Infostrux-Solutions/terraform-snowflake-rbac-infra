locals {
  object_prefix   = join("_", [var.environment, var.project])
  roles_yml       = yamldecode(file("config/roles.yml"))
  permissions_yml = yamldecode(file("config/permissions.yml"))
  database_yml    = yamldecode(file("config/databases.yml"))
  warehouse_yml   = yamldecode(file("config/warehouses.yml"))
}