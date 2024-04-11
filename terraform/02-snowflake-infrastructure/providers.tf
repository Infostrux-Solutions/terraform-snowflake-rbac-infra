terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.88.0"
    }
  }
}

# Primary provider
provider "snowflake" {
  role          = var.snowflake_role
  account       = var.snowflake_account
  user          = var.snowflake_username
  region        = var.snowflake_cloud
  authenticator = "JWT"
}

provider "snowflake" {
  alias         = "tag_securityadmin"
  role          = "TAG_SECURITYADMIN"
  account       = var.snowflake_account
  user          = var.snowflake_username
  region        = var.snowflake_cloud
  authenticator = "JWT"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}
