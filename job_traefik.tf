resource "nomad_acl_policy" "traefik" {
    name = "traefik"
    rules_hcl = file("./acl/traefik.hcl")
}

resource "nomad_acl_token" "traefik" {
  name = "traefik"
  type = "client"
  policies = [ nomad_acl_policy.traefik.name ]
}

data "docker_registry_image" "traefik" {
    name = "traefik:3"
}

resource "nomad_job" "traefik" {
    jobspec = file("./jobs/traefik.hcl")
    hcl2 {
      vars = {
        "nomad_token": nomad_acl_token.traefik.secret_id,
        "traefik_image_digest": data.docker_registry_image.traefik.sha256_digest,
      }
    }
}