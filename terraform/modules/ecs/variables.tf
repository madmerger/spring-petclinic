variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_ids" {
  description = "Security group IDs of the ALB"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "Task CPU units"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 2048
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "autoscaling_min" {
  description = "Minimum number of tasks"
  type        = number
  default     = 2
}

variable "autoscaling_max" {
  description = "Maximum number of tasks"
  type        = number
  default     = 6
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager secret ARN for DB credentials"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
