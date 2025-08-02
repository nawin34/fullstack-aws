provider "aws" {
  region = "ap-south-1"
}

variable "react_bucket_name" {
  type    = string
  default = "akki-react-frontend-2025"
}

variable "ec2_key_pair" {
  type    = string
  default = "akki-ec2-key"
}

variable "private_key_path" {
  type        = string
  description = "Path to the SSH private key"
  default     = "../ec2_key.pem"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.react_bucket_name

  tags = {
    Name = "ReactFrontendHosting"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend_ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_instance" "backend_instance" {
  ami                         = "ami-0f5ee92e2d63afc18"
  instance_type               = "t2.micro"
  key_name                    = var.ec2_key_pair
  associate_public_ip_address = true

  tags = {
    Name = "SpringBootBackend"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install java-17-amazon-corretto -y"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

resource "aws_apigatewayv2_api" "backend_api" {
  name          = "SpringBootHTTPAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "backend_integration" {
  api_id                 = aws_apigatewayv2_api.backend_api.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = "http://${aws_instance.backend_instance.public_ip}:8080"
  integration_method     = "ANY"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "proxy_route" {
  api_id    = aws_apigatewayv2_api.backend_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.backend_integration.id}"
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id      = aws_apigatewayv2_api.backend_api.id
  name        = "dev"
  auto_deploy = true
}

output "react_frontend_url" {
  value = aws_s3_bucket.frontend_bucket.website_endpoint
}

output "springboot_backend_ip" {
  value = aws_instance.backend_instance.public_ip
}

output "api_gateway_endpoint" {
  value = aws_apigatewayv2_stage.dev_stage.invoke_url
}
