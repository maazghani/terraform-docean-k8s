# variables.tf 
variable "cluster_name" {
  description = "The name of the cluster"
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
variable "region" {
  description = "The region where the database will be created"
  type        = string
}
variable "general_compute_size" {
  description = "The size of the general compute nodes"
  type        = string
}
variable "general_compute_count" {
  description = "The number of general compute nodes"
  type        = number
}
variable "monitoring_node_size" {
  description = "The size of the monitoring nodes"
  type        = string
}
variable "monitoring_nodes_count" {
  description = "The number of monitoring nodes"
  type        = number
}
