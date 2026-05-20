locals {
  name_prefix = "${var.project}-${var.env}"

  azs = ["${var.aws_region}a", "${var.aws_region}c"]

  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]
  db_subnets      = ["10.20.21.0/24", "10.20.22.0/24"]

  common_tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  }
}
