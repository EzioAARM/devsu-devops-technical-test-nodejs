provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "build_bucket" {
  bucket = "devsu-build-bucket-devops-technical-test"
}

resource "aws_s3_bucket_ownership_controls" "build_bucket_ownership" {
  bucket = aws_s3_bucket.build_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "build_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.build_bucket_ownership]

  bucket = aws_s3_bucket.build_bucket.id
  acl    = "private"
}

resource "aws_codestarconnections_connection" "personal-github-connection" {
  name          = "personal-github-connection"
  provider_type = "GitHub"
}

locals {
  environments = {
    dev  = { environment = "dev", branch = "develop" }
    prod = { environment = "prod", branch = "main" }
  }
}

module "network" {
  source   = "./modules/network"
  for_each = local.environments

  environment = each.value.environment
}

module "pipelines" {
  source   = "./modules/pipelines"
  for_each = local.environments

  vpc_id                  = module.network[each.value.environment].vpc_id
  build_subnet_arn        = module.network[each.value.environment].build_subnet_arn
  build_sg_id             = module.network[each.value.environment].build_sg_id
  build_bucket_name       = aws_s3_bucket.build_bucket.bucket
  build_bucket_arn        = aws_s3_bucket.build_bucket.arn
  environment             = each.value.environment
  codestar_connection_arn = aws_codestarconnections_connection.personal-github-connection.arn
  github_repository_id    = "EzioAARM/devsu-devops-technical-test-nodejs"
  github_branch           = each.value.branch
}
