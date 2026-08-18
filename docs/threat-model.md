# Lightweight threat model

## Scope and trust boundaries

The protected assets are the source repository, GitHub Actions credentials, AWS
Learner Lab resources, Terraform state, SSH key, deployment artifact, and the
availability and integrity of the running application.

Trust boundaries exist between the developer workstation and GitHub, GitHub-hosted
runners and AWS, the public internet and Nginx, and Nginx and the local Node.js
service.

## Principal risks and controls

| Risk | Potential effect | Control and evidence |
|---|---|---|
| AWS or SSH credential committed to Git | Account or host compromise | `.gitignore`, GitHub encrypted secrets, Gitleaks, and temporary Learner Lab credentials |
| Vulnerable dependency | Compromised application or build | Lockfile, `npm audit`, Dependabot, and scheduled security checks |
| Unsafe application input or browser content | Injection or cross-site scripting | No database or user-generated HTML; DOM updates use `textContent`; Helmet supplies a restrictive Content Security Policy |
| Untrusted change deploys from a pull request | Production compromise | PRs run checks only; deployment will run from protected `main` after environment approval |
| Overly broad workflow permissions | Repository or supply-chain compromise | Workflow-level `contents: read`; write permission is isolated to the CodeQL workflow |
| Public SSH access from every address | EC2 compromise | Terraform will restrict port 22 to the current GitHub runner `/32`; port 3000 remains private |
| Insecure infrastructure definition | Exposed or non-compliant AWS resources | Terraform formatting, validation, plan review, and Checkov gate before apply |
| Configuration drift or insecure package setup | Unrepeatable or vulnerable server | Idempotent Ansible playbook, pinned intent, ansible-lint, and service verification |
| Lost or inconsistent Terraform state | Duplicate resources or failed recovery | Encrypted, versioned S3 remote state where Learner Lab permissions permit |
| Failed deployment remains undetected | Availability or integrity failure | systemd restart policy, `/health`, `/version`, external smoke test, and structured logs |

## Accepted constraints

- AWS Learner Lab credentials expire and must be refreshed before a deployment.
- CodeQL code scanning is free for public repositories; private repositories require
  GitHub Code Security. The workflow therefore skips safely while the repository is
  private unless that entitlement is available.
- SSH is retained because it matches the taught Terraform and Ansible architecture.
  AWS Systems Manager would remove the inbound SSH requirement but may require IAM
  capabilities unavailable in the Learner Lab.
- The initial Learner Lab demonstration uses HTTP. A production design would terminate
  TLS at an Application Load Balancer or equivalent managed entry point.
