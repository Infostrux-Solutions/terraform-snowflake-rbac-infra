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

variable "tags" {
  type        = list(map(string))
  description = "A key/value map of all the tags to apply to the resources."
  default     = [{}]
}

