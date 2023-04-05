
variable "master" {}
variable "app" {}
variable "app_name" {}

resource "aws_ecr_repository" "ecr-Repo" {
  name                 = "${var.app_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

}

