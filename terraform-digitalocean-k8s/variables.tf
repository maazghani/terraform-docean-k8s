# variables.tf 
  
variable "cluster_id" {
  description = "The ID of the Kubernetes cluster"
  type        = string
}
variable "db_name" {
  description = "The name of the database"
  type        = string
}
variable "db_user" {
  description = "The name of the database user"
  type        = string
}

variable "db_password" {
  description = "The password for the database user"
  type        = string
}

#variable "allowed_sources" {
 # description = "The list of IP ranges allowed to access the database"
  #type        = list(string)
#}
