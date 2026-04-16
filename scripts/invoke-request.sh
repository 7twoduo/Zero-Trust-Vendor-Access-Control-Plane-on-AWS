#!/usr/bin/env bash
echo "Invoke request placeholder"
BASE_URL="https://4epsuu8t51.execute-api.us-east-1.amazonaws.com"

curl -s -X POST "$BASE_URL/request" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"partner-1","resource":"partner/resource","reason":"Troubleshooting incident INC-1003","duration_minutes":15}' > request.json

export REQUEST_ID="$(jq -r '.request_id' request.json)"

curl -s -X POST "$BASE_URL/approve" \
  -H "Content-Type: application/json" \
  -d "{\"request_id\":\"$REQUEST_ID\",\"approved\":true,\"approver\":\"security-admin\"}" > approve.json

export AWS_ACCESS_KEY_ID="$(jq -r '.credentials.AccessKeyId' approve.json)"
export AWS_SECRET_ACCESS_KEY="$(jq -r '.credentials.SecretAccessKey' approve.json)"
export AWS_SESSION_TOKEN="$(jq -r '.credentials.SessionToken' approve.json)"

curl --aws-sigv4 "aws:amz:us-east-1:execute-api" \
  --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
  -H "x-amz-security-token: $AWS_SESSION_TOKEN" \
  "$BASE_URL/partner/resource"