##################
# TF Config Block
##################
terraform {
  required_version = "~> 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
       version = "~> 3.39.0"
    }
  }
}

provider "aws" {
  region = var.region

  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  default_tags {
    tags = local.default_tags
  }

  endpoints {
    iam         = "http://localhost:4566"
    lambda      = "http://localhost:4566"
    s3          = "http://localhost:4566"
    elasticache = "http://localhost:4566"
    sts         = "http://localhost:4566"
    ec2         = "http://localhost:4566"
  }
}


##################
# Main Resources
##################

module "transcriber_lambda" {
  source  = "claranet/lambda/aws"
  version = "1.4.0"

  function_name = "${var.namespace}_transcriber_${terraform.workspace}"
  description   = "Triggered by S3 bucket files upload. Stores names of uploaded files in ElastiCache."
  handler       = "name_transcriber_lambda.lambda_handler"
  runtime       = "python3.8"
  timeout       = 300

  source_path = "${path.module}/../name_transcriber_lambda"

  // Add environment variables.
  environment = {
    variables = {
      REDIS_ENDPOINT = var.localstack_service_name
      REDIS_PORT     = aws_elasticache_cluster.redis_cluster.port
      DEBUG          = var.debug
    }
  }

}

resource "aws_s3_bucket" "data_input_bucket" {
  bucket = "files-${var.namespace}"
  acl    = "private"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.transcriber_lambda.function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_input_bucket.arn
}

resource "aws_s3_bucket_notification" "input_bucket_notification" {
  bucket = aws_s3_bucket.data_input_bucket.id
  lambda_function {
    lambda_function_arn = module.transcriber_lambda.function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]

}
