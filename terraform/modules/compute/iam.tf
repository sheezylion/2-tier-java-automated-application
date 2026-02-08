############################################
# EC2 ROLE
############################################

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

############################################
# SSM ACCESS
############################################

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################################
# SECRETS MANAGER READ
############################################

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

############################################
# EC2 DOWNLOAD ARTIFACTS
############################################

resource "aws_iam_policy" "artifact_read" {
  name = "${var.project_name}-${var.environment}-artifact-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject"]
      Resource = "arn:aws:s3:::votingapp-artifacts-dev-12345/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "artifact_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.artifact_read.arn
}

############################################
# INSTANCE PROFILE
############################################

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-${var.environment}-instance-profile"
  role = aws_iam_role.ec2.name
}

############################################
# GITHUB USER
############################################

resource "aws_iam_user" "github" {
  name = "${var.project_name}-${var.environment}-github"
}

resource "aws_iam_policy" "github_artifact_upload" {
  name = "${var.project_name}-${var.environment}-github-upload"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject"
      ],
      Resource = "arn:aws:s3:::votingapp-artifacts-dev-12345/*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "github_attach" {
  user       = aws_iam_user.github.name
  policy_arn = aws_iam_policy.github_artifact_upload.arn
}

resource "aws_iam_access_key" "github" {
  user = aws_iam_user.github.name
}

############################################
# OUTPUTS 
############################################

output "github_access_key_id" {
  value = aws_iam_access_key.github.id
}

output "github_secret_access_key" {
  value     = aws_iam_access_key.github.secret
  sensitive = true
}
