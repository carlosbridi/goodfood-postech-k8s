resource "aws_vpc" "main" {
  cidr_block           = var.VpcBlock
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "Public Subnets"
    Network = "Public"
  }
}

resource "aws_route_table" "private01" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "Private Subnet AZ1"
    Network = "Private01"
  }
}

resource "aws_route_table" "private02" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "Private Subnet AZ2"
    Network = "Private02"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "nat_gateway_1" {
  vpc = true
}

resource "aws_eip" "nat_gateway_2" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "eks-NatGatewayAZ1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_gateway_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "eks-NatGatewayAZ2"
  }
}

resource "aws_route" "private_1" {
  route_table_id         = aws_route_table.private01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id
}

resource "aws_route" "private_2" {
  route_table_id         = aws_route_table.private02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_2.id
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.PublicSubnet01Block
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name                      = "eks-PublicSubnet01"
    "kubernetes.io/role/elb"  = "1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.PublicSubnet02Block
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, 1)

  tags = {
    Name                      = "eks-PublicSubnet02"
    "kubernetes.io/role/elb"  = "1"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.PrivateSubnet01Block
  availability_zone = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name                                = "eks-PrivateSubnet01"
    "kubernetes.io/role/internal-elb"   = "1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.PrivateSubnet02Block
  availability_zone = element(data.aws_availability_zones.available.names, 1)

  tags = {
    Name                                = "eks-PrivateSubnet02"
    "kubernetes.io/role/internal-elb"   = "1"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private01.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private02.id
}

data "aws_availability_zones" "available" {}
