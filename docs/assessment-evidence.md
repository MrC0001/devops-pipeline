# Assessment evidence plan

This file is a recording checklist, not a script. Every claim should be demonstrated
with the running repository, workflow, AWS environment, or logs.

## Functionality - 40%

- Show the interactive page, `/health`, and `/version` locally and in AWS.
- Trigger a pipeline from a visible commit and show tests blocking deployment.
- Show Terraform plan/apply output and the resulting EC2 and security-group resources.
- Show Ansible configuring Nginx and systemd, then rerun it to demonstrate idempotence.
- Show the external smoke test and a separate controlled destroy workflow.

## DevOps understanding - 20%

- Explain CI versus continuous delivery and why production has manual approval.
- Explain Infrastructure as Code, configuration management, immutable intent, and
  shift-left security in relation to the files being demonstrated.
- Assess the pipeline using deployment frequency, lead time, change failure rate,
  and mean time to restore rather than simply saying it works.

## Design and architecture - 20%

- Use `architecture.md` to explain each boundary and the order of operations.
- Justify EC2, Nginx, systemd, Terraform, Ansible, GitHub Actions, and the minimal app.
- Discuss alternatives: AWS Systems Manager versus SSH, public versus private CodeQL,
  and S3 remote state versus local state.

## Reflection - 20%

- Show one real failure and explain how the logs led to the fix.
- Discuss credential expiry, remote-state setup, security/usability trade-offs, and
  what would change in a production organisation.
- Relate shared ownership, early feedback, blameless improvement, and security-team
  involvement to the student's own organisation and wider industry.
