variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

variable "container_port" {
  description = "Container port for target group"
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
