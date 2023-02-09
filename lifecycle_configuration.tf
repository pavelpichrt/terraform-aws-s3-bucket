resource "aws_s3_bucket_lifecycle_configuration" "_" {
  count  = var.object_transitions == null || length(coalesce(var.object_transitions, [])) == 0 ? 0 : 1
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.object_transitions

    content {
      id     = "TransitionObjects-${rule.key}"
      status = "Enabled"

      dynamic "filter" {
        for_each = rule.value.prefix != null ? [true] : []

        content {
          prefix = rule.value.prefix
        }
      }

      # Transition non-current versions of objects after x days
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.non_current == null ? [] : rule.value.non_current

        content {
          noncurrent_days           = noncurrent_version_transition.value.noncurrent_days
          storage_class             = noncurrent_version_transition.value.storage_class
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
        }
      }

      # Transition current versions of objects after x days
      dynamic "transition" {
        for_each = rule.value.current == null ? [] : rule.value.current

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Delete non-current objects after X days
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days == null ? [] : [true]

        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }

      # Delete current versions of objects after x days
      dynamic "expiration" {
        for_each = rule.value.current_version_expiration_days == null ? [] : [true]

        content {
          days = rule.value.current_version_expiration_days
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
