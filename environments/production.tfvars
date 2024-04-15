# Common
customer    = "infx"
domain      = "snowflake"
environment = "prod"
region      = "us-east-2"

create_parent_roles = true

default_tags = {
  OWNER         = "matt@infostrux.com"
  ENVIRONMENT   = "Production"
  CREATED_USING = "Terraform"
  SOURCE_CODE   = "terraform-snowflake-rbac-infra"
}

# Create tags
tags = {
  OWNER             = ["matt@infostrux.com"]
  ENVIRONMENT       = ["Development", "Production", "QA", "Stage"]
  CREATED_USING     = ["Python", "Terraform", "dbt"]
  SOURCE_CODE       = ["terraform-snowflake-rbac-infra"]
  WAREHOUSE_PURPOSE = ["Ingest", "Monitor", "Serve", "Transform"]
  DATA_LAYER        = ["Analyze", "Clean", "Ingest", "Integrate", "Normalize"]
}

# Snowflake
snowflake_role           = "SYSADMIN"
snowflake_account        = "aua12673"
snowflake_username       = "INFX_TERRAFORM"
snowflake_warehouse_size = "xsmall"

# User Creation
create_fivetran_user = true
create_datadog_user  = true

warehouse_auto_suspend = {
  "INGEST_WH"     = 120
  "MONITORING_WH" = 60
}
