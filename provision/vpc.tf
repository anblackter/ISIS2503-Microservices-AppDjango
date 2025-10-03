# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    name = "${var.project_name}-vpc"
  }
}

# Security Group
resource "aws_security_group" "security_group" {
  name        = "${var.project_name}-security-group"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  # SSH access for EC2 Instance Connect
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH for EC2 Instance Connect"
  }

  # firewall-django
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "firewall-django"
  }

  # postgres-db
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "postgres-db"
  }

  # kong-proxy
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "kong-proxy"
  }

  # kong-admin-api
  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "kong-admin-api"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all internal VPC traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all internal VPC traffic"
  }

  tags = {
    Name = "${var.project_name}-security-group"
  }
}

# Subnets
resource "aws_subnet" "static_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
}

resource "aws_subnet" "static_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"
}


# Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.static_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-internet_gateway"
  }
}

# Network Interfaces for each instance
resource "aws_network_interface" "kong_ni" {
  subnet_id   = aws_subnet.static_subnet.id
  private_ips = [var.kong_ip]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "kong_network_interface"
  }
}

resource "aws_network_interface" "variables_db_ni" {
  subnet_id   = aws_subnet.static_subnet.id
  private_ips = [var.variables_db_ip]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "varibales_db_interface"
  }
}

resource "aws_network_interface" "measurements_db_ni" {
  subnet_id   = aws_subnet.static_subnet.id
  private_ips = [var.measurements_db_ip]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "measurements_db_interface"
  }
}

resource "aws_network_interface" "variables_ms_ni" {
  subnet_id   = aws_subnet.static_subnet.id
  private_ips = [var.variables_ms_ip]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "variables_ms_interface"
  }
}

resource "aws_network_interface" "measurements_ms_ni" {
  subnet_id   = aws_subnet.static_subnet.id
  private_ips = [var.measurements_ms_ip]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "measurements_ms_interface"
  }
}




