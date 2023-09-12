output "cluster_id" {
  value = digitalocean_kubernetes_cluster.do_cluster.id
}

output "cluster_ip_range" {
  value = digitalocean_kubernetes_cluster.do_cluster.cluster_subnet
}