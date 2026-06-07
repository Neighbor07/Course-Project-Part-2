terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Automatically find the latest Ubuntu 24.04 image
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Upload your local WSL SSH key to AWS
resource "aws_key_pair" "minecraft_key" {
  key_name   = "acme-minecraft-key"
  public_key = file("~/.ssh/acme_minecraft.pub")
}

# Build the Network (VPC & Subnet)
resource "aws_vpc" "minecraft_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "acme-minecraft-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.minecraft_vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.minecraft_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.minecraft_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Set up the Firewall (Security Group)
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_rules"
  description = "Allow SSH and Minecraft inbound traffic"
  vpc_id      = aws_vpc.minecraft_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch the Server
resource "aws_instance" "minecraft_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  key_name               = aws_key_pair.minecraft_key.key_name
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  subnet_id              = aws_subnet.public_subnet.id

  tags = { Name = "Acme-Minecraft-Server" }
}

# Auto-generate the Ansible inventory file so Ansible knows where to connect
resource "local_file" "ansible_inventory" {
  content  = "[minecraft]\n${aws_instance.minecraft_server.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/acme_minecraft ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n"
  filename = "../ansible/inventory.ini"
}

output "server_public_ip" {
  value = aws_instance.minecraft_server.public_ip
}