################################################################################
# VPC
################################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

################################################################################
# Subnets
################################################################################
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-public-${var.azs[count.index]}" })
}

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, { Name = "${var.name_prefix}-private-${var.azs[count.index]}" })
}

resource "aws_subnet" "db" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-${var.azs[count.index]}" })
}

################################################################################
# NAT Gateway (single, in first public subnet)
################################################################################
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-eip" })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat" })

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# Route Tables
################################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-private-rt" })
}

resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-rt" })
}

resource "aws_route_table_association" "db" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}
