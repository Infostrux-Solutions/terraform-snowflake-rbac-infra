# Common
project     = "marketing"
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
  OWNER         = ["matt@infostrux.com"]
  ENVIRONMENT   = ["Development", "Production", "QA", "Stage"]
  CREATED_USING = ["Python", "Terraform", "dbt"]
  SOURCE_CODE   = ["terraform-snowflake-rbac-infra"]
}

# Snowflake
snowflake_role    = "SYSADMIN"
snowflake_account = "IAA23611"
snowflake_org     = "UMNXXYZ"
snowflake_user    = "TERRAFORM"

# Configuration
config_dir = "./config"
