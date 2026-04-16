// DynamoDB resources placeholder
# This DynamoDB table will store the access requests from partners, including their status (pending, approved, revoked), timestamps, and any other relevant metadata. This allows us to have a durable, queryable store for all access requests, which is essential for both the functionality of the system and for audit purposes.
resource "aws_dynamodb_table" "access_requests" {
  name         = "${local.name_prefix}-access-requests"
  billing_mode = "PAY_PER_REQUEST" # the billing model, it is serverless mostly
  hash_key     = "request_id"

  attribute {
    name = "request_id" # i don't know what this is for, but it is required for the hash key, so I am including it here. It is a unique identifier for each access request, which allows us to efficiently query and manage the requests in the DynamoDB table.
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.common_tags
}