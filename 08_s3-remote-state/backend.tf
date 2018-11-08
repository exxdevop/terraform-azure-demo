# Quelle: https://medium.com/@jessgreb01/how-to-terraform-locking-state-in-s3-2dc9a5665cb6

# terraform {
#   backend "s3" {
#     encrypt = true
#     bucket = "exxeta-tf-remote-state-storage-s3"
#     region = "eu-central-1"
#     key = "demo/terraform.tfstate"
#   }
# }

# ========================================================================

resource "aws_s3_bucket" "terraform-state-storage-s3" {
    bucket = "exxeta-tf-remote-state-storage-s3"
 
    versioning {
      enabled = true
    }
 
    lifecycle {
      prevent_destroy = true
    }
 
    tags {
      Name = "S3 Remote Terraform State Store"
    }      
}

