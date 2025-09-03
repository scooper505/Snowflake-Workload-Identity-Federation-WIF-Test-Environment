# iam.tf

# Trust policy: allow EC2 to assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
  tags               = local.common_tags
}

# Attach SSM core so you can use Session Manager (no inbound SSH needed)
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Placeholder policy for future WIF/token-broker needs (tighten to least-privilege later)
resource "aws_iam_role_policy" "wif_placeholder" {
  name = "${var.name_prefix}-wif-placeholder"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowDescribeAndGetParameters",
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory"
        ],
        Resource = "*"
      }
    ]
  })
}

# Instance profile to attach the role to the EC2 instance
resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.ec2.name
  tags = local.common_tags
}

# --- Snowflake IAM notes (commented out for AWS-only template) ---
# When you add a token-broker (Lambda/ECS) or direct OIDC exchange later,
# you may need additional IAM permissions here, e.g.:
#
# resource "aws_iam_role_policy" "wif_broker_access" {
#   name = "${var.name_prefix}-wif-broker"
#   role = aws_iam_role.ec2.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid: "CallBroker",
#         Effect: "Allow",
#         Action: ["execute-api:Invoke"],                  # or "lambda:InvokeFunction"
#         Resource: "arn:aws:execute-api:...:...:.../*"    # tighten to your broker endpoint
#       }
#     ]
#   })
# }