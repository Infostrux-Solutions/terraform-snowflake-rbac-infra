locals {
  # Create flattened list of resources
  dynamic_tables_roles_flat_list = flatten([
    for database, permissions in var.dynamic_tables_and_roles : [
      for permission, roles in permissions : [
        for role in roles : {
          permission = permission
          database   = database
          role       = upper(join("_", ["role", var.environment, var.product, role]))
        }
      ]
    ]
  ])

  # Group by db and role
  dynamic_tables_roles_map = {
    for item in local.dynamic_tables_roles_flat_list :
    join(".", [item.database, item.role]) => item.permission... if item.permission != "OWNERSHIP"
  }

  # Split owner permissions (Snowflake requirement)
  dynamic_tables_roles_map_owner = {
    for item in local.dynamic_tables_roles_flat_list :
    join(".", [item.database, item.role]) => item.permission... if item.permission == "OWNERSHIP"
  }
}

resource "snowflake_grant_privileges_to_account_role" "dynamic_tables" {
  for_each = local.dynamic_tables_roles_map

  privileges        = each.value
  account_role_name = split(".", each.key)[1]
  on_schema_object {
    future {
      object_type_plural = "DYNAMIC TABLES"
      in_database        = snowflake_database.database[split(".", each.key)[0]].id
    }
  }
}

resource "snowflake_grant_ownership" "dynamic_tables" {
  for_each = local.dynamic_tables_roles_map_owner

  account_role_name = split(".", each.key)[1]
  on {
    future {
      object_type_plural = "DYNAMIC TABLES"
      in_database        = snowflake_database.database[split(".", each.key)[0]].id
    }
  }
}
