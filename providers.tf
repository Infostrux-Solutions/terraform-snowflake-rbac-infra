terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.88.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Primary provider
provider "snowflake" {
  role          = var.snowflake_role
  account       = var.snowflake_account
  user          = var.snowflake_user
  authenticator = "JWT"
}

provider "snowflake" {
  alias         = "accountadmin"
  role          = "ACCOUNTADMIN"
  account       = var.snowflake_account
  user          = var.snowflake_user
  authenticator = "JWT"
}

provider "snowflake" {
  alias         = "securityadmin"
  role          = "SECURITYADMIN"
  account       = var.snowflake_account
  user          = var.snowflake_user
  authenticator = "JWT"
}

provider "snowflake" {
  alias         = "useradmin"
  role          = "USERADMIN"
  account       = var.snowflake_account
  user          = var.snowflake_user
  authenticator = "JWT"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}
