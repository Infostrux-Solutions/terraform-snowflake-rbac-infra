# terraform-snowflake-rbac-infra
The infrastructure stack deploys snowflake databases, warehouses, and grants based on the configuration in the `./config` directory.

## Prerequisites

<details>
<summary>AWS Authentication Requirements</summary>
<br>
Terraform needs credentials for connecting to the remote backend. Multiples configuration are available, and the AWS provides full documentation can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

Whenever possible, it's best practices to used temporary credentials. The most ideal approach when connecting to GitHub Actions would be to use the instructions found <a href="https://benoitboure.com/securely-access-your-aws-resources-from-github-actions">here</a> to create a role that will be assumed by GitHub.

Once the above is complete you must setup an environment in GitHub Settings (development, production) and add a secret to it `AWS_ROLE_ARN` with the role ARN created during the instructions above.
</details>
<br/>

<details>
<summary>Snowflake Authentication provider requirements</summary>
<br>
In Terraform, each provider needs credentials to manage resources on our behalf. In the case of the Snowflake provider, the following environment variables are required:

- **account** - (required) Both the name and the region (ex:corp.us-east-1). It can also come from the SNOWFLAKE_ACCOUNT environment variable.
- **username** - (required) Can come from the SNOWFLAKE_USER environment variable.
- **private_key** - (required) A private key for using keypair authentication. Can be a source from SNOWFLAKE_PRIVATE_KEY environment variable.
- **role** - (optional) Snowflake role to use for operations. If left unset, the user’s default role will be used. It can come from the SNOWFLAKE_ROLE environment variable.

The account, username, and role can be configured in the terraform `.tfvars` file.
</details>
<br/>

<details>
<summary>Snowflake User key Creation</summary>
<br>
If your snowflake don't already have an SSH key associated with it, the following
the command will ensure you are correctly set up.

Only the ciphers aes-128-cbc, aes-128-gcm, aes-192-cbc, aes-192-gcm, aes-256-cbc, aes-256-gcm, and des-ede3-cbc are supported by the Snowflake Terraform provider.

In your development environment, run the following command to generate a key pair:

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out infx_terraform.p8 -nocrypt
openssl rsa -in infx_terraform.p8 -pubout -out infx_terraform.pub
```

The next step is to associate the public key with your snowflake user.
Only a role with SECURITYADMIN admin privilege or higher can alter a user.
In the Snowflake user console, execute the following command and Exclude the public key delimiters in the SQL statement.:

```SQL
alter user INFX_TERRAFORM set rsa_public_key='MIIBIjANBgkqh...';
grant role SYSADMIN to user INFX_TERRAFORM;
grant role ACCOUNTADMIN to user INFX_TERRAFORM;
```

You can execute a DESCRIBE USER command to verify the user’s public key.

```SQL
desc user INFX_TERRAFORM;
```

The private key must be created as an GitHub environment secret with the name `SNOWFLAKE_PRIVATE_KEY`.
</details>

## Deployment

1. Update the `backend tfvars` file to point to the appropriate S3 backend (if required).
2. Update the `tfvars` file with any variable changes that may be required.
3. Navigate to `GitHub Actions` and trigger ` Plan Snowflake Infra` to verify that the plan is showing what we want to deploy is expected.
4. Again in  `GitHub Actions` trigger ` Deploy Snowflake Infra` to deploy the infrastructure to Snowflake.
