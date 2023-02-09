# S3 Bucket Base

Provides an S3 bucket resource with common configuration options.

## Usage

### Basic

### All options

```terraform
data "aws_iam_policy_document" "deny_put" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]

    resources = [
      module.s3_bucket_content._.arn,
      "${module.s3_bucket_content._.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

module "s3_bucket_content" {
  source = "pavelpichrt/s3-bucket-base/aws"

  name = "my-bucket"
  has_custom_policy = true
  force_destroy     = true # Will prevent errors when deleting a buckket that is not empty
  is_versioned      = true
  sse_algorithm     = "AES256"
  kms_master_key_id = "aws/s3"
  policy            = data.aws_iam_policy_document.deny_put.json

  # Note that all of object_transitions args are required, but nullable
  object_transitions = [{
    # set to null to apply rule to all objects in the bucket
    prefix                             = "/my-path"
    # Delete non-current objects after this many days
    noncurrent_version_expiration_days = 210

    current = [
      {
        storage_class = "INTELLIGENT_TIERING"
        days          = 30
      },
      {
        storage_class = "GLACIER"
        days          = 60
      }
    ]

    non_current = [
      {
        storage_class             = "ONEZONE_IA"
        noncurrent_days           = 30
        newer_noncurrent_versions = null
      },
      {
        storage_class             = "DEEP_ARCHIVE"
        noncurrent_days           = 60
        newer_noncurrent_versions = 3
      }
    ]
  }]
}
```

## Limitations on object transition

Note that AWS imposes limitations on available options.

### Available tiers and mobing objects between them

The tiers are ordered and it is currently not possible to transition into a higher tier (e.g.: GLACIER -> STANDARD_IA) in this rule.

1. Standard IA - STANDARD_IA
2. Intelligent tiering - INTELLIGENT_TIERING
3. One Zone IA - ONEZONE_IA
4. Glacier instant retrieval - GLACIER_IR
5. Glacier flexible retrieval - GLACIER
6. Glacier deep archive - DEEP_ARCHIVE

### Minumum number of days in a tier

AWS enforces a minimum number of days in most tiers, e.g.:

- Intelligent tiering: 30 days
- Glacier flexible retrieval: 90 days

### noncurrent_version_expiration_days param

This parameter specifies after how many days a non-current object should be deleted from the bucket. This needs to be at least one day after the final transition plus a minimum number of days in the final tier.

#### Example

If the last transition occurs on day 60 into Glacier tier (which stores objects for a minimum of 90 days), the param must be at least:

> noncurrent_version_expiration_days = 60 + 90 + 1 = 151
