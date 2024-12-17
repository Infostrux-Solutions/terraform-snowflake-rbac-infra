locals {
  object_prefix   = length(var.project) > 0 ? join("_", [var.environment, var.project]) : var.environment
  create_tags     = length(var.tags) > 0 ? 1 : 0
  roles_yml       = yamldecode(file("${var.config_dir}/roles.yml"))
  users_yml       = yamldecode(file("${var.config_dir}/users.yml"))
  permissions_yml = yamldecode(file("${var.config_dir}/permissions.yml"))
  database_yml    = yamldecode(file("${var.config_dir}/databases.yml"))
  warehouse_yml   = yamldecode(file("${var.config_dir}/warehouses.yml"))
  default_tags    = coalesce(var.default_tags, {})

  # for convenience define all the supported object types
  object_type = {
    databases          = "databases"
    schemas            = "schemas"
    tables             = "tables"
    dynamic_tables     = "dynamic_tables"
    views              = "views"
    materialized_views = "materialized_views"
  }
  # group permissions per supported object type to handle optional grants in case an object type
  # is not supported by Snowflake license (e.g. materialized views not supported by the Standard edition)
  #
  # in other words "permissions_per_type" will contain all "object_types" but with empty list
  # for those that are omitted during config, so that the rest of the code works accordingly
  permissions_per_type = {
    for role, grants in local.permissions_yml.permissions.database : role => {
      for type, name in local.object_type : type => lookup(grants, type, [])
    }
  }
}
