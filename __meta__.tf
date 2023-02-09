variable "name" {}

variable "sse_algorithm" {
  default = "AES256"
}

variable "kms_master_key_id" {
  default     = "aws/s3"
  description = "This is actually ARN of the key, but keeping the name for consistency."
}

variable "is_private" {
  type    = bool
  default = true
}

variable "is_versioned" {
  default = true
  type    = bool
}

variable "force_destroy" {
  default = "false"
  type    = bool
}

variable "policy" {
  default = null
}

variable "object_transitions" {
  type = list(
    object({
      prefix                             = string
      current_version_expiration_days    = number
      noncurrent_version_expiration_days = number

      current = list(object({
        storage_class = string
        days          = number
      }))

      non_current = list(object({
        storage_class             = string
        noncurrent_days           = number
        newer_noncurrent_versions = number
      }))
    })
  )

  default     = null
  description = "Transition current objects into a different storage tier class. Note that AWS imposes limitations on how long an object must stay in particular class (e.g.: 30 days for STANDARD_IA, 90 for GLACIER) or minimum sizes. Currently available classes: STANDARD_IA, INTELLIGENT_TIERING, ONEZONE_IA, GLACIER, DEEP_ARCHIVE. More info: https://aws.amazon.com/s3/storage-classes/"
}

# ============================================

output "_" {
  value = aws_s3_bucket.bucket
}

output "public_access_block" {
  value = aws_s3_bucket_public_access_block.bucket
}
