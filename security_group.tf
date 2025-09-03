# security_group.tf

resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for Snowflake WIF test EC2"
  vpc_id      = var.vpc_id

  # Egress: allow all by default (simplest for a first template).
  # We'll tighten this later to specific endpoints (Snowflake, IdP/broker, SSM).
  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress: NONE by default (use SSM Session Manager).
  # Optional SSH if explicitly enabled.
  dynamic "ingress" {
    for_each = var.allow_ssh ? [1] : []
    content {
      description = "Optional SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_cidr]
    }
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-sg"
    },
    local.common_tags
  )
}

# --- Future hardening ideas (commented out for now) ---
# resource "aws_vpc_security_group_egress_rule" "to_snowflake" {
#   security_group_id = aws_security_group.ec2.id
#   cidr_ipv4         = "<Snowflake egress CIDR or resolved IPs>"   # Prefer PrivateLink instead of public egress.
#   ip_protocol       = "tcp"
#   from_port         = 443
#   to_port           = 443
#   description       = "Egress to Snowflake over HTTPS"
# }
#
# resource "aws_vpc_security_group_egress_rule" "to_idp_broker" {
#   security_group_id = aws_security_group.ec2.id
#   cidr_ipv4         = "<IdP/broker CIDR or SG>"
#   ip_protocol       = "tcp"
#   from_port         = 443
#   to_port           = 443
#   description       = "Egress to IdP/token broker for WIF"
# }