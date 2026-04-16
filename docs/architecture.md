# Architecture

## Architecture Goal

Design the smallest AWS architecture that can enforce approval-based temporary access and produce audit evidence.

## High-Level Design

The system is made of six core parts:

- API Gateway
- Lambda functions
- DynamoDB
- IAM and STS
- S3
- CloudTrail

## Logical Flow

1. A partner sends an access request to API Gateway.
2. The request is handled by the `request_access.py` Lambda.
3. The request is stored in DynamoDB with a status of `PENDING`.
4. An approver triggers the `approve_access.py` Lambda.
5. If approved, the system creates or enables a short-lived access path using scoped IAM permissions.
6. Evidence is written to S3.
7. A scheduled Lambda using `revoke_access.py` checks for expired grants and revokes them.
8. CloudTrail records AWS API activity for review.

## Core Components

### API Gateway
Receives access requests and approval actions.

### Lambda
Implements request processing, approval logic, and expiration handling.

### DynamoDB
Stores:

- request ID
- requester identity
- requested resource
- approval state
- approved duration
- expiration time
- evidence reference

### IAM and STS
Provides short-lived, least-privilege access to the protected target resource.

### S3
Stores evidence records such as:

- request details
- approval details
- expiration details
- audit-ready JSON artifacts

### CloudTrail
Provides AWS API audit visibility for actions tied to the access workflow.

### KMS
Encrypts data stored in S3 and supports secure data handling.

## Trust Boundaries

### Boundary 1: External Requester to AWS API
The requester is outside the trusted environment. All access must enter through authenticated and validated API requests.

### Boundary 2: Application Logic to Data Stores
Lambda functions interact with DynamoDB and S3. Access must be scoped tightly with least-privilege IAM.

### Boundary 3: Access Grant to Protected Resource
The granted access path must be temporary and limited only to the approved resource and duration.

## Minimal Data Flow

### Request Submission
Requester submits:

- user ID
- target resource
- requested duration
- business reason

### Approval
Approver reviews:

- requester
- resource requested
- justification
- duration

### Grant
If approved, the system writes:

- approval decision
- start time
- end time
- grant scope

### Evidence
The system writes an evidence object to S3 containing:

- request metadata
- approval metadata
- access grant details
- expiration metadata

## Protected Resource

The MVP uses one protected internal API as the target resource.

This keeps scope small while still proving:

- approval enforcement
- scoped access
- time-bound grant
- audit trail

## Security Design Principles

### Zero Trust
No user is trusted by default. Every request is validated, authorized, and logged.

### Least Privilege
Access is limited to one approved target resource for a short time.

### Short-Lived Access
No standing privileged access is used for the main workflow.

### Logging by Default
Requests, approvals, and expirations are all recorded.

### Infrastructure as Code
All AWS resources are created using Terraform.

## Future Expansion

This design can later expand to include:

- multi-account architecture
- PrivateLink
- admin UI
- WAF and CloudFront
- EKS-based services
- exception workflow
- richer evidence reporting