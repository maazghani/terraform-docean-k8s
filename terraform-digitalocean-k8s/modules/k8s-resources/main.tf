resource "helm_release" "jupyter_lab" {
  name       = "jupyter-lab"
  chart      = "jupyterhub/jupyterhub"
  version    = "<specific_version>"
  namespace  = "default"
  # values = ["${file("../k8s-configs/helm-jupyter-lab.yaml")}"]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  chart      = "grafana/grafana"
  version    = "<specific_version>"
  namespace  = "monitoring"
  # values = ["${file("../k8s-configs/grafana.yaml")}"]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "prometheus-community/prometheus"
  version    = "<specific_version>"
  namespace  = "monitoring"
  # values = ["${file("../k8s-configs/prometheus.yaml")}"]
}