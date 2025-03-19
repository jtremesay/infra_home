resource "nomad_acl_token" "jtremesay" {
    name = "jtremesay"
    type = "management"
}

output "token_jtremesay" {
    sensitive = true
    value = nomad_acl_token.jtremesay.secret_id
}