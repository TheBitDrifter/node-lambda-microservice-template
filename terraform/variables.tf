variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "lambda-service"
}

variable "platform_state_bucket" {
  description = "S3 bucket name where the platform state is stored"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to the zipped Lambda code (injected by CI/CD)"
  type        = string
}
