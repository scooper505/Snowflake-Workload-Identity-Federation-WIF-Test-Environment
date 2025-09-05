# locals.tf

locals {
  # Render the EC2 user_data from the template file.
  # The template installs Python, sets up a venv, installs the Snowflake connector,
  # and writes out a test script.
  user_data = templatefile("${path.module}/userdata.sh.tmpl", {
    test_script = templatefile("${path.module}/test_snowflake.py.tmpl", {
      snowflake_organization_name = var.snowflake_organization_name
      snowflake_account_name      = var.snowflake_account_name
      wif_default_warehouse       = var.wif_default_warehouse
      wif_test_database           = var.wif_test_database
      wif_test_schema             = var.wif_test_schema
    })
    snowflake_default_authenticator = "oauth"
    snowflake_default_account       = var.snowflake_account_name
  })

  # Enforce IMDSv2 (instance metadata service v2 only).
  imds_v2_required = true

  # Convenience name tags
  common_tags = merge(
    {
      Project = "snowflake-wif-ec2-test"
    },
    var.tags
  )
}
