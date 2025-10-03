resource "aws_ecr_repository" "api-consumption" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.api-consumption.name
  policy     = local.policy_document
}

# Get ECR login token
data "aws_ecr_authorization_token" "token" {}

# Build and push Docker image
resource "null_resource" "build_and_push_image" {
  triggers = {
    # Trigger rebuild when lambda code changes
    lambda_code_hash = filemd5("${path.module}/lambda/lambda_function.py")
    dockerfile_hash  = filemd5("${path.module}/lambda/Dockerfile")
    requirements_hash = filemd5("${path.module}/lambda/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Login to ECR
      echo ${data.aws_ecr_authorization_token.token.password} | docker login --username AWS --password-stdin ${data.aws_ecr_authorization_token.token.proxy_endpoint}

      # Build the image
      cd ${path.module}/lambda
      docker build -t ${aws_ecr_repository.api-consumption.repository_url}:latest .

      # Tag the image
      docker tag ${aws_ecr_repository.api-consumption.repository_url}:latest ${aws_ecr_repository.api-consumption.repository_url}:latest

      # Push the image
      docker push ${aws_ecr_repository.api-consumption.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.api-consumption]
}