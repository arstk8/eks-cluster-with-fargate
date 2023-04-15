data aws_availability_zones available {
  state = "available"
}

resource aws_vpc eks_vpc {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource aws_internet_gateway internet_gateway {
  vpc_id = aws_vpc.eks_vpc.id
}

resource aws_route_table public_route_table {
  vpc_id = aws_vpc.eks_vpc.id
}

resource aws_route_table private_route_table_01 {
  vpc_id = aws_vpc.eks_vpc.id
}

resource aws_route_table private_route_table_02 {
  vpc_id = aws_vpc.eks_vpc.id
}

resource aws_route public_route {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource aws_route private_route_01 {
  route_table_id         = aws_route_table.private_route_table_01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_01.id
}

resource aws_route private_route_02 {
  route_table_id         = aws_route_table.private_route_table_02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_02.id
}

resource aws_nat_gateway nat_gateway_01 {
  allocation_id = aws_eip.eip1.allocation_id
  subnet_id     = aws_subnet.public_subnet_01.id
}

resource aws_nat_gateway nat_gateway_02 {
  allocation_id = aws_eip.eip2.allocation_id
  subnet_id     = aws_subnet.public_subnet_02.id
}

resource aws_eip eip1 {
  vpc = true
}

resource aws_eip eip2 {
  vpc = true
}

resource aws_subnet public_subnet_01 {
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "192.168.0.0/18"
  tags                    = {
    "kubernetes.io/role/elb" : 1
  }
}

resource aws_subnet public_subnet_02 {
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "192.168.64.0/18"
  tags                    = {
    "kubernetes.io/role/elb" : 1
  }
}

resource aws_subnet private_subnet_01 {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "192.168.128.0/18"
  tags              = {
    "kubernetes.io/role/internal-elb" : 1
  }
}

resource aws_subnet private_subnet_02 {
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "192.168.192.0/18"
  tags              = {
    "kubernetes.io/role/internal-elb" : 1
  }
}

resource aws_route_table_association public_subnet_01_route_table_association {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_route_table.id
}

resource aws_route_table_association public_subnet_02_route_table_association {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_route_table.id
}

resource aws_route_table_association private_subnet_01_route_table_association {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_route_table_01.id
}

resource aws_route_table_association private_subnet_02_route_table_association {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private_route_table_02.id
}

resource aws_security_group control_plane_security_group {
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id
}
