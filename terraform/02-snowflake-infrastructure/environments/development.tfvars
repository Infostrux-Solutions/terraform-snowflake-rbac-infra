# Common
customer    = "infx"
domain      = "snowflake"
environment = "dev"
region      = "us-east-2"

default_tags = {
  OWNER         = "matt@infostrux.com"
  ENVIRONMENT   = "Development"
  CREATED_USING = "Terraform"
  SOURCE_CODE   = "terraform-snowflake-rbac-infra"
}

warehouse_tags = {
  "INGEST_WH"    = "Ingest"
  "DEV_WH"       = "Transform"
  "REPORTING_WH" = "Serve"
}

# Snowflake
snowflake_role           = "SYSADMIN"
snowflake_account        = "aua12673"
snowflake_username       = "INFX_TERRAFORM"
snowflake_cloud          = "" # blank for us-west-2 
snowflake_warehouse_size = "xsmall"

warehouse_auto_suspend = {
  "INGEST_WH" = 120
}

# Creates Warehouses and Role Permissions
warehouses_and_roles = {

  "INGEST_WH" = {
    "USAGE"     = ["INGESTION", "SYSADMIN"]
    "MONITOR"   = ["SYSADMIN"]
    "MODIFY"    = ["SYSADMIN"]
    "OPERATE"   = ["INGESTION", "SYSADMIN"]
    "OWNERSHIP" = ["SYSADMIN"]
  }

  ## Need to add a WH for tasks and workloads?

  "DEV_WH" = {
    "USAGE"     = ["DEVELOPER", "DBT", "SYSADMIN"]
    "MONITOR"   = ["SYSADMIN"]
    "MODIFY"    = ["SYSADMIN"]
    "OPERATE"   = ["DEVELOPER", "DBT", "SYSADMIN"]
    "OWNERSHIP" = ["SYSADMIN"]
  }

  "REPORTING_WH" = {
    "USAGE"     = ["ANALYST", "SYSADMIN"]
    "MONITOR"   = ["SYSADMIN"]
    "MODIFY"    = ["SYSADMIN"]
    "OPERATE"   = ["ANALYST", "SYSADMIN"]
    "OWNERSHIP" = ["SYSADMIN"]
  }
}

# Database name = Schema name (to create)
create_schemas = {
  #"INGEST" = "CLIENTS"
}

