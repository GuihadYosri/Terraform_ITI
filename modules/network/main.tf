# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "InternetGateway"
  }
}

# Subnets
resource "aws_subnet" "main" {
  for_each = { for subnet in var.subnets_details : subnet.name => subnet }
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.cidr
  availability_zone = each.value.zone
  tags = {
    Name = "${each.value.name}_subnet"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "NAT_EIP"
  }
}

resource "aws_nat_gateway" "main" {
  subnet_id = aws_subnet.main["public1"].id
  allocation_id = aws_eip.nat_eip.allocation_id
  tags = {
    Name = "NATGateway"
  }
}

# Route Tables
resource "aws_route_table" "main" {
  count = 2
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = count.index == 0 ? aws_internet_gateway.main.id : aws_nat_gateway.main.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_rt_association" {
  route_table_id = aws_route_table.main[0].id
  subnet_id = aws_subnet.main["public1"].id
}

resource "aws_route_table_association" "private_rt_association" {
  route_table_id = aws_route_table.main[1].id
  subnet_id = aws_subnet.main["private1"].id
}

