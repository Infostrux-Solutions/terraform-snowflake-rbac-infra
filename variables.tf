# Common
variable "project" {
  type        = string
  description = "The name of the project, for naming and tagging purposes"
  default     = ""
}

variable "environment" {
  type        = string
  description = "The name of the environment we are deploying, for environment separation and naming purposes"
}

variable "region" {
  type        = string
  description = "The AWS region that we will deploy into, as well as for naming purposes"
}

variable "default_tags" {
  description = "Default tags to apply to all Snowflake resources"
  type        = map(string)
}

variable "tags" {
  description = "Tags and their allowed values to create in Snowflake. This will also create a database and schema to house the tags"
  type        = map(list(string))
  default     = {}
}

variable "comment" {
  description = "A comment to apply to all resources"
  type        = string
  default     = "Created by terraform"
}

variable "governance_database_name" {
  description = "The name to set for governance database"
  type        = string
  default     = "GOVERNANCE"
}

variable "tags_schema_name" {
  description = "The name to set for tags schema"
  type        = string
  default     = "TAGS"
}

variable "tag_admin_role" {
  description = "The name to set for the tag admin"
  type        = string
  default     = "TAG_ADMIN"
}

# Snowflake
variable "snowflake_role" {
  type        = string
  description = "The role in Snowflake that we will use to deploy by default"
}

variable "snowflake_account" {
  type        = string
  description = "The name of the Snowflake account that we will be deploying into"
}

variable "snowflake_user" {
  type        = string
  description = "The name of the Snowflake user that we will be utilizing to deploy into the snowflake_account"
}

variable "default_warehouse_size" {
  type        = string
  description = "The size of the Snowflake warehouse that we will be utilizing to run queries in the snowflake_account"
  default     = "xsmall"
}

variable "default_warehouse_auto_suspend" {
  type        = number
  description = "The auto_suspend (seconds) of the Snowflake warehouse that we will be utilizing to run queries in the snowflake_account"
  default     = 600
}

variable "create_fivetran_user" {
  type        = bool
  description = "Create the fivetran user (true|false)"
  default     = false
}

variable "snowflake_fivetran_private_key" {
  type        = string
  description = "The snowflake user private key to set for fivetran ingestion"
  default     = ""
  sensitive   = true
}

variable "create_datadog_user" {
  type        = bool
  description = "Create the datadog user (true|false)"
  default     = false
}

variable "snowflake_datadog_private_key" {
  type        = string
  description = "The snowflake user private key to set for datadog monitoring"
  default     = ""
  sensitive   = true
}

variable "create_dbt_user" {
  type        = bool
  description = "Create the dbt user (true|false)"
  default     = false
}

variable "snowflake_dbt_private_key" {
  type        = string
  description = "The snowflake user private key to set for dbt transformations"
  default     = ""
  sensitive   = true
}

variable "create_reporting_user" {
  type        = bool
  description = "Create the reporting user (true|false)"
  default     = false
}

variable "snowflake_reporting_private_key" {
  type        = string
  description = "The snowflake user private key to set for reporting user (bi)"
  default     = ""
  sensitive   = true
}

variable "always_apply" {
  type        = bool
  description = "Toggle to always apply on all objects. Used for when there are changes to the grants that need to be retroatively granted to roles"
  default     = false
}

variable "create_parent_roles" {
  type        = bool
  description = "Whether or not you want to create the parent roles (for production deployment only)"
  default     = false
}