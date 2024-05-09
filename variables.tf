# Define input variables
variable "aws_region" {
  description = "The AWS region"
}

variable "mysql_image" {
  description = "The MySQL Docker image"
}

variable "wordpress_image" {
  description = "The WordPress Docker image"
}

variable "mysql_root_password" {
  description = "The password for the MySQL root user"
}

variable "subnets" {
  description = "The subnets for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "The security groups for the ECS service"
  type        = list(string)
}
