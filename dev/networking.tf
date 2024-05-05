resource "aws_vpc" "cloudgroup" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "cloudgroup"
  }
}

resource "aws_internet_gateway" "cloudgroup_igw" {
  vpc_id = aws_vpc.cloudgroup.id

  tags = {
    Name = "cloudgroup_igw"
  }
}

resource "aws_subnet" "dev_public" {
  vpc_id            = aws_vpc.cloudgroup.id
  cidr_block        = "10.0.0.0/18"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name                                = "dev_public_subnet"
    Env                                 = "dev"
    "kubernetes.io/role/elb"            = "1" # public loadBalancer
    "kubernetes.io/cluster/dev_cluster" = "owned"
  }
}

resource "aws_subnet" "dev_private" {
  vpc_id            = aws_vpc.cloudgroup.id
  cidr_block        = "10.0.64.0/18"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name                                = "dev_private_subnet"
    Env                                 = "dev"
    "kubernetes.io/role/internal-elb"   = "1" # internal loadBalancer
    "kubernetes.io/cluster/stg_cluster" = "owned"
  }

}

resource "aws_eip" "nat_gateway_eip" {

  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.dev_public.id

  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.cloudgroup_igw]
}

resource "aws_route_table" "dev_private" {
  vpc_id = aws_vpc.cloudgroup.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "dev_private_route"
  }
}

resource "aws_route_table" "dev_public" {
  vpc_id = aws_vpc.cloudgroup.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudgroup_igw.id
  }

  tags = {
    Name = "dev_public_route"
  }
}


# associate the route tables

resource "aws_route_table_association" "dev_public" {
  subnet_id      = aws_subnet.dev_public.id
  route_table_id = aws_route_table.dev_public.id
}

resource "aws_route_table_association" "dev_private" {
  subnet_id      = aws_subnet.dev_private.id
  route_table_id = aws_route_table.dev_private.id
}

