resource "nomad_acl_policy" "traefik" {
    name = "traefik"
    rules_hcl = file("./acl/traefik.hcl")
}

resource "nomad_acl_token" "traefik" {
  name = "traefik"
  type = "client"
  policies = [ nomad_acl_policy.traefik.name ]
}

resource "nomad_job" "traefik" {
    jobspec = file("./jobs/traefik.hcl")
    hcl2 {
      vars = {
        "nomad_token": nomad_acl_token.traefik.secret_id
      }
    }
}