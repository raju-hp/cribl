# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name}-vpc" })

  lifecycle {
    create_before_destroy = true
  }
}


# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "${var.name}-public-${count.index}" })

  depends_on = [aws_vpc.this]

  lifecycle {
    create_before_destroy = true
  }
}


# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(var.tags, { Name = "${var.name}-private-${count.index}" })

  depends_on = [aws_vpc.this]

  lifecycle {
    create_before_destroy = true
  }
}


# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-igw" })

  depends_on = [aws_vpc.this]

  lifecycle {
    create_before_destroy = true
  }
}


# NAT Gateway & EIP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.name}-nat-eip" })

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.this,
    aws_eip.nat,
    aws_subnet.public
  ]

  tags = merge(var.tags, { Name = "${var.name}-nat" })

  lifecycle {
    create_before_destroy = true
  }
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name}-public-rt" })

  depends_on = [
    aws_internet_gateway.this,
    aws_subnet.public
  ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]
}


# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name}-private-rt" })

  depends_on = [
    aws_nat_gateway.this,
    aws_subnet.private
  ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route_table.private]
}


# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
  lifecycle { create_before_destroy = true }
}

# Leader Security Group
resource "aws_security_group" "leader_sg" {
  name        = "${var.name}-leader-sg"
  description = "Cribl Leader Security Group"
  vpc_id      = aws_vpc.this.id

  # SSH Access
  ingress {
    description = "Allow SSH (for admin access)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound communication with worker
  ingress {
    from_port   = 4200
    to_port     = 4200
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  # ALB → Leader (UI)
  ingress {
    description     = "Allow ALB access to Cribl UI"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  tags = merge(var.tags, { Name = "${var.name}-leader-sg" })
  lifecycle { create_before_destroy = true }
}


# Worker Security Group
resource "aws_security_group" "worker_sg" {
  name        = "${var.name}-worker-sg"
  description = "Cribl Worker Security Group"
  vpc_id      = aws_vpc.this.id

  # SSH Access
  ingress {
    description = "Allow SSH (for admin access)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound communication with leader
  ingress {
    from_port   = 4200
    to_port     = 4200
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  tags = merge(var.tags, { Name = "${var.name}-worker-sg" })
  lifecycle { create_before_destroy = true }
}


# # Cross Security Group Rules

# # ALB → Leader (Cribl UI on port 9000)
# resource "aws_security_group_rule" "alb_to_leader" {
#   description              = "Allow ALB to reach Cribl UI (9000)"
#   type                     = "ingress"
#   from_port                = 9000
#   to_port                  = 9000
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.alb_sg.id
#   security_group_id        = aws_security_group.leader_sg.id

#   depends_on = [
#     aws_security_group.alb_sg,
#     aws_security_group.leader_sg
#   ]
# }

# # Worker → Leader (Private IP Port 4200)
# resource "aws_security_group_rule" "worker_to_leader" {
#   description              = "Allow workers to connect to leader (port 4200, private IP)"
#   type                     = "ingress"
#   from_port                = 4200
#   to_port                  = 4200
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.worker_sg.id
#   security_group_id        = aws_security_group.leader_sg.id

#   depends_on = [
#     aws_security_group.worker_sg,
#     aws_security_group.leader_sg
#   ]
# }

# # Leader → Worker (Optional, for bidirectional Cribl sync)
# resource "aws_security_group_rule" "leader_to_worker" {
#   description              = "Allow leader to connect to worker (port 4200, private IP)"
#   type                     = "ingress"
#   from_port                = 4200
#   to_port                  = 4200
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.leader_sg.id
#   security_group_id        = aws_security_group.worker_sg.id

#   depends_on = [
#     aws_security_group.worker_sg,
#     aws_security_group.leader_sg
#   ]
# }
