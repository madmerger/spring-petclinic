################################################################################
# Network
################################################################################
module "network" {
  source = "./modules/network"

  name_prefix     = local.name_prefix
  vpc_cidr        = var.vpc_cidr
  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  db_subnets      = local.db_subnets
  tags            = local.common_tags
}

################################################################################
# ALB
################################################################################
module "alb" {
  source = "./modules/alb"

  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  certificate_arn   = var.certificate_arn
  tags              = local.common_tags
}

################################################################################
# ECS
################################################################################
module "ecs" {
  source = "./modules/ecs"

  name_prefix            = local.name_prefix
  aws_region             = var.aws_region
  vpc_id                 = module.network.vpc_id
  private_subnet_ids     = module.network.private_subnet_ids
  alb_security_group_ids = [module.alb.alb_security_group_id]
  target_group_arn       = module.alb.target_group_arn
  ecr_repository_name    = "${var.project}/${var.env}"

  task_cpu    = var.ecs_task_cpu
  task_memory = var.ecs_task_memory

  desired_count   = var.ecs_desired_count
  autoscaling_min = var.ecs_autoscaling_min
  autoscaling_max = var.ecs_autoscaling_max

  db_host       = module.rds.db_instance_address
  db_port       = module.rds.db_instance_port
  db_name       = module.rds.db_name
  db_secret_arn = module.rds.db_secret_arn

  tags = local.common_tags
}

################################################################################
# RDS
################################################################################
module "rds" {
  source = "./modules/rds"

  name_prefix            = local.name_prefix
  vpc_id                 = module.network.vpc_id
  db_subnet_ids          = module.network.db_subnet_ids
  ecs_security_group_ids = [module.ecs.ecs_security_group_id]

  instance_class = var.rds_instance_class
  multi_az       = var.rds_multi_az

  tags = local.common_tags
}
