terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.40.0"
    }
  }
}

# Primary provider
provider "snowflake" {
  role     = var.snowflake_role
  account  = var.snowflake_account
  username = var.snowflake_username
  region   = var.snowflake_cloud
}

provider "snowflake" {
  alias    = "accountadmin"
  role     = "ACCOUNTADMIN"
  account  = var.snowflake_account
  username = var.snowflake_username
  region   = var.snowflake_cloud
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn     = var.aws_role_arn
  }

  default_tags {
    tags = var.default_tags
  }
}