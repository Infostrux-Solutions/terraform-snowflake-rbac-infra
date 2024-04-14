# Common
customer    = "infx"
domain      = "snowflake"
environment = "dev"
region      = "us-east-2"

create_parent_roles = false

# Tag values
default_tags = {
  OWNER         = "matt@infostrux.com"
  ENVIRONMENT   = "Development"
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
snowflake_role     = "SYSADMIN"
snowflake_account  = "aua12673"
snowflake_username = "INFX_TERRAFORM"
