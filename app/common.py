import json
import os
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import boto3


ddb = boto3.resource("dynamodb")
sts = boto3.client("sts")
s3 = boto3.client("s3")

TABLE_NAME = os.getenv("TABLE_NAME", "")
EVIDENCE_BUCKET = os.getenv("EVIDENCE_BUCKET", "")
EVIDENCE_KMS_KEY_ARN = os.getenv("EVIDENCE_KMS_KEY_ARN", "")
DEFAULT_DURATION_MINUTES = int(os.getenv("DEFAULT_DURATION_MINUTES", "60"))
PARTNER_ROLE_ARN = os.getenv("PROTECTED_ASSUME_ROLE_ARN", "")
ENVIRONMENT = os.getenv("ENVIRONMENT", "dev")

table = ddb.Table(TABLE_NAME)


def _json_default(value):
    if isinstance(value, datetime):
        return iso_utc(value)
    if isinstance(value, Decimal):
        if value % 1 == 0:
            return int(value)
        return float(value)
    raise TypeError(f"Type not serializable: {type(value)}")


def response(status_code: int, body: dict):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body, default=_json_default),
    }


def parse_body(event: dict) -> dict:
    body = event.get("body")
    if not body:
        return {}

    if isinstance(body, dict):
        return body

    try:
        return json.loads(body)
    except json.JSONDecodeError:
        return {}


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def iso_utc(dt: datetime) -> str:
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc).isoformat()


def parse_iso_utc(value: str) -> datetime:
    return datetime.fromisoformat(value.replace("Z", "+00:00")).astimezone(timezone.utc)


def epoch_utc(dt: datetime) -> int:
    return int(dt.timestamp())


def new_request_id() -> str:
    return str(uuid.uuid4())


def clamp_duration_minutes(requested_minutes: int) -> int:
    minimum = 15
    maximum = DEFAULT_DURATION_MINUTES
    return max(minimum, min(requested_minutes, maximum))


def get_request(request_id: str):
    result = table.get_item(Key={"request_id": request_id})
    return result.get("Item")


def save_request(item: dict):
    table.put_item(Item=item)


def scan_requests():
    items = []
    response_page = table.scan()
    items.extend(response_page.get("Items", []))

    while "LastEvaluatedKey" in response_page:
        response_page = table.scan(ExclusiveStartKey=response_page["LastEvaluatedKey"])
        items.extend(response_page.get("Items", []))

    return items


def write_evidence(request_id: str, event_type: str, payload: dict) -> str:
    timestamp = now_utc().strftime("%Y%m%dT%H%M%SZ")
    key = f"requests/{request_id}/{event_type}-{timestamp}.json"

    kwargs = {
        "Bucket": EVIDENCE_BUCKET,
        "Key": key,
        "Body": json.dumps(payload, default=_json_default).encode("utf-8"),
        "ContentType": "application/json",
    }

    if EVIDENCE_KMS_KEY_ARN:
        kwargs["ServerSideEncryption"] = "aws:kms"
        kwargs["SSEKMSKeyId"] = EVIDENCE_KMS_KEY_ARN

    s3.put_object(**kwargs)
    return f"s3://{EVIDENCE_BUCKET}/{key}"


def assume_partner_role(request_id: str, duration_minutes: int) -> dict:
    duration_seconds = duration_minutes * 60
    session_name = f"req-{request_id.replace('-', '')[:24]}"

    response_data = sts.assume_role(
        RoleArn=PARTNER_ROLE_ARN,
        RoleSessionName=session_name,
        DurationSeconds=duration_seconds,
    )
    return response_data["Credentials"]