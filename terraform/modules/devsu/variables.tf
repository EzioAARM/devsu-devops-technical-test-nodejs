variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "environment" {
  description = "The environment for the resources"
  type        = string
}
