# Common
variable "customer" {
  type        = string
  description = "The name of the customer, for naming and tagging purposes."
}

variable "domain" {
  type        = string
  description = "The project name, for naming and tagging purposes."
}

variable "environment" {
  type        = string
  description = "The name of the environment we are deploying, for environment separation and naming purposes."
}

variable "region" {
  type        = string
  description = "The AWS region that we will deploy into, as well as for naming purposes."
}

variable "default_tags" {
  description = "Default tags for all Snowflake resources."
  type        = map(string)
}

variable "warehouse_tags" {
  description = "Warehouse specific tags for Snowflake resources."
  type        = map(string)
}

# Snowflake
variable "snowflake_role" {
  type        = string
  description = "The role in Snowflake that we will use to deploy."
}
variable "snowflake_account" {
  type        = string
  description = "The name of the Snowflake account that we will be deploying into."
}

variable "snowflake_username" {
  type        = string
  description = "The name of the Snowflake user that we will be utilizing to deploy into the snowflake_account."
}

variable "snowflake_warehouse_size" {
  type        = string
  description = "The size of the Snowflake warehouse that we will be utilizing to run queries in the snowflake_account."
}

variable "snowflake_cloud" {
  type        = string
  description = "The region and cloud that is hosting Snowflake LEAVE BLANK FOR us-west-2 (us-east-1.aws)"
  default     = ""
}

# Resource, Roles and Permissions
variable "warehouses_and_roles" {
  type        = map(map(any))
  description = "The first map is the warehouse that will be created, the inner map is the permission we are assigning (grant), and the inner list are the roles we are granting access to the permission."
}

variable "dbs_and_roles" {
  type        = map(map(any))
  description = "The first map is the database that will be created, the inner map is the permission we are assigning (grant), and the inner list are the roles we are granting access to the permission."
}

variable "create_schemas" {
  type        = map(any)
  description = "A mapping of existing databases and the schema to create in the existing db (Ex {\"EXISTING_DB\" = \"NEW_SCHEMA\"})."
  default     = {}
}

variable "schemas_and_roles" {
  type        = map(map(any))
  description = "A mapping of schema permissions {map} to target roles [list]. (The outer most {map} is not currently used)."
}

variable "tables_and_roles" {
  type        = map(map(any))
  description = "A mapping of table permissions {map} to the target roles [list]. (The outer most {map} is not currently used)."
}

variable "views_and_roles" {
  type        = map(map(any))
  description = "A mapping of the view permissions {map} to the target roles [list]. (The outer most {map} is not currently used)."
}

variable "role_to_roles" {
  type        = map(list(string))
  description = "A mapping of the roles created for each stage (Ex. DEV_INGEST_SYSADMIN) and the role(s) to inherit their permissions (Ex. SYSADMIN)."
}