locals {
  object_prefix   = length(var.project) > 0 ? join("_", [var.environment, var.project]) : var.environment
  create_tags     = length(var.tags) > 0 ? 1 : 0
  roles_yml       = yamldecode(file("config/roles.yml"))
  users_yml       = yamldecode(file("config/users.yml"))
  permissions_yml = yamldecode(file("config/permissions.yml"))
  database_yml    = yamldecode(file("config/databases.yml"))
  warehouse_yml   = yamldecode(file("config/warehouses.yml"))
}