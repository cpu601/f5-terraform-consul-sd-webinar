resource "aws_instance" "vault" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "m5.large"
  private_ip             = "10.0.0.130"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = ["${aws_security_group.vault.id}"]
  key_name = aws_key_pair.demo.key_name
  tags = {
    Name = "${var.prefix}-vault"
    Env  = "vault"
  }
}

module "install_vault" {
  source          = "git::https://github.com/timarenz/terraform-ssh-vault.git?ref=v0.1.0"
  host            = aws_instance.vault.public_ip
  username        = "ubuntu"
  ssh_private_key = tls_private_key.demo.private_key_pem
  vault_version   = "1.4.2"
  address         = "${aws_instance.vault.private_ip}:8200"
}

resource "null_resource" "vault_init" {
  depends_on = [module.install_vault]
  provisioner "local-exec" {
    command = <<EOT
      ./../scripts/vault-init.sh
      ./../scripts/vault-unseal.sh
   EOT

    environment = {
      VAULT_ADDR = "${aws_instance.vault.public_ip}:8200"
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f vault.key vault.token"
  }
}

data "local_file" "vault_token" {
  depends_on = [null_resource.vault_init]
  filename   = "vault.token"
}

data "template_file" "tfvars-vault" {
  template = "${file("../as3-secure/1-vault-pki/terraform.tfvars.example")}"
  vars = {
    vault-address = "http://${aws_instance.vault.public_ip}:8200",
    vault-token   = "${data.local_file.vault_token.content}"
  }
}

resource "local_file" "tfvars-vault" {
  content  = data.template_file.tfvars-vault.rendered
  filename = "../as3-secure/1-vault-pki/terraform.tfvars"
}

data "template_file" "tfvars-vaultf5" {
  template = "${file("../as3-secure/2-as3/terraform.tfvars.example")}"
  vars = {
    addr     = "${aws_eip.f5.public_ip}",
    port     = "8443",
    username = "admin"
    pwd      = "${random_string.password.result}"
    vault-address = "http://${aws_instance.vault.public_ip}:8200",
    vault-token   = "${data.local_file.vault_token.content}"
  }
}

resource "local_file" "tfvars-vaultf5" {
  content  = data.template_file.tfvars-vaultf5.rendered
  filename = "../as3-secure/2-as3/terraform.tfvars"
}
