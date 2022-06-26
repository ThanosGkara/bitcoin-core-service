variable "stack" {
  description = "The Infrastructure grouping the TF placement belongs to"
  type        = string
  default     = "dev-ci"
}

variable "owner" {
  description = "Team that owns this resource"
  default     = "admin"
}

variable "env" {
  description = "The environment that this resource belongs to and is intended to be used"
  default     = "dev"
}