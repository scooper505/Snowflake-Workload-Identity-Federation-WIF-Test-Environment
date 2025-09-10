```markdown
# Snowflake Workload Identity Federation (WIF) Test Environment

A Terraform module to deploy a secure AWS EC2 instance for testing Snowflake Workload Identity Federation (WIF). This allows an AWS IAM role to authenticate to Snowflake instead of using passwords or keys.

## Quick Start

### Prerequisites
- Terraform >= 1.5.0
- AWS CLI configured
- Snowflake ACCOUNTADMIN privileges
- An existing VPC and private subnet

### Deployment
1. **Clone the repository**
   ```bash
   git clone https://github.com/scooper505/Snowflake-Workload-Identity-Federation-WIF-Test-Environment
   cd Snowflake-Workload-Identity-Federation-WIF-Test-Environment
   

2. **Configure variables**
   Create a `terraform.tfvars` file:
   ```hcl
   region    = "us-east-1"
   vpc_id    = "vpc-yourvpc"
   subnet_id = "subnet-yoursubnet"

   snowflake_account_name = "your_account"
   snowflake_username     = "your_terraform_user"
   snowflake_role         = "ACCOUNTADMIN"

   wif_user_name = "WIF_TEST_USER"
   wif_role_name = "WIF_TEST_ROLE"
   

3. **Deploy**
   
   terraform init
   terraform apply
   

4. **Connect and Test**
   Connect via AWS SSM Session Manager (no SSH key needed):
   
   aws ssm start-session --target $(terraform output -raw instance_id)
   
   Run the test script inside the instance:
   
   sudo su -
   python3 /opt/snowflake-test/test_snowflake.py
   

## Architecture
This module creates:
- **AWS**: An EC2 instance with an IAM role, security group, and necessary WIF trust policy.
- **Snowflake**: A database user, role, and grants configured for Workload Identity Federation.

## Security
- No public IP or SSH access; uses AWS SSM for secure shell access.
- Enforces IMDSv2 and least-privilege IAM policies.
- All resources are tagged for cost tracking.

## Cleanup
To destroy all resources and avoid ongoing charges:
bash
terraform destroy


##  Documentation
- [Snowflake WIF Documentation](https://docs.snowflake.com/en/user-guide/federation-aws)
- [AWS Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)



### Option 2: Slightly More Detailed (With TOC)

This version includes a table of contents for easier navigation on GitHub.

```markdown
# Snowflake WIF Test Environment

Terraform module to provision an isolated test environment for Snowflake Workload Identity Federation on AWS.

## Table of Contents
- [Overview](#overview)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Outputs](#outputs)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)

## Overview
This module automates the setup of a secure AWS EC2 instance and the corresponding Snowflake configuration to test Workload Identity Federation. This enables authentication to Snowflake using an AWS IAM role.

**Architecture Diagram:**

[EC2 w/ IAM Role] --assumes--> [AWS IAM] --authenticates--> [Snowflake]


## Quick Start

1. **Clone the repo** and `cd` into the directory.
2. **Create a `terraform.tfvars`** file with your settings (see example below).
3. Run `terraform init` and `terraform apply`.
4. Connect to the instance using the output SSM command and run the test script.

### Example `terraform.tfvars`
```hcl
# AWS Config
region    = "us-east-1"
vpc_id    = "vpc-12345"
subnet_id = "subnet-12345"

# Snowflake Config (for Terraform provider)
snowflake_account_name = "myaccount"
snowflake_username     = "terraform_user"
snowflake_role         = "ACCOUNTADMIN"

# WIF Test User
wif_user_name = "WIF_TEST_USER"
wif_role_name = "WIF_TEST_ROLE"


## Configuration
| Variable | Description | Default |
| :--- | :--- | :--- |
| `region` | AWS region to deploy to | *required* |
| `vpc_id` | VPC for the EC2 instance | *required* |
| `subnet_id` | Private subnet for the EC2 instance | *required* |
| `instance_type` | EC2 instance type | `"t3.micro"` |

## Outputs
- `instance_id`: ID of the provisioned EC2 test instance.
- `ssm_start_session_command`: The AWS CLI command to start an SSM session.
- `wif_role_arn`: The ARN of the IAM role created for WIF.

## Cleanup
Destroy all resources with:
```bash
terraform destroy -auto-approve


## Troubleshooting
- **SSM Connection Issues**: Ensure the EC2 instance is in a private subnet with a route to the internet (NAT Gateway) or VPC Endpoints.
- **Snowflake Connection**: Check the test script on the instance at `/opt/snowflake-test/test_snowflake.py`.


**Recommendation:** Use **Option 1**. It's modern, clean, and gets the user from zero to a working environment in the fewest possible steps, which is the primary goal of a good README.
