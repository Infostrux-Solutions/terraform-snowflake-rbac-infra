terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.99.0"
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
  authenticator     = "JWT"
}

provider "snowflake" {
  alias             = "accountadmin"
  role              = "ACCOUNTADMIN"
  account_name      = var.snowflake_account
  organization_name = var.snowflake_org
  user              = var.snowflake_user
  authenticator     = "JWT"
}

provider "snowflake" {
  alias             = "securityadmin"
  role              = "SECURITYADMIN"
  account_name      = var.snowflake_account
  organization_name = var.snowflake_org
  user              = var.snowflake_user
  authenticator     = "JWT"
}

provider "snowflake" {
  alias             = "useradmin"
  role              = "USERADMIN"
  account_name      = var.snowflake_account
  organization_name = var.snowflake_org
  user              = var.snowflake_user
  authenticator     = "JWT"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}
