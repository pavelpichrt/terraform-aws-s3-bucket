resource "aws_s3_bucket_server_side_encryption_configuration" "_" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_master_key_id : null
      sse_algorithm     = var.sse_algorithm
    }
  }
}
