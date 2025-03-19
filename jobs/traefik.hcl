variable "traefik_image_digest" {
  type = string
}

job "traefik" {
  namespace = "traefik"
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
      name     = "traefik-dashboard"
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
        image        = "traefik@${var.traefik_image_digest}"
        network_mode = "host"
        volumes = [
          "traefik_data:/data/",
          "local/config.yml:/etc/traefik/traefik.yml",
          "local/routes/:/etc/traefik/routes/",
        ]
      }

      template {
        data        = <<EOF
api:
  dashboard: true
  insecure: true

entrypoints:
  websecure:
    address: ":{{ env "NOMAD_PORT_https" }}"

  web:
    address: ":{{ env "NOMAD_PORT_http" }}"
    http:
      redirections:
        entryPoint:
          to: "websecure"
          scheme: "https"
          permanent: true

providers:
  nomad:
    exposedByDefault: false
    endpoint:
      token: "{{ with nomadVar "nomad/jobs/traefik/traefik/traefik" }}{{ .nomad_token }}{{ end }}"
    namespaces:
      - "default"
      - "traefik"
  file:
    directory: "/etc/traefik/routes/"

log:
  level: "DEBUG"

certificatesResolvers:
  leresolver:
    acme:
      httpChallenge:
        entryPoint: web
      email: "jonathan.tremesaygues@slaanesh.org"
      storage: "/data/acme.json"
EOF
        destination = "local/config.yml"
      }

      template {
        data = <<EOF
http:
  routers:
    nomad:
      rule: "Host(`nomad.home.jtremesay.org`)"
      service: nomad
      tls:
        certresolver: "leresolver"

  services:
    nomad:
      loadBalancer:
        servers:
          - url: "http://localhost:4646"
EOF
        destination = "local/routes/nomad.yml"
      }
    }
  }
}