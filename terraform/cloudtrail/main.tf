data "aws_caller_identity" "me" {}

data "aws_canonical_user_id" "current" {}


resource "aws_cloudtrail" "cloudtrail" {

  name = var.name

  is_organization_trail = false

  s3_bucket_name        = aws_s3_bucket.cloudtrail.id
  is_multi_region_trail = true

  kms_key_id     = null

  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true

  tags = var.tags

  ## note: seems required to avoid racing conditions (InsufficientSnsTopicPolicyException on cloudtrail creation) /shrug
  depends_on = [
    aws_s3_bucket_policy.cloudtrail_s3
  ]
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.name}-${data.aws_caller_identity.me.account_id}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "expire in ${var.s3_bucket_expiration_days} days"
    status = "Enabled"
    expiration {
      days = var.s3_bucket_expiration_days
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

## Logging bucket configuration ###
## Ref to 3.6 Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket [CIS Amazon Web Services Foundations Benchmark] ##

resource "aws_s3_bucket" "logging" {
  bucket        = "${var.name}-${data.aws_caller_identity.me.account_id}-logs"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.cloudtrail.id

  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.logging.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# --------------------------
# iam, acl
# -------------------------

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket_policy.cloudtrail_s3] # https://github.com/hashicorp/terraform-provider-aws/issues/7628
}

resource "aws_s3_bucket_policy" "cloudtrail_s3" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}

data "aws_iam_policy_document" "cloudtrail_s3" {

  # begin. required policies as requested in aws_cloudtrail resource documentation
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:PutObject"]
    condition {
      variable = "s3:x-amz-acl"
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
    }
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"]
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = ["s3:*"]
    condition {
      variable = "aws:SecureTransport"
      test     = "Bool"
      values   = ["false"]
    }
    resources = [aws_s3_bucket.cloudtrail.arn, "${aws_s3_bucket.cloudtrail.arn}/*"]
  }

}
