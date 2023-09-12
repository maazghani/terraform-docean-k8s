resource "digitalocean_kubernetes_cluster" "do_cluster" {
  name   = var.cluster_name
  region = var.region

  node_pool {
    name       = "general-compute-pool"
    size       = var.general_compute_nodes.size
    node_count = var.general_compute_nodes.count
  }

  node_pool {
    name       = "monitoring-pool"
    size       = var.monitoring_nodes.size
    node_count = var.monitoring_nodes.count
  }
}