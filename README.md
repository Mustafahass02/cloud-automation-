AWS Terraform Showcase Project

A production-ready infrastructure-as-code project demonstrating a secure, scalable web application architecture on AWS using Terraform. Designed to showcase technical understanding of cloud infrastructure for interview purposes.



![Elastic Beanstalk Screenshot](./Screenshot%202026-03-15%20at%2000.30.48.png)

AWS Services Used
ServicePurposeVPC (10.0.0.0/16)Isolated network containing all resourcesInternet GatewayEntry point for public internet trafficPublic Subnet (10.0.1.0/24)Hosts the ALB and NAT GatewayRoute TableDirects 0.0.0.0/0 traffic to the Internet GatewayNAT GatewayAllows private instances to reach the internet securelyElastic IPStatic IP allocated to the NAT GatewayElastic BeanstalkManages EC2 provisioning, scaling, and app deploymentEC2 (t3.micro)Runs the Java application via Amazon Corretto 17DynamoDBServerless NoSQL database (PAY_PER_REQUEST billing)Secrets ManagerStores sensitive credentials securelyACMProvisions SSL/TLS certificate via DNS validation

Project Structure
terraform-project/
│
├── provider.tf        # AWS provider — region: us-east-1
├── variables.tf       # Input variable declarations and defaults
├── main.tf            # All resource definitions
└── outputs.tf         # Exported values after apply

Variables
VariableDescriptionDefaultvpc_cidrCIDR block for the VPC10.0.0.0/16public_subnet_cidrCIDR for the public subnet10.0.1.0/24instance_typeEC2 instance type for Beanstalkt3.microapp_nameName of the Beanstalk applicationbeanstalk-demodomain_nameDomain for ACM certificate(required — no default)

Outputs
OutputDescriptionbeanstalk_urlThe live endpoint URL of the Elastic Beanstalk environment

How the Architecture Works

Route 53 resolves the domain and routes traffic to the Application Load Balancer
ACM provides the SSL/TLS certificate (DNS-validated) enabling HTTPS on the ALB
ALB terminates HTTPS and forwards requests to EC2 instances managed by Elastic Beanstalk
Elastic Beanstalk runs the application on EC2 using Amazon Corretto 17 (Java 17), with t3.micro instances and auto scaling configured
EC2 instances interact with DynamoDB to read and write application data
Secrets Manager stores sensitive values such as API keys and database credentials, keeping them out of the codebase
NAT Gateway (with an Elastic IP) allows the private EC2 instances to make outbound internet calls without being directly reachable from the internet


Key Terraform Concepts Demonstrated
Resource references — resources reference each other by attribute:
hclsubnet_id = aws_subnet.public.id
vpc_id    = aws_vpc.main.id
Variables — parameterise the configuration for reusability:
hclvariable "app_name" {
  type    = string
  default = "beanstalk-demo"
}
Outputs — expose important values after terraform apply:
hcloutput "beanstalk_url" {
  value = aws_elastic_beanstalk_environment.env.endpoint_url
}
Beanstalk settings blocks — configure managed services declaratively:
hclsetting {
  namespace = "aws:autoscaling:launchconfiguration"
  name      = "InstanceType"
  value     = var.instance_type
}

Deployment (If Required)
bash# 1. Initialise Terraform and download providers
terraform init

# 2. Preview the execution plan
terraform plan -var="domain_name=yourdomain.com"

# 3. Deploy all resources
terraform apply -var="domain_name=yourdomain.com"

# 4. Retrieve the application URL
terraform output beanstalk_url

# 5. Tear down all resources when done
terraform destroy

Design Decisions

PAY_PER_REQUEST billing on DynamoDB — avoids provisioned capacity costs for a showcase project; scales automatically with traffic
DNS validation for ACM — preferred over email validation as it can be automated and renewed without manual intervention
Elastic Beanstalk over raw EC2 — reduces operational overhead by abstracting instance management, load balancing, and deployment pipelines
NAT Gateway in public subnet — follows AWS best practice; private instances never have public IPs but can still reach external APIs or package repositories
Secrets Manager over environment variables — credentials are never stored in code or config files, reducing the risk of accidental exposure


Notes

This project is designed for showcase and demonstration purposes and is not deployed live
All resources are ready to deploy with a single terraform apply command
The domain_name variable has no default and must be supplied at plan/apply time
The Beanstalk environment targets Amazon Linux 2 with Corretto 17 — suitable for Spring Boot or any Java 17 application


References

Terraform AWS Provider
AWS Elastic Beanstalk
AWS DynamoDB
AWS Certificate Manager
AWS Secrets Manager
AWS NAT Gateway
