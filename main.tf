provider "aws" {
    region = "ap-south-1"
    }

variable "vpc_cidr_block" {
  type        = string
  description = "cidr block for vpc"
}

variable "subnet_cidr_block" {
    type = string
    description = "cidr block for subnet"
}

variable "subnet_cidr_block_default" {
    type = string
    description = "cidr block for subnet default"
}

variable environment {
  description = "Type of environment"
}



resource "aws_vpc" "development_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: var.environment
    }
}

resource "aws_subnet" "development_subnet" {
    vpc_id = aws_vpc.development_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "ap-south-1a"
    tags =  {
        Name: var.environment
    }
} 

data "aws_vpc" "default_vpc"{
    default = true
}

resource "aws_subnet" "development_subnet_1" {
    vpc_id = data.aws_vpc.default_vpc.id
    cidr_block = var.subnet_cidr_block_default
    availability_zone = "ap-south-1a"
    tags = {
        Name: var.environment
    }
} 

output "vpc_id" {
  value = aws_vpc.development_vpc.id
}

output "subnet_id" {
  value = aws_subnet.development_subnet.id
}

output "default_subnet_id" {
  value = aws_subnet.development_subnet_1.id
}
