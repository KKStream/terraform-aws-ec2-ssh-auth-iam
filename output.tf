output "ec2_user_data" {
  value = data.template_file.ec2_init.rendered
}

output "ec2_user_data_base64" {
  value = base64encode(data.template_file.ec2_init.rendered)
}
