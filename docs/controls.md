# Control Objectives

## Purpose

This document defines the core security and compliance objectives for the MVP.

The project is not a full FedRAMP implementation. It is a FedRAMP-aligned design exercise focused on core access control and audit principles.

## Core Objectives

### 1. Enforce Approval Before Access
No access is granted until a request is reviewed and approved.

### 2. Enforce Least Privilege
Granted access is limited to a single approved resource and action scope.

### 3. Enforce Time-Bound Access
Every approved access grant must expire automatically.

### 4. Record Audit Evidence
Each request, decision, grant, and expiration event must be recorded.

### 5. Protect Stored Records
Evidence and request metadata must be protected from unauthorized modification.

### 6. Manage Infrastructure Consistently
Infrastructure must be declared and deployed through Terraform.

## Control Family Alignment

## AC — Access Control

### Objective
Limit access to approved users, approved resources, and approved durations.

### MVP Implementation
- explicit access request
- approval step before grant
- scoped IAM permissions
- automatic expiration

## AU — Audit and Accountability

### Objective
Ensure access events can be reconstructed and reviewed.

### MVP Implementation
- request records in DynamoDB
- evidence artifacts in S3
- AWS API activity in CloudTrail

## IA — Identification and Authentication

### Objective
Ensure request and approval actions are tied to known identities.

### MVP Implementation
- authenticated API access model
- identity recorded with each request and approval

## SC — System and Communications Protection

### Objective
Protect system data and access paths.

### MVP Implementation
- KMS-backed encryption
- controlled API entry point
- scoped Lambda IAM permissions

## CM — Configuration Management

### Objective
Control infrastructure changes consistently.

### MVP Implementation
- Terraform-managed AWS resources
- predictable infrastructure definitions

## SI — System and Information Integrity

### Objective
Maintain reliable workflow behavior and support detection of unexpected access patterns.

### MVP Implementation
- expiration checks
- consistent request state transitions
- CloudTrail review support

## Minimal Policy Rules

The MVP enforces these simple policy rules:

- only approved requests can receive access
- access duration must be limited
- access must target only one predefined resource
- every request must include a reason
- every approval decision must be recorded
- every grant must have an expiration time

## Evidence Requirements

Each request should produce an evidence record containing:

- request ID
- requester identity
- requested resource
- business justification
- approval decision
- approver identity
- grant start time
- grant end time
- revocation status
- evidence creation timestamp

## Residual Risk

The MVP intentionally accepts the following limitations:

- no multi-account isolation
- no advanced policy engine
- no partner private network path
- no dedicated exception workflow
- no threat detection correlation layer

These are known gaps and are acceptable for the first version because the goal is to prove the core access control workflow first.

## Exit Criteria

The control model is complete when:

- all access is approval-based
- access is temporary
- evidence is stored
- AWS activity is auditable
- infrastructure is reproducible