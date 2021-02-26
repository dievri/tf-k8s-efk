resource "kubernetes_deployment" "apache" {
  metadata {
    name = "apache-httpd"
    labels = {
      app = "apache-httpd"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "apache-httpd"
      }
    }
    template {
      metadata {
        labels = {
          app = "apache-httpd"
        }
      }
      spec {
        container {
          image = "httpd"
          name  = "apache-httpd"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "200Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "apache" {
  wait_for_load_balancer = true
  metadata {
    name = "apache-httpd"
  }

  spec {
    selector = {
      app = "apache-httpd"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}