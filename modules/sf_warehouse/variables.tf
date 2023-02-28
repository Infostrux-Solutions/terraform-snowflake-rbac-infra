variable "name" {
  type        = string
  description = "The name for the warehouse to create in snowflake."
}

variable "comment" {
  type        = string
  description = "A comment to add to the resource in snowflake."
  default     = "created by terraform"
}

variable "warehouse_size" {
  type        = string
  description = "The size of the Snowflake warehouse that we will be utilizing to run queries."
}

variable "warehouse_auto_suspend" {
  type        = number
  description = "The auto_suspend (seconds) of the Snowflake warehouse that we will be utilizing to run queries."
  default     = 600
}

variable "tags" {
  type        = map(string)
  description = "A key/value map of all the tags to apply to the resources."
  default     = {}
}

variable "tags_db" {
  type        = string
  description = "The database to retrieve tags from."
  default     = "DB_TAGS"
}

variable "tags_schema" {
  type        = string
  description = "The schema to retrieve tags from."
  default     = "TAGS"
}

variable "min_cluster_count" {
  type        = string
  description = "The min cluster count to set for the warehouses."
  default     = 1
}

variable "max_cluster_count" {
  type        = string
  description = "The max cluster count to set for the warehouses."
  default     = 10
}
