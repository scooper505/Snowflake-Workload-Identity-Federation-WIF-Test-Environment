terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 2.0.0"
    }
  }
}


# ____AWS PROVIDER____
provider "aws" {
  region = var.region
}

# ___SNOWFLAKE PROVIDER___
# You must identify which authN mechninism you will use. You’ll pick *either* key-pair auth or OAuth depending on how you set variables.
# Can comment out Snowflake parts to just test AWS
# Option A: Key-pair authentication


provider "snowflake" {
  organization_name        = var.snowflake_organization_name
  account_name             = var.snowflake_account_name
  user                     = var.snowflake_username
  role                     = var.snowflake_role
  authenticator            = "SNOWFLAKE_JWT"
  preview_features_enabled = ["snowflake_current_account_datasource"]
}

