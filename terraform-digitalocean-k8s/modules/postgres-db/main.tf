resource "digitalocean_database_cluster" "postgres-cluster" {
  name       = "dev"
  engine     = "pg"
  version    = "12"
  size       = "db-s-1vcpu-1gb"
  region     = "sfo2"
  node_count = 1
  

  tags = ["k8s"]
}

resource "digitalocean_database_user" "db_user" {
  cluster_id = digitalocean_database_cluster.postgres-cluster.id
  name       = var.db_user
}

resource "digitalocean_database_firewall" "db_firewall" {
 cluster_id = digitalocean_database_cluster.postgres-cluster.id
 rule {
    type = "k8s"
    value = module.k8s_cluster.cluster_ip_range
 }
}


