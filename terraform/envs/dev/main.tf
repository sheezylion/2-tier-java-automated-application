

module "vpc" {
  source          = "../../modules/vpc"
  project_name    = var.project_name
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security" {
  source       = "../../modules/security"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

module "secrets" {
  source = "../../modules/secrets"
  project_name = var.project_name
  environment  = var.environment
}

module "rds" {
  source             = "../../modules/rds"
  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  db_sg_id           = module.security.rds_sg_id
  db_name            = var.db_name
  db_secret_arn      = module.secrets.db_secret_arn
  secrets_dependency = module.secrets

  
}

module "alb" {
  source             = "../../modules/alb"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
}

module "compute" {
  source              = "../../modules/compute"
  project_name        = var.project_name
  environment         = var.environment
  private_subnet_ids  = module.vpc.private_subnet_ids
  app_sg_id           = module.security.app_sg_id
  instance_type       = var.instance_type
  target_group_arn    = module.alb.target_group_arn
  db_secret_arn       = module.secrets.db_secret_arn
  

}
