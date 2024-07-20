# AWS Infrastructure Deployment with Terraform

This repository contains Terraform configuration files to deploy a simple AWS infrastructure setup, including a VPC, subnet, internet gateway, route table, security group, EC2 instance, and S3 bucket.

## Infrastructure Components

1. **VPC**: Creates a Virtual Private Cloud with a CIDR block of `10.0.0.0/16`.
2. **Subnet**: Creates a public subnet within the VPC with a CIDR block of `10.0.1.0/24`.
3. **Internet Gateway**: Enables the VPC to communicate with the internet.
4. **Route Table**: Associates the route table with the subnet to route internet traffic through the internet gateway.
5. **Security Group**: Defines firewall rules for the EC2 instance.
    - Allows inbound SSH (port 22) from anywhere.
    - Allows inbound HTTPS (port 443) from anywhere.
    - Allows all outbound traffic.
6. **EC2 Instance**: Launches an EC2 instance with a specified AMI, instance type, key pair, and security group.
7. **S3 Bucket**: Configures an S3 bucket with versioning, server-side encryption, and a bucket policy.

## Security Group Configuration

- **Port 22 (SSH)**: Open to `0.0.0.0/0` to allow SSH access from any IP address. This is typically used for administrative purposes and should be restricted in a production environment.
- **Port 443 (HTTPS)**: Open to `0.0.0.0/0` to allow HTTPS access from any IP address. This is necessary for secure web traffic.

## Prerequisites

- Terraform installed on your local machine.
- AWS account with appropriate permissions to create resources.
- AWS CLI configured with your credentials.

## Deployment Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
2. Initialize Terraform

Initialize the Terraform working directory and download the necessary provider plugins.
terraform init

3. Set Up S3 Bucket

Before running terraform apply, you need to manually create the S3 bucket that will be used for the Terraform state backend.
aws s3api create-bucket --bucket my-statement-bucket --region eu-central-1
Ensure that the bucket name matches the one specified in the terraform block in main.tf.

4. Search for an AMI in Your Region

Use the following AWS CLI command to find a suitable AMI in your region. Replace <search-term> with a keyword related to the type of AMI you are looking for, such as "ubuntu" or "amazon linux".
aws ec2 describe-images --owners amazon --filters "Name=name,Values=<search-term>*" --query "Images[*].[ImageId,Name]" --output table --region eu-central-1
Select an appropriate AMI ID from the output and update the ami attribute in the aws_instance resource in main.tf.

5. Review and Modify Variables

Ensure that the main.tf and variables.tf files contain the correct configuration. Modify any variables as needed, such as the key_name for your EC2 instance.

6. Apply the Configuration

Apply the Terraform configuration to create the infrastructure.
terraform apply
Review the changes and type yes to confirm.

7. Access the Resources

After the deployment, you can access the EC2 instance using the public IP address and the specified SSH key.

Clean Up
To destroy the infrastructure and avoid incurring charges, run the following command:
terraform destroy
Review the changes and type yes to confirm.

