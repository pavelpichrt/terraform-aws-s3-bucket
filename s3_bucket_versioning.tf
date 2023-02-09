resource "aws_s3_bucket_versioning" "_" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.is_versioned == true ? "Enabled" : "Suspended"
  }
}
