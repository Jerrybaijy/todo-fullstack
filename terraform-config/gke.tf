# --- Cluster 配置 ---

# cluster 配置
resource "google_container_cluster" "todo_cluster" {
  name     = "todo-cluster"
  location = var.zone

  # 关闭防止误删
  deletion_protection = false

  # 我们在这里删除默认节点池，并创建一个独立的节点池
  remove_default_node_pool = true
  initial_node_count       = 1

  # 启用 Workload Identity，这是安全连接的关键
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# node 配置
resource "google_container_node_pool" "primary_nodes" {
  name       = "todo-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.todo_cluster.name
  node_count = 2 # 对应 --num-nodes=2

  autoscaling {
    min_node_count = 1 # 对应 --min-nodes=1
    max_node_count = 5 # 对应 --max-nodes=5
  }

  node_config {
    machine_type = "e2-medium"   # 对应 --machine-type
    disk_type    = "pd-standard" # 对应 --disk-type
    disk_size_gb = 40            # 对应 --disk-size=40

    # 启用 GKE 节点的 Workload Identity 
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # 对应 --scopes=cloud-platform
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}