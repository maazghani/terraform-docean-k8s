# Call the Kubernetes Cluster module
module "do_k8s_cluster" {
  source = "./modules/k8s-cluster"

  # Variables specific to the Kubernetes cluster module
  cluster_name = var.cluster_name
  region       = var.region

  # Node pool configurations
  general_compute_nodes = {
    size  = var.general_compute_size
    count = var.general_compute_count
  }

  monitoring_nodes = {
    size  = var.monitoring_node_size
    count = var.monitoring_node_count
  }
}

# Call the Kubernetes Resources module
module "k8s_resources" {
  source = "./modules/k8s-resources"

  # Variables specific to the Kubernetes resources module
  cluster_id = module.do_k8s_cluster.cluster_id
}

# Call the PostgreSQL Database module
module "postgres_db" {
  source = "./modules/postgres-db"

  # Variables specific to the PostgreSQL database module
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password

  # Allow only the Kubernetes cluster to access the database
  allowed_sources = [module.do_k8s_cluster.cluster_ip_range]
}