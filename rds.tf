# Security Group to allow access to RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow DB access from within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Adjust to match your VPC CIDR if different
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Subnet group for RDS (uses private subnets)
resource "aws_db_subnet_group" "workout_subnet_group" {
  name       = "workout-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "Workout DB subnet group"
  }
}

# RDS PostgreSQL instance
resource "aws_db_instance" "workout" {
  identifier             = "micro-workout-db"
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.workout_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "micro-workout-db"
  }
}
