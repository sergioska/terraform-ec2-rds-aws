# Set a Provider
provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

# Create a security group
resource "aws_security_group" "default" {
  name        = "terraform security group"
  description = "terraform security group"
  vpc_id      = aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an ec2 instance
resource "aws_instance" "web" {
  ami                    = var.aws_amis
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id              = aws_subnet.private_subnet_1.id

  # The name of our SSH keypair we created above.
  key_name = var.key_name

  connection {
    # The default username for our AMI
    user = "ec2-user"
    host = self.public_ip
    type     = "ssh"
    private_key = file(var.pem_path)
    # The connection will use the local SSH agent for authentication.
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      var.web_service == "apache" ? "sudo apt-get -y install apache" : "sudo apt-get -y install nginx",
      var.web_service == "apache" ? "sudo service httpd start" : "sudo service nginx start",
    ]
  }
}

resource "aws_db_instance" "default" {
  depends_on             = [aws_security_group.default]
  storage_type           = "gp2"
  identifier             = var.db_identifier
  allocated_storage      = var.storage
  engine                 = var.engine
  engine_version         = lookup(var.engine_version, var.engine)
  instance_class         = var.instance_class
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.default.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  skip_final_snapshot    = false
}


