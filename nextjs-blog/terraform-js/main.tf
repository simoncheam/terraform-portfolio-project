provider "aws" {
  region = "us-east-1"

}


#s3 bucket
resource "aws_s3_bucket" "nextjs_bucket" {
  bucket = "sc-nextjs-portfolio-bucket"
}

# Ownership Control
resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_controls" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# block public access
resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
  bucket = aws_s3_bucket.nextjs_bucket.id

# disable block public access - can be publicly accessible
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}

# # Multiple layers of security

# Bucket ACL - access to control list - allows public access
resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {

  depends_on = [
    aws_s3_bucket_ownership_controls.nextjs_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block
  ]
  bucket = aws_s3_bucket.nextjs_bucket.id
  acl = "public-read"
}

# Bucket Policy - allows public access
resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  # IAM syntax
  policy = jsondecode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "PublicReadGetObject",
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.nextjs_bucket.arn}/*"
      }
    ]
  })
}