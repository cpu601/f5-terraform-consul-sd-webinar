#
# Create IAM Role for Consul
#
resource "aws_iam_role" "consul" {
  name = "${var.prefix}-f5-consul-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "consul" {
  name = "${var.prefix}-f5-consul-policy"
  role = aws_iam_role.consul.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "consul" {
  name = "${var.prefix}-consul_sd"
  role = aws_iam_role.consul.name
}

#
# Create IAM Role for BIG-IP
#
resource "aws_iam_role" "bigip_role" {
  name               = "${var.prefix}-bigip-role"
  assume_role_policy = data.aws_iam_policy_document.bigip_role.json

  tags = {
    tag-key = "tag-value"
  }
}

data "aws_iam_policy_document" "bigip_role" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# resource "aws_iam_role_policy" "bigip_policy" {
#   name   = "${var.prefix}-bigip-policy"
#   role   = aws_iam_role.bigip_role.id
#   policy = data.aws_iam_policy_document.bigip_policy.json
# }

# data "aws_iam_policy_document" "bigip_policy" {
#   version = "2012-10-17"
#   statement {
#     actions = [
#       "secretsmanager:GetSecretValue"
#     ]

#     resources = [
#       "${data.aws_secretsmanager_secret.bigip_password.arn}"
#     ]
#   }
# }

resource "aws_iam_instance_profile" "bigip_profile" {
  name = "${var.prefix}-bigip-profile"
  role = aws_iam_role.bigip_role.name
}