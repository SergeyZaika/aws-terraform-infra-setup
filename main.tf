provider "aws" {
  region = "eu-central-1" # Specify the desired AWS region (Frankfurt)
}

terraform {
  backend "s3" {
    bucket = "my-statement-bucket"
    key    = "terraform/terraform.tfstate"
    region = "eu-central-1"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true  # Ensure this matches the current state
  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Route Table
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id
  name   = "web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# EC2 Instance with EBS volume and Public IP
resource "aws_instance" "web_instance" {
  ami           = "ami-0955442b9127ada93" # Ensure this is correct for the region
  instance_type = "t2.micro"
  key_name      = var.key_name # Reference the key name variable
  subnet_id     = aws_subnet.public_subnet.id

  associate_public_ip_address = true  # Associate a public IP address

  vpc_security_group_ids = [aws_security_group.web_sg.id] # Correct security group reference

  root_block_device {
    volume_type = "gp2"
    volume_size = 30 # 30 GB within free tier limits
  }

  tags = {
    Name = "web-instance"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "statements" {
  bucket = "my-statement-bucket"
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "statements" {
  bucket = "my-statement-bucket"
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "statements" {
  bucket = "my-statement-bucket"
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "statements_policy" {
  bucket = "my-statement-bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "s3:*",
        Resource = [
          "arn:aws:s3:::my-statement-bucket",
          "arn:aws:s3:::my-statement-bucket/*"
        ],
        Principal = "*"
      }
    ]
  })
}
