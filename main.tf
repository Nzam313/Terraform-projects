provider aws {
  region = "ap-south-1"
}

variable vpc_cidr_block {
  type = string
}
variable subnet_cidr_block {
  type = string
}
variable avail_zone {
  type = string
}
variable environment_prefix {
  type = string
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.environment_prefix}-vpc" 
  }

}

resource "aws_subnet" "myapp_subnet" {
  vpc_id = aws_vpc.myapp_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.environment_prefix}-subnet-1"
  }

} 
