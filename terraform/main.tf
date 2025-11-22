terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key     = "placeholder/state.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# --- 1. READ SHARED PLATFORM STATE ---
data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = var.platform_state_bucket
    key    = "platform/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# --- 2. DEFINE FUNCTIONS ---
locals {
  lambdas = {
    "hello" = {
      handler      = "functions/hello.handler"
      path_pattern = "/${var.service_name}/hello"
      method       = "GET"
    }
    "goodbye" = {
      handler      = "functions/goodbye.handler"
      path_pattern = "/${var.service_name}/goodbye"
      method       = "GET"
    }
  }
}

# --- 3. DEPLOY LAMBDA SERVICES ---
module "service" {
  source = "git::https://github.com/TheBitDrifter/terraform-aws-lambda-service.git?ref=main"
  # source = "../../terraform-aws-lambda-service"

  for_each = local.lambdas

  service_name    = "${var.service_name}-${each.key}"
  environment     = var.environment
  api_gateway_id  = data.terraform_remote_state.platform.outputs.api_gateway_id
  lambda_zip_path = var.lambda_zip_path

  handler      = each.value.handler
  path_pattern = each.value.path_pattern

  # Optional: VPC Config
  # vpc_id     = try(data.terraform_remote_state.platform.outputs.vpc_id, null)
  # subnet_ids = try(data.terraform_remote_state.platform.outputs.private_subnet_ids, [])
}

output "api_endpoints" {
  value = {
    for k, v in local.lambdas : k => "https://${data.terraform_remote_state.platform.outputs.api_gateway_id}.execute-api.${var.aws_region}.amazonaws.com${v.path_pattern}"
  }
}
