terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # ------------------------------------------------------------------
  # S3 + DynamoDB backend – uncomment and fill in after bootstrapping
  # ------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "petclinic-terraform-state"
  #   key            = "envs/dev/terraform.tfstate"
  #   region         = "ap-northeast-1"
  #   encrypt        = true
  #   dynamodb_table = "petclinic-terraform-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "petclinic"
      Environment = var.env
      ManagedBy   = "terraform"
    }
  }
}
