variable "environment" {
  description = "Deployment Env"
  type        = string
  default     = "dev-env"
}

variable "vpc_cidr" {
  description = "vpc from tf"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_pub_cidr" {
  type        = string
  description = "subnet public"
  default     = "10.0.1.0/24"
}

variable "subnet_pri_cidr" {
  type        = string
  description = "subnet private"
  default     = "10.0.2.0/24"
}

variable "region" {
  type        = string
  description = "Region in which the bastion host will be launched"
  default     = "us-east-1"
}

