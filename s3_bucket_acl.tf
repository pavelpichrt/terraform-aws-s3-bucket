resource "aws_s3_bucket_acl" "_" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}
