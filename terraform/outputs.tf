output "f5_ip" {
  value = "${aws_eip.f5.public_ip}"
}

output "f5_password" {
  value = "${data.aws_secretsmanager_secret_version.bigip_password.secret_string}"
}

output "f5_username" {
  value = "admin"
}

output "f5_ui" {
  value = "https://${aws_eip.f5.public_ip}:${var.port}"
}

output "consul_ui" {
  value = "http://${aws_instance.consul.public_ip}:8500"
}


output "f5_ssh" {
  value = "ssh admin@${aws_eip.f5.public_ip} -i ${aws_key_pair.demo.key_name}.pem"
}