// KMS resources placeholder
# This creates a KMS key that we will use to encrypt the evidence in the evidence bucket. Using KMS for encryption is a best practice for sensitive data, as it provides strong encryption and allows for fine-grained access control. The key rotation is enabled to enhance security by regularly changing the encryption keys, which helps to protect against potential key compromise.
resource "aws_kms_key" "evidence" {
  description             = "KMS key for evidence bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.common_tags
}
# This creates an alias for the KMS key, which makes it easier to reference in other resources, such as the S3 bucket encryption configuration. Using an alias also allows us to change the underlying key without having to update all references to it, which is a good practice for maintainability.
resource "aws_kms_alias" "evidence" {
  name          = "alias/${local.name_prefix}-evidence"
  target_key_id = aws_kms_key.evidence.key_id
}