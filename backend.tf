terraform {
  backend "s3" {
    bucket = "mybucket-gabe"
    key    = "k1/midterm-key"
    region = "us-east-1"
  }
}