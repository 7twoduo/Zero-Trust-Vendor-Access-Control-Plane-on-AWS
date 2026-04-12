from datetime import timedelta

from common import (
    DEFAULT_DURATION_MINUTES,
    clamp_duration_minutes,
    get_request,
    iso_utc,
    new_request_id,
    now_utc,
    parse_body,
    response,
    save_request,
    write_evidence,
    epoch_utc,
)


ALLOWED_RESOURCE = "partner/resource"


def _handle_protected_resource(event: dict):
    iam_ctx = (
        event.get("requestContext", {})
        .get("authorizer", {})
        .get("iam", {})
    )

    return response(
        200,
        {
            "message": "Protected partner resource reached.",
            "timestamp": iso_utc(now_utc()),
            "caller": {
                "userArn": iam_ctx.get("userArn"),
                "accountId": iam_ctx.get("accountId"),
                "accessKey": iam_ctx.get("accessKey"),
                "callerId": iam_ctx.get("callerId"),
            },
        },
    )


def lambda_handler(event, context):
    route_key = event.get("routeKey", "")

    if route_key == "GET /partner/resource":
        return _handle_protected_resource(event)

    body = parse_body(event)

    user_id = str(body.get("user_id", "")).strip()
    resource = str(body.get("resource", "")).strip()
    reason = str(body.get("reason", "")).strip()

    try:
        requested_duration = int(body.get("duration_minutes", DEFAULT_DURATION_MINUTES))
    except (TypeError, ValueError):
        return response(
            400,
            {
                "message": "duration_minutes must be a number.",
            },
        )

    if not user_id:
        return response(400, {"message": "user_id is required."})

    if resource != ALLOWED_RESOURCE:
        return response(
            400,
            {
                "message": f"resource must be '{ALLOWED_RESOURCE}'.",
            },
        )

    if not reason:
        return response(400, {"message": "reason is required."})

    duration_minutes = clamp_duration_minutes(requested_duration)
    created_at = now_utc()
    request_id = new_request_id()

    item = {
        "request_id": request_id,
        "user_id": user_id,
        "resource": resource,
        "reason": reason,
        "requested_duration_minutes": duration_minutes,
        "status": "PENDING",
        "created_at": iso_utc(created_at),
        "updated_at": iso_utc(created_at),
        "ttl": epoch_utc(created_at + timedelta(days=30)),
    }

    save_request(item)

    evidence_uri = write_evidence(
        request_id,
        "requested",
        {
            "event_type": "requested",
            "request": item,
        },
    )

    item["latest_evidence_uri"] = evidence_uri
    save_request(item)

    return response(
        201,
        {
            "message": "Access request created.",
            "request_id": request_id,
            "status": item["status"],
            "resource": resource,
            "requested_duration_minutes": duration_minutes,
            "evidence_uri": evidence_uri,
        },
    )