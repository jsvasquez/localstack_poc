####################################################################################
#
# Not in use for LocalStack but I decided to keep this configs in case the
# resources need to be provisioned in actual AWS infrastructure.
#
####################################################################################



# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = var.namespace
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = var.namespace
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Grab the list of availability zones
data "aws_availability_zones" "available" {}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  count                   = length(var.cidr_blocks)
  vpc_id                  = aws_vpc.default.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.cidr_blocks[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.namespace
  }
}

resource "aws_security_group" "default" {
  name_prefix = var.namespace
  vpc_id      = aws_vpc.default.id

  # Commenting this block out to avoid creating open to the internet SGs as a measure for Security Risks

  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}
