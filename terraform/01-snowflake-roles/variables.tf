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

variable "tags" {
  description = "Tags and their allowed values for all Snowflake resources."
  type        = map(list(string))
  default     = {}
}

variable "comment" {
  description = "Comment to apply to all resources."
  type        = string
  default     = "Created by terraform"
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

variable "create_parent_roles" {
  type        = bool
  description = "Whether or not you want to create the parent roles (for production deployment only)"
  default     = false
}