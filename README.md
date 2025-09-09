# Snowflake Workload Identity Federation (WIF) Test Environment

This Terraform project creates a complete testing environment for **Snowflake Workload Identity Federation (WIF)**, enabling secure AWS-to-Snowflake authentication using AWS IAM roles instead of traditional username/password credentials.

## Project Overview

The infrastructure consists of two main components:
- **AWS Resources**: Secure EC2 test environment with proper IAM roles
- **Snowflake Resources**: WIF-enabled service user with role-based permissions

##  Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   AWS EC2       │    │   AWS IAM Role   │    │   Snowflake     │
│                 │    │                  │    │                 │
│ • Python 3.11   │───▶│ • SSM Access     │───▶│ • WIF User      │
│ • Snowflake SDK │    │ • WIF Mapping    │    │ • Role Grants   │
│ • Test Scripts  │    │ • Least Privilege│    │ • DB/Schema     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Quick Start

### Prerequisites
- Terraform ≥ 1.5.0
- AWS CLI configured with appropriate permissions
- Snowflake account with admin privileges
- Existing VPC and private subnet
- Existing Snowflake user to support Terraform automation (ideally authenticates to Snowflake via key pair or OAuth)

### 1. Clone and Initialize
```bash
terraform init
```

### 2. Configure Variables
Create a `terraform.tfvars` file with your specific values (see Configuration section below).

### 3. Plan and Apply
```bash
terraform plan
terraform apply
```

### 4. Connect to Test Instance
```bash
# Get the connection command
terraform output ssm_start_session_command

# Connect via SSM (no SSH needed)
aws ssm start-session --target $(terraform output -raw instance_id) --region us-east-1
```

### 5. Test Snowflake Connectivity
```bash
# On the EC2 instance
sudo su -
source /opt/snowflake-test/venv/bin/activate

# Set your auth method (see Testing section below)
export SNOWFLAKE_AUTHENTICATOR=oauth
export SNOWFLAKE_OAUTH_TOKEN="your-oauth-token"

# Run the test
python /opt/snowflake-test/test_snowflake.py
```

## ⚙️ Configuration

### Required terraform.tfvars File

Create a `terraform.tfvars` file in the project root with the following configuration:

```hcl
# _____AWS INFRASTRUCTURE_____
region    = "YOUR REGION"
vpc_id    = "YOUR VPC ID"
subnet_id = "YOUR SUBNET IT"

# _____SNOWFLAKE CONNECTION FOR TERRAFORM AUTMATION_____
snowflake_organization_name = "ORG NAME"
snowflake_account_name      = "ACCOUNT NAME"
snowflake_role              = "SNOWFLAKE ROLE"
snowflake_username          = "YOUR USERNAME"




# _____WIF TEST USER_____
wif_user_name         = "YOUR WIF USER NAME"
wif_user_login_name   = "YOUR WIF USER LOGIN"
wif_role_name         = "YOUR ROLE NAME"
wif_default_warehouse = "YOUR WAREHOUSE"
wif_test_database     = "YOUR DB"
wif_test_schema       = "YOUR SCHEMA"
```

### Optional Variables

You can also customize these variables in your `terraform.tfvars`:

```hcl
# AWS Infrastructure Customization
name_prefix   = "my-wif-test"
instance_type = "t3.small"
os_family     = "ubuntu22.04"  # or "al2023"

# SSH Access (not recommended, use SSM instead)
allow_ssh = false
ssh_cidr  = "10.0.0.0/8"

# Resource Tags
tags = {
  Environment = "test"
  Project     = "snowflake-wif"
  Owner       = "your-name"
}
```

##  Security Features

- ** No SSH Access**: Uses AWS SSM Session Manager for secure shell access
- ** IMDSv2 Enforced**: Prevents SSRF attacks on instance metadata
- ** Encrypted Storage**: All EBS volumes encrypted at rest
- ** Private Networking**: No public IP addresses assigned
- ** Least Privilege IAM**: Minimal permissions for WIF functionality
- ** Security Groups**: Locked down with minimal egress rules

