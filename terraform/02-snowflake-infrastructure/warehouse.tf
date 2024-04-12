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
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])

  warehouse_grants_wo_ownership = flatten([
    for warehouse, grants in local.warehouses : [
      for role, privilege in grants : {
        unique    = join("_", [warehouse, trimspace(role)])
        warehouse = warehouse
        privilege = setsubtract(privilege, ["ownership"])
        role      = upper(join("_", [var.customer, var.environment, role]))
      }
    ]
  ])
}

resource "snowflake_warehouse" "warehouse" {
  for_each = local.warehouses

  name           = upper(join("_", [var.customer, var.environment, each.key]))
  comment        = "created by terraform"
  warehouse_size = var.snowflake_warehouse_size
  auto_suspend   = try(var.warehouse_auto_suspend[each.key], 600)
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
    for uni in local.warehouse_grants : uni.unique => uni if contains(uni.privilege, "ownership")
  }

  provider = snowflake.securityadmin

  account_role_name   = each.value.role
  outbound_privileges = "REVOKE"
  on {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.warehouse[each.value.warehouse].id
  }
}
