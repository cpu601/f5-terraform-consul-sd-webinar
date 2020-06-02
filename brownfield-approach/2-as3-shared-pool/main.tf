terraform {
  required_providers {
    bigip = "= 1.1.2"
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

# deploy shared webapp-pool using as3
resource "bigip_as3" "nginx" {
  as3_json    = file("nginx-pool.json")
  tenant_name = "consul"
}