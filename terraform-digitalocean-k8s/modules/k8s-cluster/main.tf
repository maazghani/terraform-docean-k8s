resource "digitalocean_kubernetes_cluster" "do_cluster" {
  name   = "dev"
  region = "sfo2"
  version = "1.24.6-do.0"

  node_pool {
    name       = "general-compute-pool"
    size       = var.general_compute_nodes.size
    node_count = var.general_compute_nodes.count
  }
}

resource "digitalocean_kubernetes_node_pool" "monitoring_pool" {
  cluster_id = digitalocean_kubernetes_cluster.do_cluster.id
  name       = "monitoring-pool"
  size       = var.monitoring_nodes.size
  node_count = var.monitoring_nodes.count
}