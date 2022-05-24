variable "debug" {
  description = "Indicates if logging should be configure in debug mode"
  default     = 1
}

variable "namespace" {
  description = "A namespace to keep app naming schema consistent"
  default     = "redis-cloudapp"
}

variable "region" {
  description = "AWS region in which to operate"
  default     = "us-east-1"
}

locals {
  default_tags = {
    "app" = "localstack-test"
  }
}

variable "vpc_cidr_block" {
  description = "The top-level CIDR block for the VPC."
  default     = "10.1.0.0/16"
}

variable "cidr_blocks" {
  description = "The CIDR blocks to create the workstations in."
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "cluster_id" {
  description = "Id to assign the new cluster"
  default     = "redis-cluster"
}

variable "localstack_service_name" {
  description = "Localstack Docker-compose service name"
  default = "localstack"
}
