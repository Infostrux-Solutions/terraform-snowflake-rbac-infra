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
  "INGEST_WH"     = "Ingest"
  "DEV_WH"        = "Transform"
  "REPORTING_WH"  = "Serve"
  "MONITORING_WH" = "Monitor"
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