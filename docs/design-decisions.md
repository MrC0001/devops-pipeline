# Design decisions

## Keep the app small

The app only needs enough functionality to prove that a release worked. It shows its
version, commit, deployment time, and current health. I chose not to add a database or
extra AWS services because they would create more things to maintain without making
the pipeline clearer.

## Use GitHub Actions, Terraform, and Ansible together

Each tool has one clear job. GitHub Actions controls the pipeline, Terraform manages
AWS resources, and Ansible configures the operating system and deploys the app. Nginx
is the public entry point and systemd keeps the Node.js process running.

This is close to the approach used in the lessons, which means I can explain every
part of it. It also leaves a clear boundary between infrastructure and server
configuration instead of putting the whole setup into one large script.

## Use manual continuous delivery

Pull requests must never create or change AWS resources. They run application,
infrastructure, configuration, and security checks only. Deployment is an explicit
manual action after a checked change reaches `main`, so this is continuous delivery
rather than automatic continuous deployment. The `production` GitHub Environment
records deployments and can apply protection rules if the repository plan supports
them; the current private repository does not provide a required-reviewer gate.

This avoids a problem I found in one of the lesson examples, where the deployment job
could start from a pull request without depending on every security check.

## Improve the lesson examples rather than copy them

The example repositories gave me a useful starting point, but I did not use them
unchanged. One had an empty test, did not install the app dependencies through
Ansible, and opened SSH to every IPv4 address. The separate CodeQL example contains
security problems on purpose, so none of that application code belongs in this
project.

I kept the useful controls from the examples without treating them as
interchangeable. Gitleaks, dependency auditing, Semgrep, Checkov, and
ansible-lint are gates in the main workflow and must pass before AWS deployment.

## Keep the repository private and use available SAST

I am keeping the repository private. GitHub CodeQL requires GitHub Code Security
for private repositories, which is not available on this account. I replaced it
with Semgrep Community Edition instead of leaving a security workflow that
could not run.

Semgrep performs static analysis on the JavaScript application on every pull
request and push. It is part of the main workflow, so deployment cannot start
unless the scan passes. In a production organisation I would compare its
coverage and reporting with the security tooling already licensed there.

## Use persistent state and temporary access

Terraform state cannot be left on a GitHub runner because the runner disappears after
the job. The workflow therefore bootstraps or reuses an encrypted, versioned S3 bucket
before Terraform is initialised. This bootstrap uses the AWS CLI because the backend
must exist before Terraform can use it. S3 state locking stops two deployment jobs
changing the same state at once.

The AWS credentials are temporary GitHub secrets and need to be refreshed when the
lab session changes. Port 22 is opened only to the public address of the runner doing
the deployment, rather than a personal address or `0.0.0.0/0`.

## Keep the AWS setup manageable

The project reuses the default VPC and creates one `t2.micro` Amazon Linux 2023
server with one security group. Custom networking, a load balancer, and managed
deployment services would add cost and setup without helping this app. Some IAM
changes may also be restricted by the student account. The server has no IAM role
because the app does not call any AWS APIs.

Nginx listens on port 80 and forwards traffic to Node.js on loopback port 3000. The
first version uses HTTP because there is no domain or certificate. A production
version should use HTTPS, normally through a load balancer or another managed entry
point. Each Checkov exception is written beside the resource it applies to, with the
reason included, instead of switching a rule off for the whole repository.

## Use controlled recovery and cleanup

The project does not claim automatic rollback. If a post-deployment check fails, I
will diagnose the failed run, revert the faulty Git commit where appropriate, and run
the checked deployment again. A production release process would use versioned
release directories and an atomic switch back to the last healthy version.

The destroy workflow removes the Terraform-managed EC2 instance and security group
but keeps the versioned state bucket between test runs. I will remove that bucket and
its retained object versions as a separate final cleanup after the project no longer
needs recovery history.

## Keep workflow dependencies maintainable

GitHub Actions currently use trusted major-version tags and Dependabot checks for
updates. Full commit-SHA pinning would make those dependencies immutable and is a
production hardening improvement. I kept readable version tags for the first Learner
Lab run and record the remaining supply-chain risk rather than claiming it is absent.
