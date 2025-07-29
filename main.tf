# Custom VPC Module using AWS Provider
# Based on HashiCorp AWS Provider resources

# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags,
    var.vpc_tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-igw"
    },
    var.tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.vpc_name}-public-${var.availability_zones[count.index]}"
      Tier = "Public"
    },
    var.tags,
    var.public_subnet_tags
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-private-${var.availability_zones[count.index]}"
      Tier = "Private"
    },
    var.tags,
    var.private_subnet_tags
  )
}

# Database Subnets (if specified)
resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-database-${var.availability_zones[count.index]}"
      Tier = "Database"
    },
    var.tags,
    var.database_subnet_tags
  )
}

# Route Tables
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route_table" "private" {
  count = var.single_nat_gateway ? 1 : length(var.private_subnets)

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = var.single_nat_gateway ? "${var.vpc_name}-private-rt" : "${var.vpc_name}-private-rt-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

# Public Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  count = var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}

# NAT Gateway (if enabled)
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 0

  domain = "vpc"

  tags = merge(
    {
      Name = var.single_nat_gateway ? "${var.vpc_name}-nat-eip" : "${var.vpc_name}-nat-eip-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.single_nat_gateway ? 0 : count.index].id

  tags = merge(
    {
      Name = var.single_nat_gateway ? "${var.vpc_name}-nat" : "${var.vpc_name}-nat-${var.availability_zones[count.index]}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

# Private Route to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.private_subnets) : 0

  route_table_id         = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
}

# Default Security Group
resource "aws_security_group" "default" {
  count = var.create_default_security_group ? 1 : 0

  name_prefix = "${var.vpc_name}-default-sg"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-default-sg"
    },
    var.tags
  )
}

# Default Security Group Ingress Rules
resource "aws_security_group_rule" "default_ingress" {
  count = var.create_default_security_group ? length(var.default_security_group_ingress_rules) : 0

  security_group_id = aws_security_group.default[0].id
  type              = "ingress"
  from_port         = var.default_security_group_ingress_rules[count.index].from_port
  to_port           = var.default_security_group_ingress_rules[count.index].to_port
  protocol          = var.default_security_group_ingress_rules[count.index].protocol
  cidr_blocks       = var.default_security_group_ingress_rules[count.index].cidr_blocks
  description       = var.default_security_group_ingress_rules[count.index].description
}

# Default Security Group Egress Rules
resource "aws_security_group_rule" "default_egress" {
  count = var.create_default_security_group ? length(var.default_security_group_egress_rules) : 0

  security_group_id = aws_security_group.default[0].id
  type              = "egress"
  from_port         = var.default_security_group_egress_rules[count.index].from_port
  to_port           = var.default_security_group_egress_rules[count.index].to_port
  protocol          = var.default_security_group_egress_rules[count.index].protocol
  cidr_blocks       = var.default_security_group_egress_rules[count.index].cidr_blocks
  description       = var.default_security_group_egress_rules[count.index].description
} 