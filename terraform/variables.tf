# terraform/variables.tf
variable "project_name" { default = "cloud-cicd" }
variable "aws_region"   { default = "us-east-1" }
variable "vpc_cidr"     { default = "10.0.0.0/16" }
variable "key_pair_name" { description = "project1" }
variable "jenkins_ami"  { default = "ami-0c02fb55956c7d316" } # Amazon Linux 2
variable "app_ami"      { default = "ami-0c02fb55956c7d316" }