terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create a VPC
resource "aws_vpc" "itp4124_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    terraform = "true"
    Name      = "Cloud Project VPC"
  }
}

resource "aws_subnet" "publicSubnet1" {
    vpc_id = aws_vpc.itp4124_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "publicSubnet1"
    }
}
    
resource "aws_subnet" "publicSubnet2" {
    vpc_id = aws_vpc.itp4124_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "publicSubnet2"
    }
}

resource "aws_subnet" "isolatedSubnet1" {
    vpc_id = aws_vpc.itp4124_vpc.id
    cidr_block = "10.0.4.0/22"
    availability_zone = "us-east-1a"
    tags = {
        Name = "isolatedSubnet1"
    }
}

resource "aws_subnet" "isolatedSubnet2" {
    vpc_id = aws_vpc.itp4124_vpc.id
    cidr_block = "10.0.8.0/22"
    availability_zone = "us-east-1b"
    tags = {
        Name = "isolatedSubnet2"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.itp4124_vpc.id
}

resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
    vpc_id = aws_vpc.itp4124_vpc.id
    service_name = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids = [aws_route_table.s3_rtb[0].id, aws_route_table.s3_rtb[1].id]
}

resource "aws_route_table" "public_rtb" {
    count = 2
    vpc_id = aws_vpc.itp4124_vpc.id
    
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
    Name = "public_route_table_${count.index}"
    }
}


resource "aws_route_table" "s3_rtb" {
    count = 2
    vpc_id = aws_vpc.itp4124_vpc.id

    tags = {
    Name = "s3_route_table_${count.index}"
    }
}

