terraform {
  required_providers {
    bigip = "= 1.2.0"
  }
}

data "terraform_remote_state" "aws_demo" {
  backend = "local"

  config = {
    path = "${path.module}/../../terraform/terraform.tfstate"
  }
}

provider "bigip" {
  address  = data.terraform_remote_state.aws_demo.outputs.f5_ui
  username = data.terraform_remote_state.aws_demo.outputs.f5_username
  password = data.terraform_remote_state.aws_demo.outputs.f5_password
}

# deploy application using as3
resource "bigip_as3" "nginx" {
  # as3_json    = "${file("nginx.json")}"
  as3_json = templatefile("nginx.tpl", {
    certificate = jsonencode(vault_pki_secret_backend_cert.f5-cert.certificate),
    privatekey  = jsonencode(vault_pki_secret_backend_cert.f5-cert.private_key)
  })
  tenant_filter = "consul_sd"
}