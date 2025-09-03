# locals.tf

locals {
  # Render the EC2 user_data from the template file.
  # The template installs Python, sets up a venv, installs the Snowflake connector,
  # and writes out a test script.
  user_data = ""

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
