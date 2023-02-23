locals {
  default_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:*"]
        Resource = [
          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "_" {
  bucket = aws_s3_bucket.bucket.id
  policy = var.policy == null ? local.default_policy : var.policy

  depends_on = [aws_s3_bucket_public_access_block.bucket]

  lifecycle {
    create_before_destroy = true
  }
}
