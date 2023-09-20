provider aws {
  region = "ap-south-1" 
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}

resource "aws_vpc" "myapp_vpc" {
cidr_block = var.vpc_cidr_block
tags = {
  Name = " ${var.env_prefix}-vpc"
}
}

resource "aws_subnet" "myapp_subnet" {
vpc_id = aws_vpc.myapp_vpc.id
cidr_block = var.subnet_cidr_block
availability_zone = var.avail_zone
tags = {
  Name = " ${var.env_prefix}-subnet-1"
}
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id
  tags = {
    Name = " ${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "myapp_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
    tags = {
      Name = "${var.env_prefix}-rtb"
    }

  }
  
resource "aws_route_table_association" "rtb_assossiation" {
  subnet_id = aws_subnet.myapp_subnet.id
  route_table_id = aws_route_table.myapp_route_table.id
}


