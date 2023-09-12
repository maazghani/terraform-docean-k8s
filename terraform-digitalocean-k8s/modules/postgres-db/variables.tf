variable "db_name" {
  description = "The name of the PostgreSQL database"
  type        = string
  default     = "postgres" 
}

variable "db_user" {
  description = "The username for the PostgreSQL database"
  type        = string
}

variable "db_password" {
  description = "The password for the PostgreSQL database user"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region where the database will be created"
  type        = string
}

variable "allowed_sources" {
  description = "List of sources allowed to access the database"
  type        = list(string)
f