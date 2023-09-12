variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "region" {
  description = "The region where the cluster will be created"
  type        = string
}

variable "general_compute_nodes" {
  description = "Configuration for the general compute node pool"
  type = object({
    size  = string
    count = number
  })
}
variable "monitoring_nodes" {
  description = "Configuration for the monitoring node pool"
  type = object({
    size  = string
    count = number
  })
}