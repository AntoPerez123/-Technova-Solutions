# =========================
# VPC module
# =========================
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs
}

# =========================
# Security Groups module
# =========================
module "security_groups" {
  source = "../../modules/security_groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# =========================
# ECR module
# =========================
module "ecr" {
  source = "../../modules/ecr"

  project_name     = var.project_name
  repository_names = var.ecr_repository_names
}

# =========================
# ALB module
# =========================
module "alb" {
  source = "../../modules/alb"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  sg_alb_id      = module.security_groups.sg_alb_id

  depends_on = [
    module.vpc,
    module.security_groups
  ]
}

# =========================
# RDS module
# =========================
module "rds" {
  source = "../../modules/rds"

  project_name    = var.project_name
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  private_subnets = module.vpc.private_subnets
  sg_rds_id       = module.security_groups.sg_rds_id

  depends_on = [
    module.vpc,
    module.security_groups
  ]
}

# =========================
# EC2 Auto Scaling module
# =========================
module "ec2_asg" {
  source = "../../modules/ec2_asg"

  project_name    = var.project_name
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  private_subnets = module.vpc.private_subnets
  sg_ec2_id       = module.security_groups.sg_ec2_id

  target_group_arns = [
    module.alb.tg_frontend_arn,
    module.alb.tg_backend_arn
  ]

  db_host     = module.rds.db_address
  db_user     = var.db_username
  db_password = var.db_password
  db_name     = var.db_name

  depends_on = [
    module.alb,
    module.rds
  ]
}