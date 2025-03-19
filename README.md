# README

## Bootstrap

https://developer.hashicorp.com/nomad/tutorials/access-control/access-control-bootstrap

```fish
set -x NOMAD_ADDR=http://home.jtremesay.org:4646

# Bootstrap the ACL system and get bootstrap secret id
nomad acl bootstrap
set -x NOMAD_TOKEN <bootstrap secret id>

# Apply the config
tofu init
tofu apply

# Get your token
tofu output token_jtremesay
set -x NOMAD_TOKEN <your token>
```