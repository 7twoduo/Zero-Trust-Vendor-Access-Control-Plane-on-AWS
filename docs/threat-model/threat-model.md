# Zero-Trust Vendor Access Control Plane on AWS
# Threat Model

## Purpose

This document identifies major threats, misuse cases, and abuse paths for the Zero-Trust Vendor Access Control Plane.

The goal is to understand what can go wrong, what the likely attack paths are, which assets are at risk, and which controls must exist to reduce risk.

This is a practical threat model focused on:
- access abuse
- policy bypass
- privilege escalation
- audit failure
- evidence tampering
- third-party misuse
- platform compromise

---

## Threat Modeling Scope

This threat model covers:
- access request lifecycle
- policy evaluation
- approval workflow
- temporary access issuance
- access expiration and revocation
- evidence generation and storage
- exception handling
- security findings correlation
- admin functions
- partner and auditor access paths

Out of scope for this version:
- corporate identity provider internals
- endpoint security on partner-owned devices
- every possible privileged access scenario across the entire company
- third-party ticketing systems outside integration boundaries

---

## Security Objectives

The platform must protect:
- access governance integrity
- approval integrity
- temporary access boundaries
- audit trail completeness
- evidence integrity
- platform administrative control
- policy consistency
- resource segmentation
- accountability of every access decision and action

---

## Crown Jewels

The most sensitive assets are:

1. **Access broker capability**  
   If compromised, an attacker may grant themselves or others privileged access.

2. **Policy definitions and enforcement logic**  
   If weakened or bypassed, the platform may approve unauthorized access.

3. **Approval records and workflow state**  
   If forged or altered, attackers may create fake legitimacy for privileged access.

4. **Evidence and audit data**  
   If deleted or tampered with, the organization may lose accountability and compliance proof.

5. **Exception records**  
   If abused, exceptions can become a hidden path to persistent privilege.

6. **Administrative roles for the control plane**  
   If compromised, attackers may change policy, alter records, or disable controls.

---

## Threat Actors

### External attacker
May attempt to abuse the public portal, steal credentials, or exploit exposed paths.

### Malicious vendor or subcontractor
May attempt to expand access beyond approved scope or retain access beyond approval windows.

### Compromised internal user
May misuse legitimate access or request excessive access for unauthorized reasons.

### Careless approver
May approve requests without proper review or approve overly broad access.

### Rogue admin
May alter policy, records, or controls to hide abuse or grant unauthorized access.

### Compromised workload or automation role
May issue unauthorized access or tamper with evidence.

---

## Major Threat Categories

### 1. Unauthorized Access Grant
An attacker or insider gets access without valid policy or approval.

Examples:
- forged approval
- policy bypass
- direct invocation of access broker
- replay of an old approved request

Impact:
- unauthorized access to sensitive resources
- privilege escalation
- loss of trust in the platform

---

### 2. Over-Broad Access
A request is approved, but the granted access is wider than necessary.

Examples:
- access includes unrelated environments
- read access becomes admin access
- duration exceeds what was requested
- partner gets broad internal visibility

Impact:
- excessive blast radius
- policy failure
- compliance violation

---

### 3. Stale or Persistent Access
Temporary access fails to expire or is not fully revoked.

Examples:
- automation fails silently
- session remains active after expiration
- exception is never closed
- revocation record is missing

Impact:
- standing privilege
- hidden risk accumulation
- failed access governance

---

### 4. Evidence Tampering
A privileged attacker alters or deletes access records, approvals, or reports.

Examples:
- delete evidence bundle
- alter approval history
- modify request timestamps
- suppress denied request records

Impact:
- failed audit
- broken accountability
- hidden abuse

---

### 5. Approval Process Abuse
The approval workflow is manipulated to approve inappropriate access.

Examples:
- social engineering an approver
- self-approval path
- approval routing bug
- use of an unauthorized delegate

Impact:
- unauthorized access appears legitimate
- weak separation of duties

---

### 6. Policy Manipulation
Policy logic is changed or weakened.

Examples:
- max duration increased silently
- production approval requirement removed
- vendor role expanded
- exception rules made permanent

Impact:
- systematic control breakdown
- hidden privilege inflation

---

### 7. Private Partner Path Abuse
A vendor or attacker uses the private access path outside intended scope.

Examples:
- access to unapproved backend service
- probing internal services through a narrow endpoint
- data extraction beyond authorized workflow

Impact:
- partner-originated breach path
- lateral movement risk
- exposure of internal systems

---

### 8. Audit Data Overexposure
Auditors or reviewers receive more information than needed.

Examples:
- evidence package contains unrelated sensitive data
- reviewer can browse all requests
- internal resource mappings are leaked

Impact:
- privacy issue
- unnecessary exposure
- reduced segregation of duties

---

### 9. Logging and Monitoring Failure
Important events are not captured or cannot be correlated.

Examples:
- issuance event logged but usage not logged
- approval recorded but expiration missing
- findings cannot be linked to access windows
- alerting is disabled or incomplete

Impact:
- delayed investigations
- weak detection capability
- incomplete audit evidence

---

### 10. Control Plane Compromise
The platform itself becomes the attack path.

Examples:
- admin API compromise
- compromised service account
- container breakout
- poisoned automation workflow

