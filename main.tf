terraform {
  required_providers {
    docker = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "nomad" {
  address = "http://home.jtremesay.org:4646"
}

provider "docker" {}