# Zero-Trust Vendor Access Control Plane on AWS
# Repo Foundation

## Purpose

This document defines the repository structure, service layout, engineering workflow, naming rules, and delivery model for the platform.

The goal is to ensure the project is:
- organized
- scalable
- easy to navigate
- consistent across services
- ready for local development and cloud deployment
- structured like a real enterprise platform

---

## Repo Strategy

This project will use a **single monorepo**.

### Why monorepo
A monorepo is the right choice for this platform because:
- the services are tightly related
- the infrastructure and services evolve together
- shared schemas, docs, and scripts need one source of truth
- security and architecture decisions should stay centralized
- local development is easier when services live together

---

## Top-Level Repository Structure

```text
vendor-access-control-plane/
  .github/
    workflows/
  docs/
    architecture/
    controls/
    decisions/
    diagrams/
    runbooks/
    threat-model/
  infra/
    terraform/
      envs/
        dev/
        stage/
        prod/
      modules/
        networking/
        security/
        eks/
        data/
        observability/
        edge/
        identity/
  services/
    access-request-api/
    policy-engine/
    approval-service/
    access-broker/
    evidence-service/
    exception-service/
    findings-ingestor/
    reporting-worker/
    admin-api/
  packages/
    common/
    schemas/
    clients/
  scripts/
    bootstrap/
    deploy/
    validate/
    incident/
    local/
  k8s/
    base/
    overlays/
      dev/
      stage/
      prod/
  tests/
    integration/
    e2e/
  tools/
  .editorconfig
  .gitignore
  .pre-commit-config.yaml
  Makefile
  README.md