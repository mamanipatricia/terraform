provider "aws" {
  region     = "us-east-1"
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUT_SECRET_KEY"
}
provider "azure" {

}

# EXAMPLE 1
# resource "<provider>_<resource_type>" "name" {
#   #   config options
#   key  = "value"
#   key2 = "value2"
# }

resource "aws_instance" "my-first-server" {
  ami = "ami-085925f297f89fce1"
  #   ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "my-first-ubuntu-server"
  }

}

# VPC
resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "production"
  }
}
resource "aws_vpc" "second-vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "Dev"
  }
}

# SUBNET
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.second-vpc.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "dev-subnet"
  }
}

# 1. Create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}
# 2. create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    # Name = "main"
  }
}
# 3. create Custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Prod"
  }
}
# 4. create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }

}
# 5. associate subnet with Route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id

}
# 6. create security Group to allow port 22, 80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web_traffic inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description      = "HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # ALLOW ANY IP ADDERSS
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description      = "SSH traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # ALLOW ANY IP ADDERSS
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
# 7. create a network interface with an ip in the subnet that was created in step 4
# 8. assign an elastic IP to the network interface created in step 7
# 9. create Ubuntu server and install/enable apache 2
