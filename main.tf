# 1. Create a VPC
resource "aws_vpc" "group10_nginx_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    name = "devops-group-10"
  }
}

# 2. Create a Public Subnet
resource "aws_subnet" "group10_public_subnet" {
  vpc_id     = aws_vpc.group10_nginx_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "${var.aws_region}a"
  tags = {
    name = "devops-group-10"
  }
}

# 3. Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "group10_igw" {
  vpc_id = aws_vpc.group10_nginx_vpc.id
  tags = {
    name = "devops-group-10"
  }
}

# 4. Create a Route Table for the Public Subnet
resource "aws_route_table" "group10_public_rt" {
  vpc_id = aws_vpc.group10_nginx_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.group10_igw.id
  }
}

# 5. Associate Route Table with the Public Subnet
resource "aws_route_table_association" "group10_public_rt_assoc" {
  subnet_id      = aws_subnet.group10_public_subnet.id
  route_table_id = aws_route_table.group10_public_rt.id
}

# 6. Create a Security Group to allow SSH and HTTP access
resource "aws_security_group" "group10_ec2_sg" {
  vpc_id = aws_vpc.group10_nginx_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 8080
    to_port     = 8080
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
    name = "devops-group-10"
  }
}

# 7. Launch an EC2 Instance
resource "aws_instance" "group10_nginx_server" {
  ami           = var.ami_id
  instance_type = var.instance_type_nginx
  subnet_id     = aws_subnet.group10_public_subnet.id
  security_groups = [aws_security_group.group10_ec2_sg.id]
  associate_public_ip_address = true

  # User Data Script to install NGINX
  user_data = <<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
    echo "Starting User Data Script"

    # Update the package index and install NGINX
    sudo apt-get update -y
    sudo apt-get install nginx -y

    # Start and enable NGINX
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Write a simple HTML page for testing
    echo "<html><body><h1>Hello, from NGINX on $(hostname -f)</h1></body></html>" | sudo tee /var/www/html/index.html

    echo "User Data Script Completed"
  EOF


  tags = {
    name = "devops-group-10"
  }
}

# # Launch an EC2 Instance with Jenkins
# resource "aws_instance" "group10_jenkins_server" {
#   ami           = var.ami_id
#   instance_type = var.instance_type_jenkins
#   subnet_id     = aws_subnet.group10_public_subnet.id
#   security_groups = [aws_security_group.group10_ec2_sg.id]
#   associate_public_ip_address = true

#   # User Data Script to install Jenkins
#   user_data = <<-EOF
# #!/bin/bash
# # Update the package list
# sudo apt update -y

# # Install fontconfig and OpenJDK 17 JRE
# sudo apt install -y fontconfig openjdk-17-jre

# # Download and add Jenkins GPG key to trusted keyring
# sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
#   https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# # Add the Jenkins repository to the system sources list
# echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
#   | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# # Update package list again after adding Jenkins repository
# sudo apt-get update -y

# # Install Jenkins
# sudo apt-get install -y jenkins

# # Start and enable Jenkins service
# sudo systemctl start jenkins
# sudo systemctl enable jenkins

#   EOF

#   tags = {
#     Name = "jenkins_server"
#   }
# }
