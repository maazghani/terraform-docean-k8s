resource "helm_release" "jupyter_lab" {
  name       = "jupyter-lab"
  chart      = "jupyterhub/jupyterhub"
  version    = "latest"
  namespace  = "default"
}

resource "helm_release" "grafana" {
  name       = "grafana"
  chart      = "grafana/grafana"
  version    = "latest"
  namespace  = "monitoring"
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "prometheus-community/prometheus"
  version    = "latest"
  namespace  = "monitoring"
}

resource "namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}