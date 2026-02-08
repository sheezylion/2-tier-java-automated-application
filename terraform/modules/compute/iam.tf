# IAM for EC2 (SSM + Secrets)

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}


# Attach SSM policy to EC2 role

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Allow read access to Secrets Manager

resource "aws_iam_policy" "secrets_read" {
  name = "${var.project_name}-${var.environment}-secrets-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.db_secret_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.secrets_read.arn
}


# Instance Profile for EC2

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-${var.environment}-instance-profile"
  role = aws_iam_role.ec2.name
}

# s3 bucket access policy for Ansible deployment
resource "aws_iam_policy" "ansible_ssm_s3" {
  name = "${var.project_name}-${var.environment}-ansible-ssm-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::votingapp-tf-state-dev-123456/ansible-ssm/*"
      },
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::votingapp-tf-state-dev-123456"
        Condition = {
          StringLike = {
            "s3:prefix": ["ansible-ssm/*"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ansible_ssm_s3" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ansible_ssm_s3.arn
}
