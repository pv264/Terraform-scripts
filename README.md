I structure Terraform using reusable modules such as VPC, security groups, and compute. Each module is self-contained, with clearly defined inputs and outputs, so it can be reused across environments.

Then I use environment-specific root modules, like dev or UAT, to orchestrate these modules. The root module passes values into modules and connects outputs between them.

For example, in my setup, the VPC module outputs subnet IDs, which are passed to the security group module and then to the EC2 module. Modules don’t directly reference each other’s resources—they only communicate through inputs and outputs, which keeps them loosely coupled.

I also use terraform.tfvars files to provide environment-specific values and maintain separate backend state files, typically in S3 with DynamoDB locking, to ensure each environment is isolated.

This approach keeps the infrastructure reusable, scalable, and easy to maintain across multiple environments.
