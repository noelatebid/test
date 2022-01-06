resource "aws_security_group" "db_pgsql" {
  name        = "db-pgsql-${var.environment}"
  description = "Allow EKS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    description     = "EKS cluster access"
    security_groups = [aws_security_group.worker_group_mgmt.id]
  }

  tags = local.default_tags
}

module "db_pgsql" {
  source                 = "terraform-aws-modules/rds/aws"
  version                = "3.1.0"
  identifier             = "${local.prefix}-db"
  family                 = "postgres"
  engine                 = "postgres"
  engine_version         = "12.3"
  subnet_ids             = module.vpc.public_subnets
  vpc_security_group_ids = [aws_security_group.db_pgsql.id]
  instance_class         = var.environment == "prod" ? "db.t2.medium" : "db.t2.small"
  storage_encrypted      = true
  apply_immediately      = true
  monitoring_interval    = 0
  #monitoring_role_name   = local.rds_monitoring_role
  #create_monitoring_role = true
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  backup_retention_period   = var.environment == "prod" ? 30 : 3 # 30 is soc2 recommendation
  name                      = "ourtilt"
  username                  = "ourtilt"
  password                  = var.pgsql_password
  allocated_storage         = 20
  max_allocated_storage     = 100
  port                      = 5432
  multi_az                  = var.environment == "prod" ? true : false
  create_db_option_group    = false
  create_db_parameter_group = false
  tags = merge(
    local.default_tags,
    {
      "description" = "PGSQL for ${var.environment}"
    },
  )
}

module "db_pgsql_replica" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "3.1.0"
  identifier = "${local.prefix}-terraform-replica"
  # Source database. For cross-region use this_db_instance_arn
  replicate_source_db    = module.db_pgsql.db_instance_id
  family                 = "postgres"
  engine                 = "postgres"
  engine_version         = "12.3"
  vpc_security_group_ids = [aws_security_group.db_pgsql.id]
  instance_class         = var.environment == "prod" ? "db.t2.medium" : "db.t2.small"
  storage_encrypted      = true
  apply_immediately      = true

  //  monitoring_interval  = 0
  //  monitoring_role_name = local.rds_monitoring_role
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  # Username and password should not be set for replicas
  username              = ""
  password              = ""
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = "5432"
  multi_az              = var.environment == "prod" ? true : false
  # disable backups to create DB faster
  backup_retention_period = 0
  # Not allowed to specify a subnet group for replicas in the same region
  create_db_subnet_group    = false
  create_db_option_group    = false
  create_db_parameter_group = false
}
