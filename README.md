# Snowflake Workload Identity Federation (WIF) Test Environment

A Terraform module to deploy a secure AWS EC2 instance for testing **Snowflake Workload Identity Federation (WIF)**. This enables secure authentication to Snowflake using an AWS IAM role, eliminating the need for password or key-based credentials.

##  Quick Start

### Prerequisites
- **Terraform** >= 1.5.0
- A configured Terraform to Snowflake connection - A Snowflake user with appropriate permissions to support Terraform automation in Snowflake 
- **Snowflake** ACCOUNTADMIN privileges may also help to confirm resouces
- **AWS CLI** configured with appropriate permissions
- An existing AWS **VPC and private subnet**

### Deployment Steps

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/scooper505/Snowflake-Workload-Identity-Federation-WIF-Test-Environment
    cd Snowflake-Workload-Identity-Federation-WIF-Test-Environment
    ```

2.  **Configure Variables**
    Create a `terraform.tfvars` file with your specific values:
    ```hcl
    # AWS Infrastructure
    region    = "your AWS region"
    vpc_id    = "vpc-yourvpcid"
    subnet_id = "subnet-yoursubnetid"

    # Snowflake Provider Authentication (for Terraform)
    snowflake_account_name = "your_account_identifier"
    snowflake_username     = "your_terraform_user"
    snowflake_role         = "ACCOUNTADMIN"

    # WIF Test Resources (to be created in Snowflake)
    wif_user_name = "WIF_TEST_USER"
    wif_role_name = "WIF_TEST_ROLE"

    # NOTE: Depending on the authentication being used to connect Terraform to Snowflake, you may also want to include variables for key pair location if using key pair.
    # Example: snowflake_private_key_path = "<KEY PATH HERE>"

    ```

3.  **Deploy the Infrastructure**
    # Once you have your access confired and variables configured, run your Terraform commands to deploy your resources via Terraform
    
    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

4.  **Connect and Test**
    Connect to the test instance via AWS SSM Session Manager :
    ```bash
    aws ssm start-session --target $(terraform output -raw instance_id)
    ```
    Once connected, run the test script:
    ```bash
    sudo su -
    python3 /opt/snowflake-test/test_snowflake.py
    ```

## Architecture

This module creates the following resources:

-   **In AWS:**
    -   An EC2 instance in a private subnet.
    -   An IAM Role with a trust policy for Snowflake WIF.
    -   A Security Group with minimal, necessary rules.
    -   An IAM Instance Profile.

-   **In Snowflake:**
    -   A database Role (`WIF_TEST_ROLE`) with permissions.
    -   A Service User (`WIF_TEST_USER`) configured for `WORKLOAD_IDENTITY` authentication.
    -   Necessary grants on a warehouse, database, and schema.

##  Security Features

-   **No SSH Access**: Secure access is provided exclusively via AWS Systems Manager (SSM).
-   **IMDSv2 Enforced**: Protects against SSRF attacks by requiring the latest instance metadata service.
-   **Least Privilege IAM**: The EC2 IAM role is granted only the permissions essential for WIF.
-   **Private Networking**: The EC2 instance is deployed without a public IP address.
-   **Encrypted Storage**: All associated EBS volumes are encrypted at rest.

##  Cleanup

To destroy all created resources and avoid ongoing AWS charges, run:

```bash
terraform destroy
