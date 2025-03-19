variable "nomad_token" {
  type = string
}

job "traefik" {
  type = "service"

  group "traefik" {
    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
    }

    service {
      name     = "traefik-http"
      provider = "nomad"
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik_dashboard.rule=Host(`traefik.home.jtremesay.org`)",
        "traefik.http.routers.traefik_dashboard.service=api@internal",
        "traefik.http.routers.traefik_dashboard.tls.certresolver=leresolver",
      ]
    }

    task "traefik" {
      driver = "docker"
      config {
        image = "traefik:3"
        args = [
          "--api",
          "--api.dashboard",
          "--api.insecure",
          "--entrypoints.websecure.address=:${NOMAD_PORT_https}",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.web.http.redirections.entrypoint.to=websecure",
          "--entrypoints.web.http.redirections.entrypoint.scheme=https",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.token=${var.nomad_token}",
          "--log.level=info",
          "--certificatesresolvers.leresolver.acme.httpchallenge=true",
          "--certificatesresolvers.leresolver.acme.email=jonathan.tremesaygues@slaanesh.org",
          "--certificatesresolvers.leresolver.acme.storage=/data/acme.json",
          "--certificatesresolvers.leresolver.acme.httpchallenge.entrypoint=web",
        ]
        network_mode = "host"
        volumes = [
          "traefik_data:/data"
        ]
      }
    }
  }
}