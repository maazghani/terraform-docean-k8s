resource "digitalocean_project" "k3s_cluster" {
  name        = "k3s-cluster"
  description = "k3s Cluster"
  purpose     = "HA K3s (Kubernetes) Cluster"
  environment = "Development"
}
resource "digitalocean_droplet" "k3s_server" {
  count = var.server_count - 1
  name  = "k3s-server-${var.region}-${random_id.server_node_id[count.index + 1].hex}-${count.index + 2}"

  image      = "ubuntu-20-04-x64"
  tags       = [digitalocean_tag.server.id]
  region     = var.region
  size       = var.server_size
  monitoring = true
  vpc_uuid   = digitalocean_vpc.k3s_vpc.id
  ssh_keys   = var.ssh_key_fingerprints
  user_data = templatefile("${path.module}/user_data/ks3_server.sh", {
    k3s_channel     = var.k3s_channel
    k3s_token       = random_password.k3s_token.result
    flannel_backend = var.flannel_backend
    k3s_lb_ip       = digitalocean_loadbalancer.k3s_lb.ip
    db_cluster_uri  = local.db_cluster_uri
    critical_taint  = local.taint_critical
    enable_traefik  = local.enable_traefik
  })
  depends_on = [
    digitalocean_droplet.k3s_server_init
  ]
}

resource "random_password" "k3s_token" {
  length  = 48
  upper   = false
  special = false
}

resource "digitalocean_project_resources" "k3s_server_nodes" {
  count   = var.server_count - 1
  project = digitalocean_project.k3s_cluster.id
  resources = [
    digitalocean_droplet.k3s_server[count.index].urn,
  ]
}

resource "digitalocean_droplet" "k3s_server_init" {
  count = 1
  name  = "k3s-server-${var.region}-${random_id.server_node_id[count.index].hex}-1"

  image      = "ubuntu-20-04-x64"
  tags       = [digitalocean_tag.server.id]
  region     = var.region
  size       = var.server_size
  monitoring = true
  vpc_uuid   = digitalocean_vpc.k3s_vpc.id
  ssh_keys   = var.ssh_key_fingerprints
  user_data = templatefile("${path.module}/user_data/ks3_server_init.sh", {
    k3s_channel         = var.k3s_channel
    k3s_token           = random_password.k3s_token.result
    do_token            = var.do_token
    do_cluster_vpc_id   = digitalocean_vpc.k3s_vpc.id
    do_ccm_fw_name      = digitalocean_firewall.ccm_firewall.name
    do_ccm_fw_tags      = local.ccm_fw_tags
    flannel_backend     = var.flannel_backend
    k3s_lb_ip           = digitalocean_loadbalancer.k3s_lb.ip
    db_cluster_uri      = local.db_cluster_uri
    critical_taint      = local.taint_critical
    ccm_manifest        = base64gzip(file("${path.module}/manifests/do-ccm.yaml"))
    csi_crds_manifest   = base64gzip(file("${path.module}/manifests/do-csi/crds.yaml"))
    csi_driver_manifest = base64gzip(file("${path.module}/manifests/do-csi/driver.yaml"))
    csi_sc_manifest     = base64gzip(file("${path.module}/manifests/do-csi/snapshot-controller.yaml"))
    enable_traefik      = local.enable_traefik
    traefik_ingress = var.ingress == "traefik" ? base64gzip(templatefile("${path.module}/manifests/traefik-custom.yaml", {
      traefik_ver = var.traefik_version
    })) : ""
    nginx_ingress         = var.ingress == "nginx" ? base64gzip(file("${path.module}/manifests/ingress-nginx.yaml")) : ""
    kong_ingress_postgres = var.ingress == "kong_pg" ? base64gzip(file("${path.module}/manifests/kong-all-in-one-postgres.yaml")) : ""
    kong_ingress_dbless   = var.ingress == "kong" ? base64gzip(file("${path.module}/manifests/kong-all-in-one-dbless.yaml")) : ""
    k8s_dashboard = var.k8s_dashboard == true ? base64gzip(templatefile("${path.module}/manifests/k8s-dashboard.yaml", {
      k8s_dash_ver = var.k8s_dashboard_version
    })) : ""
    cert_manager     = var.cert_manager == true ? local.install_cert_manager : ""
    sys_upgrade_ctrl = var.sys_upgrade_ctrl == true ? base64gzip(file("${path.module}/manifests/system-upgrade-controller.yaml")) : ""
  })
}

resource "digitalocean_project_resources" "k3s_init_server_node" {
  count   = 1
  project = digitalocean_project.k3s_cluster.id
  resources = [
    digitalocean_droplet.k3s_server_init[count.index].urn,
  ]
}
resource "digitalocean_droplet" "k3s_agent" {
  count = var.agent_count
  name  = "k3s-agent-${var.region}-${random_id.agent_node_id[count.index].hex}-${count.index + 1}"

  image      = "ubuntu-20-04-x64"
  tags       = [digitalocean_tag.agent.id]
  region     = var.region
  size       = var.agent_size
  monitoring = true
  vpc_uuid   = digitalocean_vpc.k3s_vpc.id
  ssh_keys   = var.ssh_key_fingerprints
  user_data = templatefile("${path.module}/user_data/k3s_agent.sh", {
    k3s_channel = var.k3s_channel
    k3s_token   = random_password.k3s_token.result
    k3s_lb_ip   = digitalocean_loadbalancer.k3s_lb.ip
  })
  depends_on = [ digitalocean_droplet.k3s_server_init ]
}


resource "digitalocean_project_resources" "k3s_agent_nodes" {
  count   = var.agent_count
  project = digitalocean_project.k3s_cluster.id
  resources = [
    digitalocean_droplet.k3s_agent[count.index].urn,
  ]
  depends_on = [ digitalocean_database_cluster.k3s ]
}

resource "random_id" "server_node_id" {
  byte_length = 2
  count       = var.server_count
}

resource "random_id" "agent_node_id" {
  byte_length = 2
  count       = var.agent_count
}
resource "digitalocean_loadbalancer" "k3s_lb" {
  name     = "k3s-api-loadbalancer"
  region   = var.region
  vpc_uuid = digitalocean_vpc.k3s_vpc.id

  forwarding_rule {
    tls_passthrough = true
    entry_port      = 6443
    entry_protocol  = "https"

    target_port     = 6443
    target_protocol = "https"
  }

  healthcheck {
    port     = 6443
    protocol = "tcp"
  }

  droplet_tag = digitalocean_tag.server.name
  depends_on = [ digitalocean_project.k3s_cluster ]
}

resource "digitalocean_project_resources" "k3s_api_server_lb" {
  project = digitalocean_project.k3s_cluster.id
  resources = [
    digitalocean_loadbalancer.k3s_lb.urn
  ]
  depends_on = [ digitalocean_loadbalancer.k3s_lb ]
}

# Server tag
resource "digitalocean_tag" "server" {
  name = var.server_tag
}

# Agent tag
resource "digitalocean_tag" "agent" {
  name = var.agent_tag
}