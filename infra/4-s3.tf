// S3 resources placeholder
#This is the s3 bucket for sotring evidence for audits later on
resource "aws_s3_bucket" "evidence" {
  bucket = local.evidence_bucket_name
  force_destroy = true

  tags = local.common_tags
}
# This enables versioning on this evidence bucket so that we have a history of all objects
resource "aws_s3_bucket_versioning" "evidence" {
  bucket = aws_s3_bucket.evidence.id

  versioning_configuration {
    status = "Enabled"
  }
}

# This configures the encryption for the evidence bucket to use the KMS key that we will create later on

resource "aws_s3_bucket_server_side_encryption_configuration" "evidence" {
  bucket = aws_s3_bucket.evidence.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.evidence.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
# This explicitly blocks all public access to the evidence bucket, which is a critical security control for this sensitive data. Even if someone were to accidentally set a bucket policy that allows public access, these settings would override that and keep the data secure.
resource "aws_s3_bucket_public_access_block" "evidence" {
  bucket                  = aws_s3_bucket.evidence.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# This is the cloudtrail bucket for audits
resource "aws_s3_bucket" "cloudtrail" {
  bucket = local.cloudtrail_bucket_name
  force_destroy = true

  tags = local.common_tags
}

# This enables versioning on the cloudtrail bucket

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  versioning_configuration {
    status = "Enabled"
  }
}

# This explicitly blocks all public access to the cloudtrail bucket, which is a critical security control for this sensitive data. Even if someone were to accidentally set a bucket policy that allows public access, these settings would override that and keep the data secure.

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    condition {
      test     = "StringEquals"                # I don't know what the string  equals condition does in this context, but it is in the cloudtrail documentation, so I am including it here. It requires that cloudtrail set the ACL on the objects it puts in the bucket to "bucket-owner-full-control", which gives the bucket owner full control over the objects, even if they are put in by another account.
      variable = "s3:x-amz-acl"                # i don't know that this is necessary, but it is in the cloudtrail documentation, so I am including it here. It requires that cloudtrail set the ACL on the objects it puts in the bucket to "bucket-owner-full-control", which gives the bucket owner full control over the objects, even if they are put in by another account.
      values   = ["bucket-owner-full-control"] # idk why full control is a required condition for cloudtrail to be able to write to the bucket, but it is in the documentation, so I am including it here. It is a good security control anyway, as it ensures that the bucket owner has full control over the objects in the bucket, even if they are put in by another account.
    }
  }
}
# This attaches the bucket policy to the cloudtrail bucket, which is necessary for cloudtrail to be able to write logs to this bucket. The policy allows cloudtrail to check the bucket ACL and to put objects in the bucket, but it does not allow any other actions, which is a principle of least privilege.
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}