# DevOps deployment pipeline

A small deployment-status web application used to demonstrate a CI/CD pipeline,
Infrastructure as Code, configuration management, and deployment to AWS.

## Current checkpoint

The application and first shift-left CI gates are implemented. Terraform, Ansible,
deployment approval, and AWS smoke testing will be added in separate verified
checkpoints.

## Run locally

```powershell
cd app
npm ci
npm run check
npm start
```

Open `http://localhost:3000`.

The application exposes:

- `GET /health` for service health.
- `GET /version` for the deployed version, commit, and timestamp.
- Structured JSON request logs for operational evidence.

## Documentation

- [Target architecture](docs/architecture.md)
- [Threat model](docs/threat-model.md)
- [Design decisions](docs/design-decisions.md)
- [Assessment evidence plan](docs/assessment-evidence.md)

## Planned structure

```text
app/          Node.js application and tests
terraform/    AWS infrastructure
ansible/      EC2 configuration and deployment
.github/      CI, security, and later deployment workflows
docs/         Architecture, threat model, and assessment evidence
```
