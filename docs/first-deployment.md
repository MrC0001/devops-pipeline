# Run the first AWS deployment

Most of this setup only needs to be done once. The three temporary AWS credentials
need to be replaced whenever the Learner Lab starts a new session.

## 1. Start the Learner Lab

1. Open the DevOps module in Canvas and launch AWS Academy Learner Lab.
2. Select **Start Lab** and wait until the AWS indicator is green.
3. Open the AWS console and check which region is selected.
4. In EC2, find the key pair that the project will use. Download its private key if it
   has not already been saved. The key-pair name in AWS may be different from the file
   name.

Do not add credentials or private keys to this repository.

## 2. Configure the GitHub repository

In **Settings > Secrets and variables > Actions**, add these repository variables:

- `AWS_REGION` - the AWS region shown in the console.
- `EC2_KEY_NAME` - the existing EC2 key-pair name.

Add these repository secrets from the current Learner Lab session:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `EC2_SSH_PRIVATE_KEY` - the complete contents of the matching private `.pem` file.

Create a GitHub Environment named `production`. If required reviewers are available
for the repository, add a reviewer so there is a visible approval step. The current
private repository plan does not provide that reviewer gate, so manual workflow
dispatch remains the release decision.

## 3. Run the complete pipeline

1. Confirm the commit to deploy is on `main` and its normal checks are green.
2. Open **Actions > DevOps Pipeline > Run workflow**.
3. Select `main`, enable **Run the AWS deployment**, and start the workflow.
4. If protection rules have been configured and GitHub prompts for approval, approve
   the `production` environment.
5. Follow the Terraform plan and apply, then the Ansible and smoke-test steps.
6. Open the application URL written to the workflow summary.

The workflow builds a unique `devops-pipeline` S3 state-bucket name from the AWS
account and region. It bootstraps the bucket outside Terraform, then enables
encryption and versioning before Terraform uses it. State is not saved in GitHub.

## 4. Destroy the test environment

When the test is finished, run **Destroy DevOps Pipeline resources** from the Actions tab and
enter `DESTROY`. Terraform removes the project server and security group but keeps the
versioned state bucket for the next deployment.

If the Learner Lab credentials have expired, refresh the three AWS secrets before
running either deployment or destruction.
