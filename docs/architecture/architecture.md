# Zero-Trust Vendor Access Control Plane on AWS
# Architecture

## Purpose

This document defines the enterprise architecture for the Zero-Trust Vendor Access Control Plane.

The platform enables vendors, subcontractors, auditors, security teams, and internal engineers to request, approve, receive, monitor, and review time-bound access to protected resources without relying on broad standing permissions or undocumented manual processes.

The architecture is designed to support:
- least privilege
- zero-trust access patterns
- time-bound access
- approval workflows
- auditability
- evidence generation
- centralized security monitoring
- compliance-aligned control enforcement

---

## High-Level Architecture Summary

The platform has four major layers:

1. **User and Access Workflow Layer**  
   Handles requests, approvals, policy evaluation, access issuance, expiration, and evidence records.

2. **Application and Processing Layer**  
   Runs the platform services that process requests, manage workflows, generate reports, and correlate findings.

3. **Security and Monitoring Layer**  
   Collects telemetry, findings, audit records, and suspicious activity related to both the platform and granted access.

4. **Resource Access Layer**  
   Represents the protected resources that users are trying to access, such as APIs, logs, operational tools, or evidence stores.

---

## Primary Actors

### Vendors / Subcontractors
Need narrow, time-bound access to specific services or workflows.

### Internal Engineers
Need temporary privileged access to resources such as production logs, operational APIs, or controlled admin functions.

### Security Team
Needs visibility into requests, approvals, granted access, findings, and suspicious activity.

### Auditors / Compliance Reviewers
Need controlled access to evidence packages, approval history, and exception records.

### Approvers / Managers / Service Owners
Need to approve or deny requests based on risk, business purpose, and policy.

---

## Enterprise Account Model

The platform should use a multi-account design.

### 1. Security Account
Used for:
- centralized findings
- log aggregation
- evidence archive
- compliance reporting data
- investigation workflows

### 2. Application Account
Used for:
- core platform services
- request handling
- approval workflows
- access broker
- evidence service
- admin portal APIs

### 3. Shared Services Account
Used for:
- CI/CD support
- shared DNS or certificates if needed
- artifact management
- central images or supporting automation

Optional later:
- dedicated audit account
- sandbox account
- partner simulation account

---

## Core Functional Components

### Access Request API
Receives user access requests.
Captures:
- identity
- target resource
- requested duration
- justification
- environment
- ticket or business reference if required

### Policy Engine
Evaluates requests against rules such as:
- requester type
- resource sensitivity
- environment sensitivity
- max allowed duration
- approval requirements
- exception triggers

### Approval Service
Routes requests to the correct approver or approval chain.
Records:
- approval decision
- approver identity
- time of decision
- comments or denial reason

### Access Broker
Issues scoped temporary access after approval.
Responsible for:
- creating or enabling temporary access paths
- attaching session scope
- enforcing expiration
- recording issuance data

### Evidence Service
Stores and retrieves:
- request records
- approval records
- issuance records
- expiration records
- exception records
- audit exports

### Exception Service
Handles cases where a request cannot fully comply with standard policy.
Tracks:
- exception reason
- compensating controls
- approvers
- expiration date
- review status

### Findings Ingestor
Pulls or receives security findings and relevant telemetry.
Links them to:
- resources
- identities
- request windows
- sessions
- exceptions where applicable

### Reporting Worker
Builds:
- access history reports
- exception registers
- expired access reports
- evidence bundles
- compliance review outputs

### Admin Portal API
Provides controlled access to:
- request review
- approval actions
- security review
- evidence review
- reporting

---

## Protected Resource Model

The platform does not manage access abstractly. It manages access to defined resource types.

### Initial resource types
- production logs
- application admin API
- protected internal API
- evidence storage location
- EKS namespace or service environment
- specific operational workflow
- secure vendor support endpoint

Each resource type should have:
- owner
- environment classification
- sensitivity level
- allowed requester categories
- max request duration
- approval rules
- exception rules

---

## Access Flow

### Standard flow
1. User submits access request
2. Request is validated
3. Policy engine evaluates request
4. Approval service routes approval if required
5. Decision is recorded
6. Access broker grants scoped temporary access if approved
7. Evidence service records the lifecycle
8. Monitoring captures related events
9. Access expires automatically
10. Evidence is updated and retained for review

### Exception flow
1. Request fails normal policy path or requires override
2. Exception request is submitted
3. Compensating controls are defined
4. Exception approver reviews
5. Approved exception is time-bound
6. Access is issued under exception conditions
7. Evidence and reminders are tracked
8. Exception expires and must be renewed or closed

---

## Network and Access Paths

### Public path
Used for:
- admin portal
- approver portal
- evidence review interface

Public path principle:
- all public access must go through a controlled edge path
- no direct exposure of backend workloads

### Private partner path
Used for:
- vendor or subcontractor access to a narrow service
- private integration or controlled partner workflow

Private path principle:
- partners should access only the narrow service they need
- backend services should not require broad network exposure

### Internal service path
Used for:
- service-to-service communication
- workflow orchestration
- findings ingestion
- report generation

