# Design decisions

## Keep the original deployment architecture

GitHub Actions, Terraform, Ansible, EC2, Nginx, systemd, and Node.js remain the
smallest architecture that demonstrates every required DevOps concern. The latest
security lesson adds gates around this flow; it does not justify replacing it with a
larger AWS-native platform.

## Separate pull-request checks from deployment

Pull requests must never create or change AWS resources. They run application and
security checks only. Deployment will run after a checked change reaches `main`, and
a GitHub Environment will require approval before Terraform applies anything.

This also corrects the supplied DevSecOps workflow, which can start its deployment job
for a pull request and does not make deployment depend on every security job.

## Reuse the lesson's controls, not its application

The useful additions from the new examples are CodeQL, Gitleaks, dependency auditing,
Checkov, and ansible-lint. The demo application is not used because its test is empty,
its Ansible playbook does not install Node dependencies, and its security group permits
SSH from every IPv4 address. The separate CodeQL project is intentionally vulnerable
and must remain teaching material rather than deployment code.

## Keep the repository private initially

Private visibility protects unfinished assessment work. GitHub CodeQL code scanning is
therefore prepared but safely skipped unless GitHub Code Security is available. Before
recording, the options are to keep the repository private and demonstrate the other
security gates, or deliberately make it public so CodeQL results can populate the
Security tab.

## Use persistent state and temporary access

Terraform state will use an encrypted, versioned S3 backend if Learner Lab permissions
allow it. AWS credentials remain temporary GitHub secrets and are refreshed for each
lab session. SSH will be restricted to the active GitHub runner address rather than a
static personal address or `0.0.0.0/0`.
