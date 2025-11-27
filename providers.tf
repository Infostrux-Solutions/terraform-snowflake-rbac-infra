terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "2.7.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

# Primary provider
provider "snowflake" {
  role              = var.snowflake_role
  account_name      = var.snowflake_account
  organization_name = var.snowflake_org
  user              = var.snowflake_user
  authenticator     = "SNOWFLAKE_JWT"
  port              = 443
}

provider "snowflake" {
  alias                    = "accountadmin"
  role                     = "ACCOUNTADMIN"
  account_name             = var.snowflake_account
  organization_name        = var.snowflake_org
  user                     = var.snowflake_user
  authenticator            = "SNOWFLAKE_JWT"
  port                     = 443
}
provider "snowflake" {
  alias             = "securityadmin"
  role              = "SECURITYADMIN"
  account_name      = var.snowflake_account
  organization_name = var.snowflake_org
  user              = var.snowflake_user
  authenticator     = "SNOWFLAKE_JWT"
  port              = 443
}

provider "snowflake" {
  alias             = "useradmin"
  role              = "USERADMIN"
  account_name      = var.snowflake_account
  organization_name = var.snowflake_org
  user              = var.snowflake_user
  authenticator     = "SNOWFLAKE_JWT"
  port              = 443
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.default_tags
  }
}
