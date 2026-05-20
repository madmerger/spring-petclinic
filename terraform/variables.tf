variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "env" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "petclinic"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.20.0.0/16"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.medium"
}

variable "rds_multi_az" {
  description = "Enable RDS Multi-AZ"
  type        = bool
  default     = true
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_autoscaling_min" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_autoscaling_max" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 6
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  type        = number
  default     = 1024
}

variable "ecs_task_memory" {
  description = "Memory in MiB for ECS task"
  type        = number
  default     = 2048
}
