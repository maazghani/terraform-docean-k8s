resource "digitalocean_database_cluster" "postgres_cluster" {
  name       = "dev"
  version    = "12"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  db_names   = [var.db_name]
}

resource "digitalocean_database_user" "db_user" {
  cluster_id = digitalocean_database_cluster.postgres_cluster.id
  name       = var.db_user
  password   = var.db_password
}

#resource "digitalocean_database_firewall" "db_firewall" {
# cluster_id = digitalocean_database_cluster.postgres_cluster.id
#}

#resource "digitalocean_database_firewall_rule" "db_firewall_rule" {
#    type  = "k8s"
#    value = var.allowed_sources
#  }
