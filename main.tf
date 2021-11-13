data "template_file" "ec2_init" {
  template = file("${path.module}/src/ec2_init_ubuntu.sh")

  vars = {
    iam_groups  = join(",", var.allow_login_iam_group_names)
    lib_version = "v1.10.0"
  }
}
