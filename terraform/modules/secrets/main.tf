# Generate a random password for the database

resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!#$%&()*+-.:;<=>?[]^_{|}~"
}

# Create a Secrets Manager secret to store the database credentials

resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.project_name}-${var.environment}-db-credentials"
  recovery_window_in_days = 0
  description             = "Database credentials for application"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Purpose     = "database-auth"
  }
}


# Store the generated password and username in the secret

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db.result
  })
}

