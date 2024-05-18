module "network" {
  source = "./modules/network"
  vpc_cidr = var.vpc_cidr
  subnets_details = var.subnets_details
  region = var.region
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = module.network.vpc_id
  name   = "BastionSG"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "BastionSG"
  }
}


# Generate a private key using the TLS provider
resource "tls_private_key" "rsa-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa-key.public_key_openssh
}

resource "local_file" "tf-key"{
  content = tls_private_key.rsa-key.private_key_pem
  filename  =  "tf-key-pair.pem"
}




resource "aws_security_group" "app_sg" {
  vpc_id = module.network.vpc_id
  name   = "AppSG"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs 
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "AppSG"
  }
}

resource "aws_instance" "bastion" {
  ami                    = var.machine_details["ami"] 
  instance_type          = var.machine_details["type"]
  subnet_id              = module.network.public_subnets["public1"]
  key_name               = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "Bastion"
  }

  provisioner "local-exec" {
    command = "echo 'Bastion Public IP: ${self.public_ip}'"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo '${tls_private_key.rsa-key.private_key_pem}' > /home/ubuntu/key.pem
    chmod 400 key.pem
    chown ubuntu:ubuntu key.pem
  EOF
}

resource "aws_instance" "application" {
  ami           = var.machine_details["ami"]
  instance_type = var.machine_details["type"]
  subnet_id     = module.network.private_subnets["private1"]
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name      = "tf-key-pair"

  tags = {
    Name = "Application"
  }
}


resource "aws_security_group" "rds_sg" {
  vpc_id = module.network.vpc_id
  name   = "RDS_SG"


  ingress {
    from_port   = 3306  # Default port for MySQL
    to_port     = 3306
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
    Name = "RDS_SG"
  }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [module.network.private_subnets["private1"], module.network.private_subnets["private2"]]

  tags = {
    Name = "RDS_Subnet_Group"
  }
}

# RDS Instance in Private Subnet
resource "aws_db_instance" "main" {
  identifier           = "my-rds-instance"
  engine               = "mysql"
  instance_class       = "db.t3.micro"  # Choose the appropriate instance type
  allocated_storage    = 20  # In GB
  username             = "admin"
  password             = "SecurePass123!"  # Ensure this is secure
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  multi_az             = false  # Single availability zone
  skip_final_snapshot  = true  # To avoid the final snapshot at deletion (be cautious with this)

  tags = {
    Name = "My_RDS_Instance"
  }
}


resource "aws_security_group" "elasticache_sg" {
  vpc_id = module.network.vpc_id
  name   = "ElastiCache_SG"

  ingress {
    from_port   = 6379  # Default port for Redis
    to_port     = 6379
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
    Name = "ElastiCache_SG"
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "elasticache-subnet-group"
 subnet_ids = [module.network.private_subnets["private1"], module.network.private_subnets["private2"]]



  tags = {
    Name = "ElastiCache_Subnet_Group"
  }
}

resource "aws_elasticache_cluster" "main" {
  cluster_id        = "my-cache-cluster"
  engine            = "redis"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  security_group_ids = [aws_security_group.elasticache_sg.id]
  subnet_group_name = aws_elasticache_subnet_group.main.name

  tags = {
    Name = "My_ElastiCache_Cluster"
  }
}


################ to test s3 trigger
resource "aws_instance" "new_instance" {
  ami           = var.machine_details["ami"] 
  instance_type = "t2.micro"
  tags = {
    Name = "NewInstance"
  }
}
