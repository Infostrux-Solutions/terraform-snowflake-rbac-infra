locals {
  warehouse_yml = yamldecode(file("config/warehouses.yml"))

  warehouses = {
    for warehouse, grants in local.warehouse_yml.warehouses : warehouse => grants
  }

  warehouse_grants = flatten([
    for warehouse, grants in local.warehouses : [
      for role, privilege in grants : {
        unique    = join("_", [warehouse, trimspace(role)])
        warehouse = warehouse
        privilege = privilege
        role      = upper(join("_", [local.object_prefix, role]))
      }
    ]
  ])

  warehouse_grants_wo_ownership = flatten([
    for warehouse, grants in local.warehouses : [
      for role, privilege in grants : {
        unique    = join("_", [warehouse, trimspace(role)])
        warehouse = warehouse
        privilege = sort([for p in setsubtract(privilege, ["ownership"]) : upper(p)])
        role      = upper(join("_", [local.object_prefix, role]))
      }
    ]
  ])
}

resource "snowflake_warehouse" "warehouse" {
  for_each   = local.warehouses
  depends_on = [snowflake_role.roles, snowflake_role.parent_roles]

  name           = upper(join("_", [local.object_prefix, each.key]))
  comment        = var.comment
  warehouse_size = var.snowflake_warehouse_size
  auto_suspend   = try(var.warehouse_auto_suspend[each.key], 600)
}

resource "snowflake_grant_privileges_to_account_role" "warehouse" {
  for_each = {
    for uni in local.warehouse_grants_wo_ownership : uni.unique => uni
  }

  provider   = snowflake.securityadmin
  depends_on = [snowflake_grant_ownership.warehouse]

  account_role_name = each.value.role
  privileges        = each.value.privilege
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.warehouse[each.value.warehouse].id
  }
}

resource "snowflake_grant_ownership" "warehouse" {
  for_each = {
    for uni in local.warehouse_grants : uni.unique => uni if contains(uni.privilege, "ownership")
  }

  provider = snowflake.securityadmin

  account_role_name = each.value.role
  on {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.warehouse[each.value.warehouse].id
  }
}