# Creates Databases and Role Permissions
dbs_and_roles = {

  "INGEST" = {
    "USAGE"         = ["ANALYST", "INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "MODIFY"        = ["INGESTION", "DBT", "SYSADMIN"]
    "CREATE SCHEMA" = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "MONITOR"       = ["INGESTION", "SYSADMIN"]
    "OWNERSHIP"     = ["INGESTION"]
  }

  "INTEGRATE" = {
    "USAGE"         = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "MODIFY"        = ["DBT", "SYSADMIN"]
    "CREATE SCHEMA" = ["DBT", "DEVELOPER", "SYSADMIN"]
    "MONITOR"       = ["SYSADMIN"]
    "OWNERSHIP"     = ["SYSADMIN"]
  }

  "CLEAN" = {
    "USAGE"         = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "MODIFY"        = ["DBT", "SYSADMIN"]
    "CREATE SCHEMA" = ["DBT", "DEVELOPER", "SYSADMIN"]
    "MONITOR"       = ["SYSADMIN"]
    "OWNERSHIP"     = ["SYSADMIN"]
  }

  "NORMALIZE" = {
    "USAGE"         = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "MODIFY"        = ["DBT", "SYSADMIN"]
    "CREATE SCHEMA" = ["DBT", "DEVELOPER", "SYSADMIN"]
    "MONITOR"       = ["SYSADMIN"]
    "OWNERSHIP"     = ["SYSADMIN"]
  }

  "ANALYZE" = {
    "USAGE"         = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "MODIFY"        = ["DBT", "SYSADMIN"]
    "CREATE SCHEMA" = ["DBT", "DEVELOPER", "SYSADMIN"]
    "MONITOR"       = ["SYSADMIN"]
    "OWNERSHIP"     = ["SYSADMIN"]
  }
}

# Creates Schema Role Permissions based on the stages of the database and not necessarily the schema
schemas_and_roles = {

  "INGEST" = {
    "USAGE"            = ["ANALYST", "INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TABLE"     = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE VIEW"      = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE FUNCTION"  = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE PROCEDURE" = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STREAM"    = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TASK"      = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STAGE"     = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"        = ["INGESTION"]
  }

  "INTEGRATE" = {
    "USAGE"            = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TABLE"     = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE VIEW"      = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE FUNCTION"  = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE PROCEDURE" = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STREAM"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TASK"      = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STAGE"     = ["DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"        = ["SYSADMIN"]
  }

  "CLEAN" = {
    "USAGE"            = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TABLE"     = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE VIEW"      = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE FUNCTION"  = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE PROCEDURE" = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STREAM"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TASK"      = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STAGE"     = ["DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"        = ["SYSADMIN"]
  }

  "NORMALIZE" = {
    "USAGE"            = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TABLE"     = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE VIEW"      = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE FUNCTION"  = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE PROCEDURE" = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STREAM"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TASK"      = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STAGE"     = ["DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"        = ["SYSADMIN"]
  }

  "ANALYZE" = {
    "USAGE"            = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TABLE"     = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE VIEW"      = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE FUNCTION"  = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE PROCEDURE" = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STREAM"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE TASK"      = ["DBT", "DEVELOPER", "SYSADMIN"]
    "CREATE STAGE"     = ["DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"        = ["SYSADMIN"]
  }
}

# Table Role Permissions
## Remove the DELETE and TRUNCATE access from DEVELOPER for PROD?
tables_and_roles = {

  "INGEST" = {
    "SELECT"    = ["ANALYST", "INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "INSERT"    = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "UPDATE"    = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "DELETE"    = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "TRUNCATE"  = ["INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP" = ["INGESTION"]
  }

  "INTEGRATE" = {
    "SELECT"    = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "INSERT"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "UPDATE"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "DELETE"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "TRUNCATE"  = ["DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP" = ["SYSADMIN"]
  }

  "CLEAN" = {
    "SELECT"    = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "INSERT"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "UPDATE"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "DELETE"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "TRUNCATE"  = ["DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP" = ["SYSADMIN"]
  }

  "NORMALIZE" = {
    "SELECT"    = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "INSERT"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "UPDATE"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "DELETE"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "TRUNCATE"  = ["DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP" = ["SYSADMIN"]
  }

  "ANALYZE" = {
    "SELECT"    = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "INSERT"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "UPDATE"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "DELETE"    = ["DBT", "DEVELOPER", "SYSADMIN"]
    "TRUNCATE"  = ["DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP" = ["SYSADMIN"]
  }
}

# View Role Permissions
views_and_roles = {
  "INGEST" = {
    "SELECT"     = ["ANALYST", "INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "REFERENCES" = ["ANALYST", "INGESTION", "DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"  = ["INGESTION"]
  }

  "INTEGRATE" = {
    "SELECT"     = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "REFERENCES" = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"  = ["SYSADMIN"]
  }

  "CLEAN" = {
    "SELECT"     = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "REFERENCES" = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"  = ["SYSADMIN"]
  }

  "NORMALIZE" = {
    "SELECT"     = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "REFERENCES" = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"  = ["SYSADMIN"]
  }

  "ANALYZE" = {
    "SELECT"     = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "REFERENCES" = ["ANALYST", "DBT", "DEVELOPER", "SYSADMIN"]
    "OWNERSHIP"  = ["SYSADMIN"]
  }
}

# Stage Role to Parent Roles
role_to_roles = {
  "DEVELOPER" = ["DEVELOPER"],
  "ANALYST"   = ["ANALYST"],
  "SYSADMIN"  = ["SYSADMIN"],
  "INGESTION" = ["SYSADMIN"]
}
