# Recording checklist

This is what I plan to cover in the recording. It is a checklist rather than a script,
so I can explain the project naturally while showing evidence from the repository,
workflow, AWS, and the running app.

## Functionality - 40%

- Show the page, health check, and version endpoint running in AWS.
- Start with a visible commit so the deployed SHA can be matched to GitHub.
- Show the application and security checks completing before deployment.
- Show the Terraform plan and the project server and security group in AWS.
- Show Ansible setting up Nginx and systemd, then use the second execution recap to
  assess whether the same inputs caused unnecessary changes.
- Show the public smoke test and explain why the destroy workflow requires its own
  confirmation.
- Show the captured service status and systemd logs instead of merely stating that
  logging exists.

## DevOps understanding - 20%

- Explain the difference between CI and continuous delivery, and why I kept production
  deployment manual.
- Explain Infrastructure as Code, configuration management, and why the security
  checks run early in the pipeline rather than after deployment.
- Use the four DORA measures to assess the pipeline: deployment frequency, lead time
  for changes, change failure rate, and mean time to restore.

## Design and architecture - 20%

- Use the architecture diagram to explain the route from a pull request to the running
  app.
- Explain why I chose EC2, Nginx, systemd, Terraform, Ansible, GitHub Actions, and a
  small Node.js app.
- Compare SSH with AWS Systems Manager, private and public CodeQL support, and remote
  Terraform state with local state.
- Explain that the S3 backend is bootstrapped by the workflow before Terraform starts,
  and that the generated plan is automatically applied rather than human-reviewed.

## Reflection - 20%

- Show one real failed run and explain how I found and fixed the problem.
- Discuss temporary AWS credentials, remote state, security trade-offs, and what I
  would change for a production system.
- Be explicit that CodeQL skipped in the private repository and was not a deployment
  gate. Compare the checks that did run with Sonar, Nexus IQ, TruffleHog, Aqua, ZAP,
  and Playwright without presenting them as direct substitutes.
- Explain the current git-revert-and-redeploy recovery process, the lack of automatic
  rollback, and the production case for immutable action SHAs and central monitoring.
- Relate shared ownership, early feedback, blameless improvement, and security-team
  involvement to my workplace and the wider industry.