Internal path principle:
- internal services should use segmented and authenticated communication
- internal access should not rely on public exposure

---

## Data Stores

### Relational Metadata Store
Holds:
- requests
- approvals
- exceptions
- sessions
- access records
- reporting metadata

### Evidence Store
Holds:
- generated evidence bundles
- exported reports
- immutable-style audit records
- raw workflow history where appropriate

### Findings / Search Store
Holds:
- correlated findings
- searchable access history
- investigation data
- session and event relationships

---

## Security Telemetry Sources

The platform should collect or correlate:
- access requests
- approval decisions
- granted access events
- expiration and revocation events
- platform admin actions
- security findings related to accessed resources
- infrastructure and workload activity tied to granted sessions

This telemetry supports:
- accountability
- detection
- investigations
- evidence generation
- policy review

---

## Trust Boundaries

### Trust Boundary 1: External Users to Public Platform Edge
Actors:
- auditors
- managers
- internal users using the public portal

Risk:
- untrusted internet traffic
- abuse of exposed paths
- credential misuse
- enumeration and brute force attempts

Boundary rule:
- no backend workloads should be directly exposed

---

### Trust Boundary 2: Partner / Vendor Network to Private Service Path
Actors:
- vendors
- subcontractors
- partner systems

Risk:
- partner compromise
- unauthorized lateral access
- misuse of approved service path

Boundary rule:
- partner connectivity must be constrained to narrow service scope

---

### Trust Boundary 3: User Workflow Layer to Access Broker
Actors:
- internal platform services

Risk:
- unauthorized issuance of access
- policy bypass
- forged approvals
- stale request replay

Boundary rule:
- access issuance must happen only after validated policy and approval checks

---

### Trust Boundary 4: Platform Services to Protected Resources
Actors:
- access broker
- policy-driven access workflows

Risk:
- over-broad permissions
- standing access
- cross-environment leakage
- privilege escalation

Boundary rule:
- platform-issued access must be scoped, time-bound, and attributable

---

### Trust Boundary 5: Platform to Evidence and Logging Stores
Actors:
- evidence service
- reporting worker
- security reviewers
- auditors

Risk:
- evidence tampering
- unauthorized reads
- unauthorized deletion
- privacy leakage

Boundary rule:
- evidence access must be tightly controlled and logged

---

### Trust Boundary 6: Platform Administration Boundary
Actors:
- platform admins
- security admins
- automation roles

Risk:
- control plane compromise
- unauthorized policy changes
- silent workflow manipulation

Boundary rule:
- admin actions must be limited, reviewable, and attributable

---

## Asset Inventory

### Tier 1 Critical Assets
These are the most sensitive platform assets.

- policy definitions
- approval logic
- access broker logic
- issued access records
- exception records
- evidence bundles
- audit trail data
- platform administrative roles
- protected resource mappings

### Tier 2 High-Value Assets
- request history
- approval comments
- user identity metadata
- reporting outputs
- findings correlation data
- service configuration

### Tier 3 Supporting Assets
- dashboards
- non-sensitive UI assets
- operational metrics
- developer documentation
- test data

---

## Data Classification Assumptions

### Restricted
Data that could materially impact security or compliance if disclosed or altered.
Examples:
- access grants
- privileged session records
- evidence bundles
- exception details
- approval chains
- sensitive findings
- internal resource mappings

### Confidential
Operational data that is not fully public and should be limited to authorized roles.
Examples:
- request justifications
- reporting outputs
- internal metadata
- service ownership mappings
- workflow state

### Internal
General internal project, architecture, or operational information.
Examples:
- non-sensitive documentation
- generic dashboards
- non-sensitive health metrics

### Public
Information intentionally exposed externally, such as minimal product descriptions or non-sensitive portal assets.

---

## Security Design Assumptions

The architecture assumes:
- all privileged access must be attributable to an identity
- all temporary access should expire automatically
- evidence must be reviewable without broad admin access
- no user should receive more access than necessary
- partner access should be narrower than internal admin access
- policy must drive decisions before human override
- exceptions must be limited and reviewable
- the control plane itself is a high-value target and must be protected accordingly

---

## Enterprise Architecture Decisions

### Decision 1: Multi-account by default
Reason:
Limits blast radius, improves separation of duties, and supports centralized monitoring.

### Decision 2: Time-bound access over standing privilege
Reason:
Reduces stale access and improves least privilege posture.

### Decision 3: Workflow evidence is a first-class output
Reason:
Auditability and accountability are core product value, not an afterthought.

### Decision 4: Segmented paths for public, private partner, and internal service access
Reason:
Supports zero-trust principles and reduces exposure.

### Decision 5: Policy before exception
Reason:
Enforces repeatable governance and reduces informal access decisions.

---

## Architecture Exit Criteria

Stage 2 architecture work is complete when:
- the major components are defined
- the actors are defined
- the access flow is defined
- the trust boundaries are defined
- the protected resource model is defined
- the critical assets are identified
- the data classification assumptions are documented
- the system can be explained from user request to access expiration