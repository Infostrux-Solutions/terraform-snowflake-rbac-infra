locals {
  warehouses_role_list = flatten([
    for stage, perm in var.warehouses_and_roles : [
      for perm, roles_opt in perm : {
        unique       = upper(join("_", [stage, trimspace(perm)]))
        stage        = stage
        perm         = perm
        grant_option = try(roles_opt["WITH_GRANT_OPTION"], true)
        role = tolist([
          for role in try(roles_opt["ROLES"], roles_opt) :
          upper(join("_", [var.environment, role]))
        ])
      }
    ]
  ])
}

resource "snowflake_warehouse_grant" "warehouse" {
  for_each = {
    for uni in local.warehouses_role_list : uni.unique => uni
  }

  warehouse_name = module.sf_warehouse[each.value.stage].id

  privilege = each.value.perm
  roles     = each.value.role

  with_grant_option = each.value.grant_option
}