Impact:
- mass unauthorized access
- evidence destruction
- control loss across the platform

---

## Misuse Cases

### Misuse Case 1: Vendor Requests Narrow Access but Uses It to Enumerate More Systems
A vendor is approved for a limited service but attempts to discover adjacent services or endpoints.

What this threatens:
- segmentation
- least privilege
- private partner boundary

Expected controls:
- narrow service exposure
- scoped authorization
- network segmentation
- logging and anomaly review

---

### Misuse Case 2: Engineer Requests Temporary Log Access but Retains It Beyond Incident Window
An internal engineer continues using sensitive access after the original need ends.

What this threatens:
- stale access control
- accountability
- privileged misuse

Expected controls:
- automatic expiration
- session revocation
- expiration audit trail
- stale access detection

---

### Misuse Case 3: Approver Clicks Approve Without Reviewing Context
An approver rubber-stamps requests without validating scope or need.

What this threatens:
- governance integrity
- separation of duties
- quality of approvals

Expected controls:
- rich approval context
- required approval reason
- policy flags
- review reporting on approvals

---

### Misuse Case 4: Malicious Admin Alters Policy to Allow Longer Vendor Access
A privileged admin weakens policy quietly.

What this threatens:
- integrity of the control model
- long-term access governance
- system trust

Expected controls:
- change logging
- reviewable policy updates
- approval for policy changes
- diff-based control review

---

### Misuse Case 5: Request Is Denied but Access Is Still Issued Through an Automation Bug
The workflow state and access issuance become inconsistent.

What this threatens:
- workflow integrity
- platform correctness
- control reliability

Expected controls:
- broker checks final decision state
- idempotent workflow enforcement
- denial and issuance reconciliation checks

---

### Misuse Case 6: Auditor Uses Evidence View to See Operational Details Beyond Scope
A reviewer accesses unrelated engineering or security data.

What this threatens:
- segregation of duties
- privacy
- information minimization

Expected controls:
- scoped evidence access
- role-based output filtering
- export boundary control

---

### Misuse Case 7: Exception Is Approved but Never Expires
A temporary exception becomes permanent through neglect.

What this threatens:
- risk governance
- control drift
- standing privilege through exception path

Expected controls:
- mandatory exception expiration
- reminder workflow
- expired exception alerts
- compliance review visibility

---

### Misuse Case 8: Attacker Replays a Previously Approved Request
A valid prior request is reused to gain unauthorized access later.

What this threatens:
- issuance integrity
- request authenticity
- session control

Expected controls:
- request state validation
- one-time issuance semantics
- signed workflow transitions
- replay detection

---

## Threat Scenarios by Component

### Access Request API
Threats:
- forged requests
- injection of malformed request data
- impersonation
- spam or abuse

Needed protections:
- authenticated requests
- input validation
- rate limiting
- structured request format

---

### Policy Engine
Threats:
- logic bypass
- misconfiguration
- rule tampering
- inconsistent evaluation

Needed protections:
- versioned policy
- deterministic evaluation
- decision logging
- change review

---

### Approval Service
Threats:
- unauthorized approval
- delegated abuse
- skipped approver
- fabricated approval result

Needed protections:
- identity verification
- approval chain rules
- audit logging
- state validation

---

### Access Broker
Threats:
- direct misuse
- over-issuance
- issuance after denial
- access not revoking

Needed protections:
- final-state checks
- scope enforcement
- expiration enforcement
- issuance logging

---

### Evidence Service
Threats:
- tampering
- deletion
- overexposure
- silent record corruption

Needed protections:
- write controls
- read segmentation
- integrity-oriented storage controls
- evidence access logging

---

### Exception Service
Threats:
- exception abuse
- permanent override path
- undocumented compensating controls
- hidden approval

Needed protections:
- required fields
- expiry enforcement
- review reporting
- visibility of open exceptions

---

### Admin Portal
Threats:
- credential theft
- privilege escalation
- admin abuse
- exposed management paths

Needed protections:
- strong authentication
- narrow admin roles
- admin action logging
- segmented management interfaces

---

## Assumed Control Responses

The platform design should respond to these threats with:

- formal request lifecycle
- policy-based decision making
- approval chain enforcement
- narrow and time-bound access issuance
- automatic expiration and revocation
- immutable-style or strongly protected evidence handling
- segmentation between public, private partner, and internal paths
- centralized logging and findings correlation
- reviewable policy and admin changes
- exception expiration and visibility
- attributable identities for all privileged actions

---

## Residual Risk Areas

Even with strong controls, these risks remain and should be documented:

- approved users can still misuse legitimately granted access
- social engineering of approvers is still possible
- partner-owned endpoints may be compromised
- the control plane itself remains a high-value target
- incomplete logging integrations may reduce investigation quality
- emergency access workflows may create temporary governance gaps

These residual risks should be acknowledged in later governance and compliance documents.

---

## Threat Model Exit Criteria

Stage 2 threat modeling is complete when:
- crown jewels are identified
- major threat actors are identified
- key threat categories are documented
- misuse cases are defined
- component-specific threats are described
- expected control responses are identified
- residual risk areas are acknowledged
- the team can explain what the platform is protecting, from whom, and how