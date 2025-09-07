##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "N2W" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    local.common_tags,
    {
      Name = "N2W VPC"
    }
  )
}

resource "aws_internet_gateway" "N2W" {
  vpc_id = aws_vpc.N2W.id

  tags = merge(
    local.common_tags,
    {
      Name = "N2W internet gateway"
    }
  )
}

resource "aws_subnet" "n2w_public_subnet" {
  cidr_block              = var.vpc_public_subnets_cidr_block[0]
  vpc_id                  = aws_vpc.N2W.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common_tags,
    {
      Name = "N2W subnet"
    }
  )
}


# ROUTING #
resource "aws_route_table" "N2W" {
  vpc_id = aws_vpc.N2W.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.N2W.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "N2W route table"
    }
  )
}

resource "aws_route_table_association" "n2w_public_subnet" {
  subnet_id      = aws_subnet.n2w_public_subnet.id
  route_table_id = aws_route_table.N2W.id
}


# SECURITY GROUPS #
# Main security group
resource "aws_security_group" "main_sg" {
  name   = "main_sg"
  vpc_id = aws_vpc.N2W.id

  tags = merge(
    local.common_tags,
    {
      Name = "mainServerSG"
    }
  )
}

# HTTPS access from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_https_home" {
  security_group_id = aws_security_group.main_sg.id
  #cidr_ipv4         = aws_vpc.N2W.cidr_block
  cidr_ipv4   = "79.177.145.118/32"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

  tags = {
    Name = "HTTPS from home"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_work" {
  security_group_id = aws_security_group.main_sg.id
  #cidr_ipv4         = aws_vpc.N2W.cidr_block
  cidr_ipv4   = "31.154.180.234/32"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

  tags = {
    Name = "HTTPS from work"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}