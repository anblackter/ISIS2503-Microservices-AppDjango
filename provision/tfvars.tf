# Global variables
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "isis2503-lab-9"
}

# VPC Variables
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.128.0.0/16"
}


variable "kong_ip" {
  type = string
  default = "10.128.0.81"

}

variable "variables_db_ip" {
  type = string
  default = "10.128.0.82"

}

variable "measurements_db_ip" {
  type = string
  default = "10.128.0.83"

}

variable "variables_ms_ip" {
  type = string
  default = "10.128.0.84"

}

variable "measurements_ms_ip" {
  type = string
  default = "10.128.0.85"

}

variable "places_db_ip" {
  type = string
  default = "10.128.0.86"

}

variable "places_ms_ip" {
  type = string
  default = "10.128.0.87"

}

# EC2 Variable
variable "ec2_instance_type" {
  type    = string
  default = "t2.small"  # 1 vCPU 2 GiB
}

variable "ssh_key_name" {
  type        = string
  description = "SSH Key used to create the EC2 instance"
  default     = "remote-ssh-key-pair"
}

# ECR Variable
variable "repository_name" {
  type = string
  default = "api-consumption"
}

variable "keep_tags_number" {
  description = "The number of image tags to retain in the registry."
  type        = number
  default     = 10
}

# Lambda Variable
variable "lambda_name" {
  description = "Lambda function name"
  type        = string
  default     = "api-consumption"
}

variable "image_version" {
  description = "major.minor.patch version of the image"
  type        = string
  nullable    = false
  default     = "latest"
}
