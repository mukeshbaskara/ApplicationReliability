resource "aws_vpc" "flyingclub_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "flyingclub-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.flyingclub_vpc.id
  cidr_block = var.public_subnets[count.index].cidr_block
  availability_zone = var.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = lookup(var.public_subnets[count.index].tags,"Name", "public_subnet_${count.index}")
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  vpc_id     = aws_vpc.flyingclub_vpc.id
  cidr_block = var.private_subnets[count.index].cidr_block
  availability_zone = var.private_subnets[count.index].availability_zone
  tags = {
    Name = lookup(var.private_subnets[count.index].tags,"Name", "private_subnet_${count.index}")
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.flyingclub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_rtb"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.flyingclub_vpc.id

  tags = {
    Name = "fc-igw"
  }
}

resource "aws_route_table_association" "rtb_association_public_subnet" {
  count = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "fc_nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "fc-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.flyingclub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.fc_nat_gw.id
  }

  tags = {
    Name = "private_rtb"
  }
  depends_on = [aws_nat_gateway.fc_nat_gw]
}


resource "aws_route_table_association" "rtb_association_private_subnet" {
  count = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}
