locals {
  object_prefix   = length(var.project) > 0 ? join("_", [var.environment, var.project]) : var.environment
  create_tags     = length(var.tags) > 0 ? 1 : 0
  roles_yml       = yamldecode(file("${var.config_dir}/roles.yml"))
  users_yml       = yamldecode(file("${var.config_dir}/users.yml"))
  permissions_yml = yamldecode(file("${var.config_dir}/permissions.yml"))
  database_yml    = yamldecode(file("${var.config_dir}/databases.yml"))
  warehouse_yml   = yamldecode(file("${var.config_dir}/warehouses.yml"))
}