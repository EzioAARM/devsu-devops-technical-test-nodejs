variable "vpc_id" {
  description = "The ID of the VPC where the pipeline resources will be created"
  type        = string
}

variable "build_subnet_id" {
  description = "The ID of the subnet for the build resources"
  type        = string
}

variable "build_subnet_arn" {
  description = "The ARN of the subnet for the build resources"
  type        = string
}

variable "build_sg_id" {
  description = "The ID of the security group for the build resources"
  type        = string
}

variable "build_bucket_name" {
  description = "The name of the S3 bucket for build artifacts"
  type        = string
}

variable "build_bucket_arn" {
  description = "The ARN of the S3 bucket for build artifacts"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}

variable "codestar_connection_arn" {
  description = "The ARN of the GitHGub CodeStar Connections connection"
  type        = string
}

variable "github_repository_id" {
  description = "The ID of the GitHub repository"
  type        = string
}

variable "github_branch" {
  description = "The branch of the GitHub repository to use"
  type        = string
  default     = "main"
}

variable "image_repo_url" {
  description = "The URL of the image repository"
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster for deployment"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "eks_cluster_ca_certificate" {
  description = "The CA certificate of the EKS cluster"
  type        = string
}
