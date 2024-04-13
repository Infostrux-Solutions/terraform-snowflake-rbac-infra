# Common
customer    = "infx"
domain      = "snowflake"
environment = "prod"
region      = "us-east-2"

# Tag values
default_tags = {
  OWNER         = "matt@infostrux.com"
  ENVIRONMENT   = "Production"
  CREATED_USING = "Terraform"
  SOURCE_CODE   = "terraform-snowflake-rbac-infra"
}

# Snowflake
snowflake_role     = "SYSADMIN"
snowflake_account  = "aua12673"
snowflake_username = "INFX_TERRAFORM"

# Roles
roles = [
  "DEVELOPER",
  "ANALYST",
  "INGESTION",
  "DBT",
  "SYSADMIN"
]
