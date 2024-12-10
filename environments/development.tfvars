# Common
project     = "marketing"
environment = "dev"
region      = "us-east-2"

default_tags = {
  OWNER         = "matt@infostrux.com"
  ENVIRONMENT   = "Development"
  CREATED_USING = "Terraform"
  SOURCE_CODE   = "terraform-snowflake-rbac-infra"
}

# Snowflake
snowflake_role    = "SYSADMIN"
snowflake_account = "IAA23611"
snowflake_org     = "UMNXXYZ"
snowflake_user    = "TERRAFORM"

# Configuration
config_dir = "./config"
