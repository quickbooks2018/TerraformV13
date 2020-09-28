resource "null_resource" "scripts" {
  provisioner "local-exec" {
    command = var.command

  }
}