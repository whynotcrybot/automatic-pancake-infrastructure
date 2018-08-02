# Automatic Pancake Infrastructure

This repository holds project's infrastructure defined using Terraform, as well as Chef cookbooks.

## Getting Started

These instructions will help you to deploy the infrastructure on AWS using Terraform and Chef.

### Prerequisites

- `terraform` installed on your system
- `berks` installed on your system
- AWS user with AdministratorAccess policy attached

## Deployment instructions

- `cp terraform.tfvars.example terraform.tfvars`
- edit AWS credentials in `terraform.tfvars`
- `terraform init`
- `terraform apply`

Keep in mind that the process may take up to 10 minutes.
When setup is complete, ELB's dns name will be shown on the screen.

Web application might not be available for a few minutes after set up is complete.
Please, be patient.
