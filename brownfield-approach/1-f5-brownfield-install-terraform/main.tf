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

resource "bigip_ltm_virtual_server" "webapp" {
  name        = "/Common/webapp"
  destination = "10.0.0.200"
  port        = 8080
  pool        = bigip_ltm_pool.webapp-pool.name
  source_address_translation = "automap"
  ip_protocol = "tcp"
  profiles    = ["/Common/http", "/Common/oneconnect", "/Common/tcp"]
}

resource "bigip_ltm_pool" "webapp-pool" {
  name                = "/Common/webapp-pool"
  load_balancing_mode = "round-robin"
  description         = "Pool for webapp manual"
  monitors            = [bigip_ltm_monitor.monitor.name]
  allow_snat          = "yes"
  allow_nat           = "yes"
}

resource "bigip_ltm_pool_attachment" "node1-attach" {
  pool = bigip_ltm_pool.webapp-pool.name
  node = "/Common/10.0.0.11:80"
}

resource "bigip_ltm_pool_attachment" "node2-attach" {
  pool = bigip_ltm_pool.webapp-pool.name
  node = "/Common/10.0.0.78:80"
}

resource "bigip_ltm_monitor" "monitor" {
  name     = "/Common/my_monitor"
  parent   = "/Common/http"
  send     = "GET"
}