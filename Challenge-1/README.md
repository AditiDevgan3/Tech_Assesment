# Terraform AWS Infrastructure

This project sets up a comprehensive AWS infrastructure using Terraform. It includes the creation of a VPC, subnets, security groups, an application load balancer, a MySQL RDS instance, and auto-scaling EC2 instances.

## Project Structure
``` bash
├── network-module/
│ ├── main.tf
│ ├── variables.tf
│ └── provider.tf
└── envs/
└── dev/
├── main.tf
├── backend.tf
├── terraform.tfvars
└── variables.tf
```


- **network-module/**: Contains Terraform configurations for creating network resources.
  - **main.tf**: Defines AWS resources including VPC, subnets, security groups, load balancer, RDS instance, and auto-scaling group.
  - **variables.tf**: Defines variables used in the module.
  - **provider.tf**: Specifies the required Terraform version and AWS provider.

- **envs/dev/**: Contains Terraform configurations for the development environment.
  - **main.tf**: Invokes the network-module with specific variable values.
  - **backend.tf**: Configures the backend for storing the Terraform state in an S3 bucket.
  - **terraform.tfvars**: Provides values for variables used in the development environment.
  - **variables.tf**: Defines variables used in the development environment.

## Prerequisites

- Terraform (>= 0.13.5)
- AWS CLI configured with appropriate permissions
- S3 bucket and DynamoDB table for storing Terraform state

## Usage

1. **Initialize Terraform**

    Navigate to the `envs/dev` directory and initialize Terraform.

    ```sh
    cd envs/dev
    terraform init
    ```

2. **Review the execution plan**

    Generate and review the execution plan.

    ```sh
    terraform plan
    ```

3. **Apply the configuration**

    Apply the configuration to create the resources.

    ```sh
    terraform apply
    ```

4. **Destroy the infrastructure (optional)**

    To destroy the infrastructure when it is no longer needed.

    ```sh
    terraform destroy
    ```