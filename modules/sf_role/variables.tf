# Role
variable "name" {
  type        = string
  description = "name of the database"
}

variable "comment" {
  type        = string
  description = "database comment"
  default     = "created by terraform"
}

variable "grant_to_roles" {
  type        = string
  description = "Allow roles in this list to assume the role that will be created."
  default     = "none"
}

variable "tags" {
  type        = list(map(string))
  description = "A key/value map of all the tags to apply to the resources."
  default     = [{}]
}

