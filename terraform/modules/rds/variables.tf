variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "db_subnet_ids" {
  description = "Subnet IDs for DB subnet group"
  type        = list(string)
}

variable "ecs_security_group_ids" {
  description = "Security group IDs of ECS tasks allowed to connect"
  type        = list(string)
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = 50
}

variable "max_allocated_storage" {
  description = "Max allocated storage for autoscaling in GiB"
  type        = number
  default     = 200
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "petclinic"
}

variable "db_master_username" {
  description = "Master username"
  type        = string
  default     = "petclinic_admin"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
