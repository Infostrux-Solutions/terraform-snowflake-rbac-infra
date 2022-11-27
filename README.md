# terraform-snowflake-rbac-infra

## Prerequisites

### AWS Authentication Requirements

Terraform needs credentials for connecting to the remote backend. Multiples configuration are available, and the AWS provides full documentation can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

Whenever possible, it's best practices to used temporary credentials. However, user and access key can be used as part of a CI/CD solution when a SSO is not practical.

<br/>

### Snowflake Authentication provider requirements

In Terraform, each provider needs credentials to manage resources on our behalf. In the case of the Snowflake provider, the following environment variables are required:

- **account** - (required) Both the name and the region (ex:corp.us-east-1). It can also come from the SNOWFLAKE_ACCOUNT environment variable.
- **username** - (required) Can come from the SNOWFLAKE_USER environment variable.
- **private_key** - (required) A private key for using keypair authentication. Can be a source from SNOWFLAKE_PRIVATE_KEY environment variable.
- **role** - (optional) Snowflake role to use for operations. If left unset, the user’s default role will be used. It can come from the SNOWFLAKE_ROLE environment variable.

#### Snowflake User key Creation

If your snowflake don't already have an SSH key associated with it, the following
the command will ensure you are correctly set up.

Only the ciphers aes-128-cbc, aes-128-gcm, aes-192-cbc, aes-192-gcm, aes-256-cbc, aes-256-gcm, and des-ede3-cbc are supported by the Snowflake Terraform provider.

In your development environment, run the following command to generate an SSH key:

```bash
OpenSSL genrsa -out snowflake_key 4096
openssl rsa -in snowflake_key -pubout -out snowflake_key.pub
openssl pkcs8 -topk8 -inform pem -in snowflake_key -outform PEM -v2 aes-256-cbc -out snowflake_key.p8
```

The next step is to associate the public key with your snowflake user.
Only a role with SECURITYADMIN admin privilege or higher can alter a user.
In the Snowflake user console, execute the following command and Exclude the public key delimiters in the SQL statement.:

```SQL
alter user INFX_TERRAFORM set rsa_public_key='MIIBIjANBgkqh...';
```

You can execute a DESCRIBE USER command to verify the user’s public key.

```SQL
desc user INFX_TERRAFORM;
```

on a mac/linux type shell, variables can be execute like this:

```bash
export SNOWFLAKE_PRIVATE_KEY'...'
```

<br/>

## Deployment

### 01 - Deploy Roles

1. Update the `backend tfvars` file to point to the appropriate S3 backend (if required).
2. Update the `tfvars` file with any variable changes that may be required.
3. Navigate to `GitHub Actions` and trigger `roles-plan-manual` to verify that the plan is showing what we want to deploy is expected.
4. Again in  `GitHub Actions` trigger `roles-deploy-manual` to deploy the infrastructure to Snowflake.

### 02 - Deploy Infrastructure

1. Update the `backend tfvars` file to point to the appropriate S3 backend (if required).
2. Update the `tfvars` file with any variable changes that may be required.
3. Navigate to `GitHub Actions` and trigger `infra-plan-manual` to verify that the plan is showing what we want to deploy is expected.
4. Again in  `GitHub Actions` trigger `infra-deploy-manual` to deploy the infrastructure to Snowflake.

## Customization
### WITH_GRANT_OPTION
If you need to control the grant options on a resource by resource basis you can do this with the following configuration pattern. This can significantly increase the amount of code in the `.tfvars` files. This works exactly the same on databases, warehouses, schemas, tables, and views.
```
warehouses_and_roles = {
  "INGEST_WH" = {
    "USAGE" = {
      "ROLES"             = ["INGESTION", "SYSADMIN"]
      "WITH_GRANT_OPTION" = true
    }

    "MONITOR" = {
      "ROLES"             = ["SYSADMIN"]
      "WITH_GRANT_OPTION" = true
    }

    "MODIFY" = {
      "ROLES"             = ["SYSADMIN"]
      "WITH_GRANT_OPTION" = true
    }

    "OPERATE" = {
      "ROLES"             = ["INGESTION", "SYSADMIN"]
      "WITH_GRANT_OPTION" = true
    }

    "OWNERSHIP" = {
      "ROLES"             = ["SYSADMIN"]
      "WITH_GRANT_OPTION" = true
    }
  }
}
```

### Inherit role permissions
By default we are granting environment level roles to the parent role as seen below, Ex. `DEV_DEVELOPER` (left), will be granted to the top level `DEVELOPER` (right) role. You can place any existing role name on the right hand side, the left side is reserved for the dynamically generated roles found [here](https://github.com/Infostrux-Solutions/terraform-snowflake-rbac-infra/blob/bc5a4d19fcf333d61aaf8f5cd73c08dc84d437c8/terraform/01-snowflake-roles/development.tfvars#L32). 
 
```
role_to_roles = {
  "DEVELOPER"  = ["DEVELOPER"],
  "ANALYST"    = ["ANALYST"],
  "SYSADMIN"   = ["SYSADMIN"],
}
```
