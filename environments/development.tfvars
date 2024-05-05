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
snowflake_account = "aua12673"
snowflake_user    = "TERRAFORM"

# User Creation
create_fivetran_user = true