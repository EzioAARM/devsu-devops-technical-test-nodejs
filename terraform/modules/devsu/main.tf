

resource "aws_ecr_repository" "project_repo" {
  name                 = "devsu-project-repo-${var.project_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
