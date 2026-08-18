# Threat model

This is the set of risks I considered while building the pipeline. It is limited to
this repository, the deployment process, and the AWS resources used by the app.

## What needs protecting

The main things I need to protect are the source code, GitHub Actions secrets, AWS
resources, Terraform state, the SSH key, the release archive, and the running app.

Data crosses a boundary between my computer and GitHub, between a GitHub runner and
AWS, between the public internet and Nginx, and between Nginx and the local Node.js
service.

## Main risks and controls

| Risk | Potential effect | Control and evidence |
|---|---|---|
| AWS or SSH credential committed to Git | Someone could access the account or server | `.gitignore`, GitHub encrypted secrets, Gitleaks, and temporary AWS credentials |
| Vulnerable dependency | The app or build process could be compromised | Lockfile, `npm audit`, Dependabot, and scheduled checks |
| Unsafe browser content | Injection or cross-site scripting | The app stores no user input, DOM updates use `textContent`, and Helmet sets a Content Security Policy |
| A pull request changes AWS | Unreviewed code could reach the server | Pull requests run checks only; deployment must be started from checked code on `main` |
| Workflow has more access than it needs | Repository or supply-chain compromise | Workflows use `contents: read`; extra permission is limited to the CodeQL job that needs it |
| SSH is open to the internet | Someone could try to access the server | Port 22 only accepts the current GitHub runner `/32`; Node.js binds to loopback and port 3000 is not exposed |
| Unsafe Terraform code | AWS resources could be exposed or misconfigured | Formatting, validation, Checkov, and creation of a saved plan all run before the exact saved plan is applied |
| Server setup changes between runs | Deployment becomes unreliable | The Ansible playbook is checked by ansible-lint, verifies each service, and runs twice with identical inputs to expose non-idempotent tasks |
| Terraform state is lost or changed twice | Resources could be duplicated or left behind | Encrypted and versioned S3 state, state locking, and one production concurrency group |
| A broken release looks successful | Users receive a failed or wrong version | systemd restart policy, health and version endpoints, public smoke tests, and JSON logs |

## Current limits

- AWS Learner Lab credentials expire and must be refreshed before a deployment.
- CodeQL cannot upload results from a private repository unless GitHub Code Security
  is available. The other security checks do not have this restriction.
- SSH is used because Ansible needs a route to the server. AWS Systems Manager could
  remove inbound SSH, but it needs IAM permissions that may not be available in the
  student account.
- The project currently uses HTTP. A production version would terminate HTTPS at an
  Application Load Balancer or a similar managed service.
- The runner `/32` SSH rule remains in Terraform state after deployment, and
  `ssh-keyscan` uses trust on first use. A production design would use Systems Manager,
  a private runner, or remove the inbound rule after configuration.
- Logs are stored locally in the systemd journal and Nginx files. The workflow captures
  a short excerpt, but a production system would use central log storage, metrics, and
  alerts.
- A failed smoke test does not automatically roll back the release. Recovery currently
  means diagnosing the run, reverting or correcting the commit, and redeploying.
- The workflow bootstraps and retains the versioned state bucket outside the main
  Terraform configuration. It needs a separate final retention and cleanup decision.
- Workflow actions use major-version tags. Dependabot helps with updates, but immutable
  commit-SHA pinning would reduce the remaining supply-chain risk.
