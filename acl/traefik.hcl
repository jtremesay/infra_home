namespace "*" {
  capabilities = ["read-job"]
}

agent {
  policy = "deny"
}

operator {
  policy = "deny"
}

quota {
  policy = "deny"
}

node {
  policy = "deny"
}

host_volume "*" {
  policy = "deny"
}