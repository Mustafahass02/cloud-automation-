# AWS Terraform Showcase Project

> A production-ready infrastructure-as-code project demonstrating a secure, scalable web application architecture on AWS using Terraform. Designed to showcase technical understanding of cloud infrastructure for interview purposes.

---

## Architecture Overview

```
Users
  │
  ▼
Route 53 ──► ACM (SSL/TLS)
  │
  ▼
Application Load Balancer          [Public Subnet: 10.0.1.0/24]
  │
  ▼
Elastic Beanstalk Environment      [Private Subnet]
  └── EC2 (Corretto 17 / Java)
        │
        ├──► DynamoDB Table         [Managed NoSQL - PAY_PER_REQUEST]
        │
        └──► Secrets Manager        [Credential Store]

Internet Gateway ◄──► Public Subnet ◄──► NAT Gateway ◄──► Private Subnet
```


![Elastic Beanstalk Screenshot](./Screenshot%202026-03-15%20at%2000.30.48.png)


Traffic flows from the public internet through Route 53 and an ACM-secured ALB into an Elastic Beanstalk-managed EC2 environment. The application communicates with DynamoDB as its backend database, with credentials stored securely in Secrets Manager. A NAT Gateway allows private instances to make outbound calls without direct internet exposure.

---

## AWS Services Used

| Service | Purpose |
|---|---|
| **VPC** (`10.0.0.0/16`) | Isolated network containing all resources |
| **Internet Gateway** | Entry point for public internet traffic |
| **Public Subnet** (`10.0.1.0/24`) | Hosts the ALB and NAT Gateway |
| **Route Table** | Directs `0.0.0.0/0` traffic to the Internet Gateway |
| **NAT Gateway** | Allows private instances to reach the internet securely |
| **Elastic IP** | Static IP allocated to the NAT Gateway |
| **Elastic Beanstalk** | Manages EC2 provisioning, scaling, and app deployment |
| **EC2** (`t3.micro`) | Runs the Java application via Amazon Corretto 17 |
| **DynamoDB** | Serverless NoSQL database (`PAY_PER_REQUEST` billing) |
| **Secrets Manager** | Stores sensitive credentials securely |
| **ACM** | Provisions SSL/TLS certificate via DNS validation |

---

## Project Structure

```
terraform-project/
│
├── provider.tf        # AWS provider — region: us-east-1
├── variables.tf       # Input variable declarations and defaults
├── main.tf            # All resource definitions
└── outputs.tf         # Exported values after apply
```

---

## Variables

| Variable | Description | Default |
|---|---|---|
| `vpc_cidr` | CIDR block for the VPC | `10.0.0.0/16` |
| `public_subnet_cidr` | CIDR for the public subnet | `10.0.1.0/24` |
| `instance_type` | EC2 instance type for Beanstalk | `t3.micro` |
| `app_name` | Name of the Beanstalk application | `beanstalk-demo` |
| `domain_name` | Domain for ACM certificate | *(required — no default)* |

---

## Outputs

| Output | Description |
|---|---|
| `beanstalk_url` | The live endpoint URL of the Elastic Beanstalk environment |

---

## How the Architecture Works

1. **Route 53** resolves the domain and routes traffic to the Application Load Balancer
2. **ACM** provides the SSL/TLS certificate (DNS-validated) enabling HTTPS on the ALB
3. **ALB** terminates HTTPS and forwards requests to EC2 instances managed by Elastic Beanstalk
4. **Elastic Beanstalk** runs the application on EC2 using Amazon Corretto 17 (Java 17), with `t3.micro` instances and auto scaling configured
5. **EC2 instances** interact with **DynamoDB** to read and write application data
6. **Secrets Manager** stores sensitive values such as API keys and database credentials, keeping them out of the codebase
7. **NAT Gateway** (with an Elastic IP) allows the private EC2 instances to make outbound internet calls without being directly reachable from the internet

---

## Key Terraform Concepts Demonstrated

**Resource references** — resources reference each other by attribute:
```hcl
subnet_id = aws_subnet.public.id
vpc_id    = aws_vpc.main.id
```

**Variables** — parameterise the configuration for reusability:
```hcl
variable "app_name" {
  type    = string
  default = "beanstalk-demo"
}
```

**Outputs** — expose important values after `terraform apply`:
```hcl
output "beanstalk_url" {
  value = aws_elastic_beanstalk_environment.env.endpoint_url
}
```

**Beanstalk settings blocks** — configure managed services declaratively:
```hcl
setting {
  namespace = "aws:autoscaling:launchconfiguration"
  name      = "InstanceType"
  value     = var.instance_type
}
```

---

## Deployment (If Required)

```bash
# 1. Initialise Terraform and download providers
terraform init

# 2. Preview the execution plan
terraform plan -var="domain_name=yourdomain.com"

# 3. Deploy all resources
terraform apply -var="domain_name=yourdomain.com"

# 4. Retrieve the application URL
terraform output beanstalk_url

# 5. Tear down all resources when done
terraform destroy
```

---

## Design Decisions

- **PAY_PER_REQUEST billing on DynamoDB** — avoids provisioned capacity costs for a showcase project; scales automatically with traffic
- **DNS validation for ACM** — preferred over email validation as it can be automated and renewed without manual intervention
- **Elastic Beanstalk over raw EC2** — reduces operational overhead by abstracting instance management, load balancing, and deployment pipelines
- **NAT Gateway in public subnet** — follows AWS best practice; private instances never have public IPs but can still reach external APIs or package repositories
- **Secrets Manager over environment variables** — credentials are never stored in code or config files, reducing the risk of accidental exposure

---

## Notes

- This project is designed for **showcase and demonstration purposes** and is not deployed live
- All resources are ready to deploy with a single `terraform apply` command
- The `domain_name` variable has no default and **must be supplied** at plan/apply time
- The Beanstalk environment targets **Amazon Linux 2 with Corretto 17** — suitable for Spring Boot or any Java 17 application

---

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/)
- [AWS DynamoDB](https://aws.amazon.com/dynamodb/)
- [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/)
- [AWS Secrets Manager](https://aws.amazon.com/secretsmanager/)
- [AWS NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
