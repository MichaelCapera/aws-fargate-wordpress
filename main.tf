# Define the AWS provider
provider "aws" {
  region = var.aws_region
}

# Define the ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

# Define the task definitions for MySQL and WordPress
resource "aws_ecs_task_definition" "mysql_task" {
  family                   = "mysql-task"
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name      = "mysql-container"
      image     = var.mysql_image
      cpu       = 512
      memory    = 1024
      portMappings = [
        {
          containerPort = 3306,
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "MYSQL_ROOT_PASSWORD", value = var.mysql_root_password }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "wordpress_task" {
  family                   = "wordpress-task"
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name      = "wordpress-container"
      image     = var.wordpress_image
      cpu       = 512
      memory    = 1024
      portMappings = [
        {
          containerPort = 80,
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "WORDPRESS_DB_HOST", value = "mysql-container:3306" },
        { name = "WORDPRESS_DB_USER", value = "root" },
        { name = "WORDPRESS_DB_PASSWORD", value = var.mysql_root_password }
      ]
    }
  ])
}

# Define the ECS services for MySQL and WordPress
resource "aws_ecs_service" "mysql_service" {
  name            = "mysql-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  desired_count   = 1
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  task_definition = aws_ecs_task_definition.mysql_task.arn

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }
}

resource "aws_ecs_service" "wordpress_service" {
  name            = "wordpress-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  desired_count   = 1
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  task_definition = aws_ecs_task_definition.wordpress_task.arn

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }
}
