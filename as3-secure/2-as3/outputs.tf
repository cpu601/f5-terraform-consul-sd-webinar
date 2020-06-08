output "app_url" {
  value = "https://${data.terraform_remote_state.aws_demo.outputs.f5_ip}:8080"
}
