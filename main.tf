
# Describes the VPC
resource "aws_vpc" "vpc-gabriel-p" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  tags                 = { Name = "vpc-gabriel-p" }
}

# Describes the two subnets to be created
resource "aws_subnet" "SN-public-1" {
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = aws_vpc.vpc-gabriel-p.id
  availability_zone       = "us-east-1a"
  tags                    = { Name = "SN-public-1" }
}

resource "aws_subnet" "SN-public-2" {
  cidr_block              = "192.168.2.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = aws_vpc.vpc-gabriel-p.id
  availability_zone       = "us-east-1a"
  tags                    = { Name = "SN-public-2" }
}

# Creates the IGW to allow for internet routing
resource "aws_internet_gateway" "igw-example" {
  vpc_id = aws_vpc.vpc-gabriel-p.id
  tags   = { Name = "igw-example" }
}

# Creates a route table
resource "aws_route_table" "RT-public" {
  vpc_id = aws_vpc.vpc-gabriel-p.id
  tags   = { Name = "RT-public" }
}

# Points any internet-bound traffic to the IGW
resource "aws_route" "Pub-Route" {
  route_table_id         = aws_route_table.RT-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw-example.id
}

# Associates the RT with the two subnets
resource "aws_route_table_association" "Pub-RT-with-SN1" {
  route_table_id = aws_route_table.RT-public.id
  subnet_id      = aws_subnet.SN-public-1.id
}

resource "aws_route_table_association" "Pub-RT-with-SN2" {
  route_table_id = aws_route_table.RT-public.id
  subnet_id      = aws_subnet.SN-public-2.id
}

# Creates the SG
resource "aws_security_group" "SG-web-servers" {
  name        = "Allow HTTP and SSH"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.vpc-gabriel-p.id
  tags        = { Name = "SG-web-servers" }
}

# Allows SSH in from anywhere, range is port 22 to port 22 (SSH)
resource "aws_vpc_security_group_ingress_rule" "ssh-in" {
  security_group_id = aws_security_group.SG-web-servers.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Allows HTTP in from anywhere, range is port 80 to port 80 (SSH)
resource "aws_vpc_security_group_ingress_rule" "http-in" {
  security_group_id = aws_security_group.SG-web-servers.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Allows egress traffic from the EC2 to anywhere- any port, tcp||udp
resource "aws_vpc_security_group_egress_rule" "all-out" {
  security_group_id = aws_security_group.SG-web-servers.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Creates the two EC2s, 1 per subnet
resource "aws_instance" "EC2-VM1" {
  ami               = data.aws_ami.latest_ami.id
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.SN-public-1.id
  security_groups   = [aws_security_group.SG-web-servers.id]
  availability_zone = "us-east-1a"
  key_name          = "pemSem5"
  tags              = { Name = "EC2-VM1" }
}

resource "aws_instance" "EC2-VM2" {
  ami               = data.aws_ami.latest_ami.id
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.SN-public-2.id
  security_groups   = [aws_security_group.SG-web-servers.id]
  availability_zone = "us-east-1a"
  key_name          = "pemSem5"
  tags              = { Name = "EC2-VM2" }
}

# Dynamically grabs the latest amazon linux ami, as changes often.
data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*x86_64-gp2"]
  }
}
