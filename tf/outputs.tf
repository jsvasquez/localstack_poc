output "redis_endpoint" {
  description = "The endpoint to access the redis cluster from the host machine, not from lambda."
  value       = "localhost:${aws_elasticache_cluster.redis_cluster.port}"
}

output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = module.transcriber_lambda.function_arn
}

output "lambda_role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = module.transcriber_lambda.role_name
}
