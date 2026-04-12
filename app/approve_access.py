from datetime import timedelta

from common import (
    PARTNER_ROLE_ARN,
    assume_partner_role,
    clamp_duration_minutes,
    get_request,
    iso_utc,
    now_utc,
    parse_body,
    response,
    save_request,
    write_evidence,
    epoch_utc,
)


def _to_bool(value):
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        return value.strip().lower() in {"true", "1", "yes", "y"}
    return bool(value)


def lambda_handler(event, context):
    body = parse_body(event)

    request_id = str(body.get("request_id", "")).strip()
    approver = str(body.get("approver", "")).strip() or "security-admin"
    approved = _to_bool(body.get("approved", False))

    if not request_id:
        return response(400, {"message": "request_id is required."})

    item = get_request(request_id)
    if not item:
        return response(404, {"message": "Request not found."})

    if item.get("status") != "PENDING":
        return response(
            409,
            {
                "message": "Request is not in PENDING state.",
                "current_status": item.get("status"),
            },
        )

    decision_time = now_utc()

    if not approved:
        item["status"] = "DENIED"
        item["approved_by"] = approver
        item["approved_at"] = iso_utc(decision_time)
        item["updated_at"] = iso_utc(decision_time)

        evidence_uri = write_evidence(
            request_id,
            "denied",
            {
                "event_type": "denied",
                "request_id": request_id,
                "approved_by": approver,
                "approved": False,
                "decision_time": iso_utc(decision_time),
            },
        )

        item["latest_evidence_uri"] = evidence_uri
        save_request(item)

        return response(
            200,
            {
                "message": "Access request denied.",
                "request_id": request_id,
                "status": item["status"],
                "evidence_uri": evidence_uri,
            },
        )

    duration_minutes = clamp_duration_minutes(
        int(item.get("requested_duration_minutes", 60))
    )

    credentials = assume_partner_role(request_id, duration_minutes)
    expires_at = credentials["Expiration"]

    item["status"] = "APPROVED"
    item["approved_by"] = approver
    item["approved_at"] = iso_utc(decision_time)
    item["updated_at"] = iso_utc(decision_time)
    item["access_expires_at"] = iso_utc(expires_at)
    item["ttl"] = epoch_utc(expires_at + timedelta(days=30))

    evidence_uri = write_evidence(
        request_id,
        "approved",
        {
            "event_type": "approved",
            "request_id": request_id,
            "approved_by": approver,
            "approved": True,
            "decision_time": iso_utc(decision_time),
            "access_expires_at": iso_utc(expires_at),
            "role_arn": PARTNER_ROLE_ARN,
        },
    )

    item["latest_evidence_uri"] = evidence_uri
    save_request(item)

    return response(
        200,
        {
            "message": "Access request approved.",
            "request_id": request_id,
            "status": item["status"],
            "approved_by": approver,
            "role_arn": PARTNER_ROLE_ARN,
            "access_expires_at": iso_utc(expires_at),
            "evidence_uri": evidence_uri,
            "credentials": {
                "AccessKeyId": credentials["AccessKeyId"],
                "SecretAccessKey": credentials["SecretAccessKey"],
                "SessionToken": credentials["SessionToken"],
                "Expiration": iso_utc(expires_at),
            },
        },
    )