##  What Gets Created

### AWS Resources
- **EC2 Instance**: Test environment (t3.micro by default)
- **IAM Role**: For EC2 instance with SSM access + WIF permissions
- **IAM Instance Profile**: Attached to EC2 instance
- **Security Group**: Minimal access (egress only, no inbound SSH)

### Snowflake Resources
- **Account Role**: WIF TEST SNOWFLAKE ROLE for permission management
- **Service User**: WIF TEST SNOWFLAKE USER with WORKLOAD_IDENTITY mapping
- **Privileges**: Grants on warehouse, database, and schema for testing

### Software Installation (via user-data)
- **Python 3.11** (Amazon Linux 2023) or **Python 3.10+** (Ubuntu 22.04)
- **Snowflake Connector**: `snowflake-connector-python>=3.14`
- **Test Scripts**: Python script added to the EC2 via userdata. Test script uses Snowflake Python connector to connect to your Snowflake account.
- **SSM Agent**: To connect to the test EC2.





### Expected Output
```
snowflake-connector-python version: 3.14.x
('<YOUR WIF TEST USER>', '<YOUR ACCOUNT>', '8.x.x')
```

## 🔍 Troubleshooting

### Can't Connect via SSM
- Verify instance is in private subnet with SSM VPC endpoints or NAT Gateway
- Check IAM role has `AmazonSSMManagedInstanceCore` policy
- Ensure SSM agent is running: `sudo systemctl status amazon-ssm-agent`

### Python/Snowflake Connector Issues
```bash
# Activate the virtual environment
source /opt/snowflake-test/venv/bin/activate

# Verify installation
python -c "import snowflake.connector; print(snowflake.connector.__version__)"

# Review the script
sed -n '1,80p' /opt/snowflake-test/test_snowflake.py

# Run the connection test scrip
python /opt/snowflake-test/test_snowflake.py
```

### Snowflake Authentication Errors
- Verify OAuth token is valid and not expired
- Check that WIF user has been created successfully in Snowflake
- Ensure AWS role ARN matches the WORKLOAD_IDENTITY configuration

### Network/DNS Issues
- Verify egress rules allow HTTPS (443) to Snowflake endpoints
- Check DNS resolution if using custom DNS servers
- Consider VPC endpoints for enhanced security

##  Outputs

After successful deployment, you can access these outputs:

```bash
# View all outputs
terraform output

# Get specific values
terraform output instance_id
terraform output wif_role_arn
terraform output ssm_start_session_command
terraform output wif_test_role
terraform output wif_test_user
```

## 🔧 Customization

### Using a Different VPC/Subnet
Update your `terraform.tfvars`:
```hcl
vpc_id    = "vpc-your-vpc-id"
subnet_id = "subnet-your-subnet-id"
```

### Changing the Test Database/Schema
Update your `terraform.tfvars`:
```hcl
wif_test_database = "YOUR_DATABASE"
wif_test_schema   = "YOUR_SCHEMA"
```

### Using a Golden AMI
```hcl
ami_id = "ami-your-custom-ami-id"
```

## Cleanup

To destroy all resources:
```bash
terraform destroy -auto-approve
```

##  Additional Resources

- [Snowflake Workload Identity Federation Documentation](https://docs.snowflake.com/en/user-guide/admin-workload-identity-federation)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Snowflake Python Connector](https://docs.snowflake.com/en/developer-guide/python-connector/python-connector)

##  Important Notes

1. **Private Key Security**: Never commit your Snowflake private key to version control
2. **Terraform State**: Contains sensitive data - secure your state backend
3. **Test Environment**: This is designed for testing - harden further for production use
4. **Resource Costs**: Remember to destroy resources when not needed to avoid charges
5. **Network Access**: Ensure your private subnet has internet access for package installation

---

**Project Type**: Snowflake WIF Test Environment  
**Provider Versions**: AWS ~> 5.0, Snowflake ~> 2.0  
**Terraform Version**: ≥ 1.5.0