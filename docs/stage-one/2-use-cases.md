# Use Cases
# Zero-Trust Vendor Access Control Plane on AWS

## Overview

This document defines the primary user-facing use cases for the platform.

The use cases focus on real enterprise problems around temporary access, third-party access, evidence generation, and policy exceptions.

---

## Use Case 1: Vendor Requests Temporary Access to a Restricted Service

### Actor
Vendor or subcontractor

### Goal
Obtain time-limited access to a specific service needed for support or delivery work.

### Scenario
A vendor needs access to a troubleshooting API for a production integration issue. They should not receive broad network access or standing credentials.

### Desired Outcome
The vendor submits an access request with business justification and requested duration. The request is evaluated against policy, approved by the proper owner, granted with narrow scope, fully logged, and automatically revoked at expiration.

### Success Conditions
- the vendor can access only the approved service
- the access has a fixed expiration time
- the request, approval, grant, usage, and expiration are recorded
- the access does not expose unrelated systems

---

## Use Case 2: Internal Engineer Requests Just-in-Time Access to Production Logs

### Actor
Internal engineer

### Goal
Get temporary access to sensitive production logs for incident response or troubleshooting.

### Scenario
An engineer needs access to production logs for one hour during an incident. The organization does not want engineers to have standing broad access to log systems.

### Desired Outcome
The engineer requests temporary access. The system checks the environment, risk level, and role. Approval is routed if needed. The engineer gets time-limited access and all actions are recorded.

### Success Conditions
- access is limited to the correct log source
- duration is limited
- approvals are enforced where required
- access is automatically revoked
- evidence is available for later review

---

## Use Case 3: Auditor Retrieves Evidence Without Broad Infrastructure Access

### Actor
Auditor or compliance reviewer

### Goal
Review evidence related to access requests, approvals, exceptions, and system activity without receiving engineering or admin access to live systems.

### Scenario
An auditor needs proof that privileged access is time-bound, approved, logged, and reviewed.

### Desired Outcome
The auditor uses the platform to retrieve evidence bundles, approval history, exception records, and access summaries without interacting directly with operational cloud resources.

### Success Conditions
- the auditor can view only approved evidence
- evidence is complete and tamper-resistant
- the auditor does not need cloud admin access
- the evidence is exportable for review

---

## Use Case 4: Security Team Investigates Suspicious Activity After Access Grant

### Actor
Security analyst

### Goal
Determine whether suspicious activity is related to a legitimate access grant or indicates misuse.

### Scenario
A finding appears after a vendor or engineer was granted temporary access. The security team needs to know whether the activity matches the approved request.

### Desired Outcome
The analyst can correlate the granted access, request details, approval chain, timeframe, and logged activity to determine whether the behavior was expected or suspicious.

### Success Conditions
- the analyst can tie findings back to granted sessions
- the analyst can see who approved the access
- the analyst can see when the access started and ended
- the investigation record can be preserved

---

## Use Case 5: Policy Exception Is Requested for a Restricted Access Scenario

### Actor
Engineer, vendor sponsor, or security approver

### Goal
Request temporary exception handling when normal access policy cannot be followed fully.

### Scenario
A team needs an urgent access path that does not fit the default policy, but the risk must be documented and managed.

### Desired Outcome
The exception is requested with justification, compensating controls, approver review, expiration date, and full evidence tracking.

### Success Conditions
- exceptions cannot exist without business justification
- compensating controls are documented
- expiration is mandatory
- reminders and review points are triggered
- expired exceptions are visible and actionable

---

## Use Case 6: Manager Reviews and Approves an Access Request

### Actor
Engineering manager, service owner, or delegated approver

### Goal
Approve or deny access requests based on policy, risk, and business need.

### Scenario
A request is submitted for access to a production resource. The manager must determine whether the access is justified and whether the duration and scope are appropriate.

### Desired Outcome
The approver receives clear request context and can approve, deny, or escalate the request with reasoning.

### Success Conditions
- the approver sees who requested access
- the approver sees the requested resource and duration
- the approver sees policy flags or risk indicators
- the approval decision is recorded

---

## Use Case 7: Access Expires Automatically Without Manual Cleanup

### Actor
Platform system

### Goal
Revoke temporary access automatically when the approved window ends.

### Scenario
An engineer or vendor no longer needs access after the approved time expires.

### Desired Outcome
The platform revokes the access automatically and updates the evidence record.

### Success Conditions
- expired access is removed without manual action
- the expiration is logged
- stale access is detectable
- compliance reviewers can see proof of revocation

---

## Use Case 8: Compliance Team Reviews the Exception Register

### Actor
Compliance reviewer or security governance lead

### Goal
Review open and expired exceptions, compensating controls, and approval history.

### Scenario
Before an audit or internal review, the compliance team needs to assess whether risk exceptions are tracked and controlled.

### Desired Outcome
The team can export an exception register and see status, owner, control gaps, expiration date, and review history.

### Success Conditions
- open exceptions are visible
- expired exceptions are flagged
- exception ownership is clear
- evidence is exportable

---

## Top Priority Use Cases for Initial Release

The first version of the platform should prioritize these five:

1. Vendor requests temporary access to a restricted service  
2. Internal engineer requests just-in-time access to production logs  
3. Manager reviews and approves an access request  
4. Access expires automatically without manual cleanup  
5. Auditor retrieves evidence without broad infrastructure access

These five establish the core business value of the platform.