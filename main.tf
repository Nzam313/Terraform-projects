provider aws {
  region = "ap-south-1" 
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}

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

resource "aws_default_route_table" "main_rtb" {
    default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp_igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}

/* resource "aws_security_group" "myapp_sg" {
  name = "myapp_sg"
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-sg"
    }
}  */

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-aws-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-2023.1.20230912.0-kernel-6.1-x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

output aws_ami_id {
  value = data.aws_ami.latest-aws-image.id
}

resource "aws_key_pair" "myapp-key_pair" {
  key_name = "myapp-server-key"
  public_key = file(var.public_key_location)

}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-aws-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp_subnet.id
    vpc_security_group_ids = [aws_default_security_group.default_sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.myapp-key_pair.key_name

    

    tags = {
        Name = "${var.env_prefix}-server"
    }
}

output ec2_public_ip {
  value = aws_instance.myapp-server.public_ip
}







