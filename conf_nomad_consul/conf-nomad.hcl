job "projet" {
  datacenters = ["aristide-briand"]

  group "frontend" {
    count = 1

    network {
      port "frontend" {
        static = 3000
        to = 3000
      }
    }
    task "frontend" {
      driver = "docker"
      config {
        image = "ghcr.io/tototriou/web:1.0.0"  #mettre l image créée en ligne
        ports = ["frontend"]
      }
    }
  }
  group "backend" {
    count = 1
    network {
      port "backend" {
        static = 8080
        to = 8080
      }
    }
    task "worker_backend" {
      driver = "docker"
      config {
        image = "ghcr.io/tototriou/worker:1.0.0"  #mettre l image créée en ligne
        ports = ["worker_backend"]
      }
    } 
  }
  group "hasher_proxy" {
    count = 3
    network {
      port "hasher_proxy" {
        static = 8080
        to = 8080
      }
    }
    task "hasher_proxy" {
      driver = "docker"
      config {
        image = "docker.io/library/haproxy"  #mettre l image créée en ligne
        ports = ["hasher_proxy"]
      }
      ressources {
        import = ["../haproxy.cfg"]
      }
    }
  }
}