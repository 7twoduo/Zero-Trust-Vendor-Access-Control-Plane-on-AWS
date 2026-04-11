10. High-level architecture
Accounts

Use at least 3 accounts:

Security account
Application account
Shared Services account

Optional later:

Audit account
Sandbox account
Core paths
Public path

For admin and approved portals:

Route 53
CloudFront
WAF
Shield Standard
ALB
EKS service
Private partner path

For partner/vendor private access:

NLB
VPC Endpoint Service
AWS PrivateLink
Internal service on EKS
Security path

For monitoring and findings:

CloudTrail
GuardDuty
Security Hub
Config
Inspector
Access Analyzer
Flow Logs
CloudWatch Logs
EventBridge
Lambda
S3
OpenSearch or similar
Data path
RDS PostgreSQL
S3
KMS
SQS
Secrets Manager