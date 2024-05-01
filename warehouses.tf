locals {
  warehouses = {
    for warehouse, specs in local.warehouse_yml.warehouses : warehouse => specs
  }

  warehouse_ownership = flatten([
    for warehouse, specs in local.warehouses : [
      for role, privilege in specs.roles : {
        unique    = join("_", [warehouse, trimspace(role)])
        warehouse = warehouse
        role      = upper(join("_", [local.object_prefix, role]))
        privilege = sort([for p in setintersection(privilege, ["ownership"]) : upper(p)])
      } if contains(privilege, "ownership")
    ]
  ])

  warehouse_grants_wo_ownership = flatten([
    for warehouse, specs in local.warehouses : [
      for role, privilege in specs.roles : {
        unique    = join("_", [warehouse, trimspace(role)])
        warehouse = warehouse
        role      = upper(join("_", [local.object_prefix, role]))
        privilege = sort([for p in setsubtract(privilege, ["ownership"]) : upper(p)])
      }
    ]
  ])
}

resource "snowflake_warehouse" "warehouse" {
  for_each   = local.warehouses
  depends_on = [snowflake_role.environment_role, snowflake_role.account_role, snowflake_role.access_role]

  name           = upper(join("_", [local.object_prefix, each.key]))
  comment        = var.comment
  warehouse_size = try(each.value.size, var.default_warehouse_size)
  auto_suspend   = try(each.value.auto_suspend, var.default_warehouse_auto_suspend)
}

resource "snowflake_grant_privileges_to_account_role" "warehouse" {
  for_each = {
    for uni in local.warehouse_grants_wo_ownership : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.warehouse[each.value.warehouse].id
  }
}

resource "snowflake_grant_ownership" "warehouse" {
  for_each = {
    for uni in local.warehouse_ownership : uni.unique => uni
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  on {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.warehouse[each.value.warehouse].id
  }
}