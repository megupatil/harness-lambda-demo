terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type = string
  default = "us-east-1"
}

# 1. IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "harness_canary_role_${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 2. S3 Bucket for Artifacts
resource "aws_s3_bucket" "lambda_bucket" {
  bucket_prefix = "harness-demo-"
  force_destroy = true # Cleanup easy for demo
}

# Helper for uniqueness
resource "random_id" "suffix" {
  byte_length = 4
}

# 3. OUTPUTS (Crucial: Harness will read these)
output "role_arn" {
  value = aws_iam_role.lambda_exec.arn
}

output "bucket_name" {
  value = aws_s3_bucket.lambda_bucket.id
}
