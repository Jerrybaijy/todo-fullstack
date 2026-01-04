# 添加 Helm Provider
provider "helm" {
  kubernetes = {
    host                   = "https://${google_container_cluster.my_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
  }
}

# 创建 Argo CD 命名空间
resource "kubernetes_namespace_v1" "argocd_ns" {
  metadata {
    name = "argocd"
  }
  depends_on = [google_container_node_pool.my_node_pool]
}

# 安装 Argo CD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argocd_ns.metadata[0].name
  version    = "7.7.1"

  set = [
    # 设置服务类型为 LoadBalancer
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    },
    # 允许 HTTP 访问
    {
      name  = "server.extraArgs"
      value = "{--insecure}"
    },
    # 仅允许自己的 IP 访问
    {
      name  = "server.service.loadBalancerSourceRanges"
      value = "{${var.my_external_ip}/32}"
    }
  ]
}

# 获取 Argo CD 服务数据 (用于 Output)
data "kubernetes_service_v1" "argocd_server" {
  metadata {
    name      = "${helm_release.argocd.name}-server"
    namespace = helm_release.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}

# 获取初始密码 Secret 数据
data "kubernetes_secret_v1" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = helm_release.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}

# 输出 Argo CD 公网 IP
output "argocd_loadbalancer_ip" {
  description = "Argo CD UI 的公网访问 IP"
  value       = data.kubernetes_service_v1.argocd_server.status[0].load_balancer[0].ingress[0].ip
}

# 输出初始管理员密码
output "argocd_initial_admin_password" {
  description = "Argo CD 的初始管理员密码 (用户名为 admin)"
  value       = data.kubernetes_secret_v1.argocd_initial_admin_secret.data["password"]
  sensitive   = true
}
