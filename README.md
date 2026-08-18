# DevOps Pipeline

I built DevOps Pipeline around a small Node.js app that shows which version is running
and whether it is healthy. Most of the work is in the release process: GitHub Actions
checks the code, Terraform creates the AWS resources, and Ansible sets up the server
and deploys the app.

## How the pipeline works

Pull requests and pushes to `main` run the app tests, linting, dependency audit,
secret scan, Semgrep static analysis, Terraform checks, Checkov, and Ansible
checks. These jobs do not make changes in AWS.

Deployment is started manually from the same workflow after a checked change reaches
`main`. The job is recorded against the `production` GitHub Environment, creates or
updates the AWS resources, deploys the selected commit, and finishes with health,
version, service-status, and log checks.

## Run locally

```powershell
cd app
npm ci
npm run check
npm start
```

Open `http://localhost:3000`.

The app provides:

- `GET /health` to confirm the service is responding.
- `GET /version` to show the deployed version, commit, and time.
- JSON request logs that can be read through the systemd journal.

## Documentation

- [Architecture](docs/architecture.md)
- [First deployment guide](docs/first-deployment.md)
- [Threat model](docs/threat-model.md)
- [Design decisions](docs/design-decisions.md)
- [Recording checklist](docs/assessment-evidence.md)

## Repository structure

```text
app/          Node.js application and tests
terraform/    AWS infrastructure and remote-state configuration
ansible/      EC2 configuration and application deployment
.github/      CI/CD, security, and destroy workflows
docs/         Architecture, decisions, setup, and recording notes
```
