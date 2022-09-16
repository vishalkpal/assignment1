provider "aws" {
  region = var.region
}

resource "aws_vpc" "Myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    #  Name        = "${var.environment}-Myvpc"
    Environment = "DEV"

  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.Myvpc.id
  availability_zone       = "${var.region}a"
  cidr_block              = var.subnet_pub_cidr
  map_public_ip_on_launch = true
  tags = {
    #Name        = "${var.environment}-pub_subnet"
    Environment = "DEV"

  }
}


resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.Myvpc.id
  availability_zone       = "${var.region}b"
  cidr_block              = var.subnet_pri_cidr
  map_public_ip_on_launch = true
  tags = {
    # Name        = "${var.environment}-pri_subnet"
    Environment = "DEV"

  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.Myvpc.id

  tags = {
    #Name        = "${var.environment}-ig"
    Environment = "DEV"
  }
}


#elastic ip for nat
resource "aws_eip" "nat_eip" {
  vpc = true
  #depends_on = [aws_internet_gateway.id]
}


# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name        = "nat"
    Environment = "DEV"
  }
}

#route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.Myvpc.id

  tags = {
    # Name        = "${var.environment}-private-route-table"
    Environment = "DEV"
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.Myvpc.id

  tags = {
    # Name        = "${var.environment}-public-route-table"
    Environment = "DEV"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
  count          = 1
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  count          = 1
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Myvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Myvpc.cidr_block]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Myvpc.cidr_block]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp" #this will be tcp not ssh
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "Allow http from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "DEV"
  }
}


resource "aws_instance" "web" {
  count                  = "1"
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "mykey"

  user_data = file("./userdata.sh")

  tags = {
    Environment = "DEV"
  }
provisioner "local-exec" {
    command = "echo server=${self.public_ip} > host1.txt"
  }

}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("/home/unthinkable-lap-0200/Desktop/terra/vpc/mykey.pub")
}
