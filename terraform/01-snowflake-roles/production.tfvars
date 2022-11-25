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
  SOURCE_CODE   = "data-terraform-snowflake-infrastructure"
}

# Snowflake
snowflake_role     = "SYSADMIN"
snowflake_account  = "aua12673"
snowflake_username = "INFX_TERRAFORM"
snowflake_cloud    = "" # blank for us-west-2 

# Roles
roles = [
  "DEVELOPER",
  "ANALYST",
  "INGESTION",
  "DBT",
  "SYSADMIN"
]