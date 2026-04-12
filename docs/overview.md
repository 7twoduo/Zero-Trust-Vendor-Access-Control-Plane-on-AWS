# FedRAMP-Aligned Zero-Trust Partner Access MVP on AWS

## Project Summary

This project is a slimmed-down zero-trust access control platform built on AWS.

It allows a partner or external user to request temporary access to one protected AWS-backed resource. The request is reviewed by an approver. If approved, the system grants short-lived access, records the event, and stores evidence for audit purposes.

This is not a full enterprise platform. It is the smallest serious version of the idea that still demonstrates:

- zero-trust access control
- least privilege
- approval before access
- short-lived access
- logging and evidence generation
- basic FedRAMP-aligned control thinking

## Problem Statement

Organizations often need to give vendors, subcontractors, auditors, or internal operators limited access to sensitive systems.

This is commonly handled poorly through:

- broad IAM access
- long-lived credentials
- manual approvals in chat or email
- weak audit trails
- poor evidence collection

That creates risk, including:

- unauthorized access
- excess privilege
- weak accountability
- poor audit readiness
- slow incident review

## Mission Statement

Build a minimal AWS-based zero-trust access workflow that grants the right user the right access for a limited time, with approval, logging, and evidence.

## What This MVP Does

This MVP supports one narrow use case:

1. A partner requests temporary access to a protected internal API.
2. The request is stored.
3. An approver approves or denies the request.
4. If approved, the system grants short-lived access.
5. The grant expires automatically.
6. Evidence is written to S3.
7. AWS activity is visible in CloudTrail.

## Primary Users

### Partner User
Requests temporary access to a protected resource.

### Security Approver
Reviews and approves or denies the request.

### Auditor
Reviews stored evidence without needing broad infrastructure access.

## In Scope

- access request submission
- approval or denial
- temporary access grant
- automatic expiration
- evidence generation
- Terraform-managed infrastructure
- Python Lambda logic
- Bash deployment and testing scripts

## Out of Scope

The following are intentionally excluded from the first version:

- multi-account AWS architecture
- EKS
- Kubernetes hardening
- PrivateLink
- full admin portal
- WAF and CloudFront
- SIEM platform
- exception workflow
- multi-service workflow engine
- RDS
- containers
- OpenSearch

## Success Criteria

The MVP is successful if it can:

- accept an access request
- store request state
- process approval
- grant temporary access
- revoke access after expiration
- generate evidence in S3
- show AWS activity in CloudTrail

## Why This Project Matters

This project demonstrates practical cloud security engineering through a small but real workflow. It shows the ability to design access around approval, least privilege, time-bound permissions, and auditability instead of standing access.