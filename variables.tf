variable "region" {
  type = string
  default = "us-east-1"
}

variable "public_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnet_availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "web_ami" {
  type    = string
  default = "ami-1234567890"
}

variable "web_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "web_user_data" {
  type    = string
  default = "#!/bin/bash\necho 'Hello, world!' > /var/www/html/index.html"
}

variable "app_ami" {
  type    = string
  default = "ami-0987654321"
}

variable "app_instance_type" {
  type    = string
  default = "t2"
}

variable "app_user_data" {
  type    = string
  default = "#!/bin/bash;sudo apt-get update;sudo apt-get install -y apache2"
}

variable "target_group_arns" {
  type = list(string)
  default = [
    "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-target-group/1234567890123456",
    "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-other-target-group/1234567890123456"
  ]
}

variable "aws_lb_target_group" {
  type        = string
  default     = "my-target-group"
}

