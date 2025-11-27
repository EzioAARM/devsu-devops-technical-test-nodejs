provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.devsu["prod"].cluster_endpoint
  cluster_ca_certificate = base64decode(module.devsu["prod"].cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.devsu["prod"].cluster_name]
  }
}

resource "aws_s3_bucket" "build_bucket" {
  bucket        = "devsu-build-bucket-devops-technical-test"
  force_destroy = true
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
    # dev  = { environment = "dev", branch = "develop" }
    prod = { environment = "prod", branch = "main" }
  }
}

module "network" {
  source   = "./modules/network"
  for_each = local.environments

  environment = each.value.environment
}

module "devsu" {
  source   = "./modules/devsu"
  for_each = local.environments

  project_name = "devsu-${each.value.environment}"
  environment  = each.value.environment

  subnets = [
    module.network[each.value.environment].public_subnet_id,
    module.network[each.value.environment].public_subnet_2_id
  ]
}

module "pipelines" {
  source   = "./modules/pipelines"
  for_each = local.environments

  vpc_id                  = module.network[each.value.environment].vpc_id
  build_subnet_id         = module.network[each.value.environment].build_subnet_id
  build_subnet_arn        = module.network[each.value.environment].build_subnet_arn
  build_sg_id             = module.network[each.value.environment].build_sg_id
  build_bucket_name       = aws_s3_bucket.build_bucket.bucket
  build_bucket_arn        = aws_s3_bucket.build_bucket.arn
  environment             = each.value.environment
  codestar_connection_arn = aws_codestarconnections_connection.personal-github-connection.arn
  github_repository_id    = "EzioAARM/devsu-devops-technical-test-nodejs"
  github_branch           = each.value.branch
  image_repo_url              = module.devsu[each.value.environment].ecr_repository_url
  eks_cluster_name            = module.devsu[each.value.environment].cluster_name
  eks_cluster_endpoint        = module.devsu[each.value.environment].cluster_endpoint
  eks_cluster_ca_certificate  = module.devsu[each.value.environment].cluster_ca_certificate
}
