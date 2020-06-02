data "terraform_remote_state" "aws_demo" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform/terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-2"
  # region = "eu-central-1"
}

provider "bigip" {
  address  = data.terraform_remote_state.aws_demo.outputs.f5_ui
  username = data.terraform_remote_state.aws_demo.outputs.f5_username
  password = data.terraform_remote_state.aws_demo.outputs.f5_password
}


# deploy application using as3
resource "bigip_as3" "nginx" {
  as3_json      = file("nginx.json")
  tenant_filter = "Consul_SD"
}
