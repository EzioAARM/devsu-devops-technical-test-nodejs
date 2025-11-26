data "aws_iam_policy_document" "build_phase_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "build_phase_role" {
  name               = "build_phase_role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.build_phase_assume_role.json
}


data "aws_iam_policy_document" "build_phase_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "ec2:RunInstances",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterfacePermission"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"

      values = [
        var.build_subnet_arn,
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      var.build_bucket_arn,
      "${var.build_bucket_arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection"
    ]
    resources = [var.codestar_connection_arn]
  }
}

resource "aws_iam_role_policy" "build_phase_role_policy" {
  name   = "build_phase_role_policy-${var.environment}"
  role   = aws_iam_role.build_phase_role.id
  policy = data.aws_iam_policy_document.build_phase_role_policy_document.json
}

resource "aws_codebuild_project" "build_phase_project" {
  name          = "build_phase_project-${var.environment}"
  description   = "Build phase project for ${var.environment} environment"
  build_timeout = 5
  service_role  = aws_iam_role.build_phase_role.arn

  artifacts {
    type     = "CODEPIPELINE"
    location = "build-artifacts"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_URL"
      value = var.image_repo_url
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "devsu-devops-technical-test-nodejs"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "build_phase-logs-${var.environment}"
      stream_name = "log-stream-${var.environment}"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.build_bucket_arn}/build_phase-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "app/buildspec.yaml"
  }

  vpc_config {
    vpc_id = var.vpc_id

    subnets = [
      var.build_subnet_id
    ]

    security_group_ids = [
      var.build_sg_id
    ]
  }

  tags = {
    Environment = var.environment
  }
}
