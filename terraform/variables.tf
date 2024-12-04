variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type = string
  default = "us-east-2"
}

variable "aws_vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "aws_subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "aws_availability_zone" {
  default = "us-east-2a"
}

variable "environment" {
  description = "The deployment environment (e.g. dev, staging, prod)"
  type = string
  default = "prod"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type = string
  default = "stratocraft-image"
}

variable "project_name" {
  description = "Name of the project"
  type = string
  default = "stratocraft"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repo"
  type = string
  default = "stratocraft-ecr-repo"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type = string
  default = "stratocraft-ecs-cluster"
}

variable "ecs_task_definition_family" {
  default = "stratocraft-task-family"
}

variable "ecs_service_name" {
  default = "stratocraft-ecs-svc"
}

variable "ecs_security_group_name" {
  default = "stratocraft-ecs-sg"
}

variable "ecs_execution_name" {
  default = "stratocraft-ecs-execution"
}

variable aws_route53_zone {
  default = "stratocraft.dev"
}

variable aws_route53_domain {
  default = "stratocraft.dev"
}
