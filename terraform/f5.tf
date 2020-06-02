resource "random_string" "password" {
  length  = 10
  special = false
}

data "aws_ami" "f5_ami" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = [var.f5_ami_search_name]
  }
}
resource "aws_instance" "f5" {

  ami                         = data.aws_ami.f5_ami.id
  iam_instance_profile        = aws_iam_instance_profile.bigip_profile.name

  instance_type               = "m5.xlarge"
  private_ip                  = "10.0.0.200"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.f5.id]
  user_data                   = data.template_file.f5_init.rendered
  key_name                    = aws_key_pair.demo.key_name
  root_block_device { delete_on_termination = true }

  tags = {
    Name = "${var.prefix}-f5"
    Env  = "consul"
  }

  provisioner "local-exec" {
    command = "while [[ \"$(curl -skiu ${var.username}:${random_string.password.result} https://${self.public_ip}:${var.port}/mgmt/shared/appsvcs/declare | grep -Eoh \"^HTTP/1.1 204\")\" != \"HTTP/1.1 204\" ]]; do sleep 5; done"
  }
}

data "template_file" "f5_init" {
  template = "${file("../scripts/f5_onboard.tmpl")}"

  vars = {
    DO_URL       = "${var.DO_URL}",
    AS3_URL      = "${var.AS3_URL}",
    TS_URL       = "${var.TS_URL}",
    CFE_URL      = "${var.CFE_URL}",
    libs_dir     = "${var.libs_dir}",
    onboard_log  = "${var.onboard_log}",
    password     = "${random_string.password.result}"
  }
}