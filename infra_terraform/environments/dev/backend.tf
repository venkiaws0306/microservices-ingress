terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_YOUR_UNIQUE_TF_STATE_BUCKET"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "REPLACE_WITH_YOUR_TF_LOCK_TABLE"
    # use_lockfile = "REPLACE_WITH_YOUR_TF_LOCK_TABLE"
    encrypt        = true
  }
}
