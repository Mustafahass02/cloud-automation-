variable "vpc_cidr"{
    description = "VPC CIDR Block"
    type = string
    default = "10.0.0.0/16"
}

variable "app_name"{
    type = string 
    default = "beanstalk-demo"
}

variable "public_subnet_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "domain_name" {
  type = string
}