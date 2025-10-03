terraform {
  backend "s3" {
    bucket = "isis2503-lab-ayhenao-terraform-state"
    key    = "lab/terraform.tfstate"
    region = "us-east-1"
  }
}