locals {
  create_schemas = flatten([
    for db, schema in var.create_schemas : {
      unique = upper(join("_", [db, schema]))
      db     = db
      schema = schema
    }
  ])
}

resource "snowflake_schema" "schema" {
  for_each = {
    for uni in local.create_schemas : uni.unique => uni
  }

  depends_on = [snowflake_schema_grant.schema]

  database = upper(join("_", [var.customer, var.environment, each.value.db]))
  name     = upper(each.value.schema)
  comment  = "created by terraform"
}
