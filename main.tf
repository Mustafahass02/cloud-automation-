# VPC Creation
resource "aws_vpc" main{
    cidr_block = var.vpc_cidr
}
# internet gateway
resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.main.id 
}

# Public Subnet creation
resource "aws_subnet" "public"{
    vpc_id = aws.vpc.main.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true 

}

# route table attached to vpc
resource "aws_route_table" "public_rt"{
    vpc_id = aws.vpc.main.id 
}

# Internet route
resource "aws_route" "internet"{
    route_table_id = aws_route_table.public_rt.id 
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 
}

# attach route to public subnet
resource "aws_route_table_association" "public_assoc"{
    subnet_id = aws_subnet.public.id 
    route_table_id = aws_route_table.public_rt.id 
}

# NAT gateway

resource "aws_eip" "nat_ip" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id = aws_subnet.public.id
}


# Elastic Beanstalk Application creating the container
resource "aws_elastic_beanstalk_application" "app"{
    name = var.app_name
}

resource "aws_elastic_beanstalk_environment" "env" {
    name = "${var.app_name}"
    application = application = aws_elastic_beanstalk_application.app.name
   solution_stack_name = "64bit Amazon Linux 2 v5.6.7 running Corretto 17"

  setting {
     namespace = "aws:autoscaling:launchconfiguration"
     name      = "InstanceType"
     value     = var.instance_type
 }

}


resource "aws_dynamodb_table" "app_db" {
  name = "${var.app_name}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}


resource "aws_secretsmanager_secret" "db_secret" {
  name = "app-db-credentials"
}


resource "aws_acm_certificate" "cert" {
  domain_name = var.domain_name
  validation_method = "DNS"
}







