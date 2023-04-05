terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

variable "master" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}


# Pulls the image
resource "docker_image" "nginx" {
  name = "nginx"

    provisioner "local-exec" {
   command = "docker pull docker_image.nginx.latest"
  }
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.master.region} | docker login --username AWS --password-stdin ${var.master.aws_account_id}.dkr.ecr.${var.master.region}.amazonaws.com"
  }

  #provisioner "local-exec" {
  #  command = "docker tag ${var.master.docker_image_id} ${var.master.aws_account_id}.dkr.ecr.${var.master.region}.amazonaws.com/${aws_ecr_repository.aeonai-Repo.name}:${var.app.release_numb}"
  #}
    provisioner "local-exec" {
    command = "docker tag nginx ${var.master.aws_account_id}.dkr.ecr.${var.master.region}.amazonaws.com/${var.app_name}:${var.app.release_numb}"
  }
  
  #provisioner "local-exec" {
  # command = "docker push ${var.master.aws_account_id}.dkr.ecr.${var.master.region}.amazonaws.com/${aws_ecr_repository.aeonai-Repo.name}:${var.app.release_numb}"
  #}
  
  provisioner "local-exec" {
   command = "docker push ${var.master.aws_account_id}.dkr.ecr.${var.master.region}.amazonaws.com/${var.app_name}:${var.app.release_numb}"
  }
    provisioner "local-exec" {
   command = "docker rm -f ${var.app_name}-fisrtrun"
  }
}