from common import (
    iso_utc,
    now_utc,
    parse_iso_utc,
    response,
    save_request,
    scan_requests,
    write_evidence,
)


def lambda_handler(event, context):
    current_time = now_utc()
    items = scan_requests()
    expired = []

    for item in items:
        if item.get("status") != "APPROVED":
            continue

        expires_at = item.get("access_expires_at")
        if not expires_at:
            continue

        if parse_iso_utc(expires_at) > current_time:
            continue

        item["status"] = "EXPIRED"
        item["revoked_at"] = iso_utc(current_time)
        item["updated_at"] = iso_utc(current_time)

        evidence_uri = write_evidence(
            item["request_id"],
            "expired",
            {
                "event_type": "expired",
                "request_id": item["request_id"],
                "expired_at": item["revoked_at"],
            },
        )

        item["latest_evidence_uri"] = evidence_uri
        save_request(item)

        expired.append(
            {
                "request_id": item["request_id"],
                "evidence_uri": evidence_uri,
            }
        )

    return response(
        200,
        {
            "message": "Expiration sweep complete.",
            "timestamp": iso_utc(current_time),
            "expired_count": len(expired),
            "expired_requests": expired,
        },
    )