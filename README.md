# terraform-snowflake-rbac-infra
The infrastructure stack deploys snowflake databases, warehouses, roles, and grants based on the configuration in the `./config` directory. See `Configuration` below.

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

## Configuration

| File                    | Description |
| ----------------------- | ------------- |
| config/roles.yml        | The roles file is used to grant access roles to the environment functional roles (`environment_roles`) as well as to grant the environment functional roles to the top-level account roles. (`account_roles`). |
| config/permissions.yml  | The permissions file is used to specify the grants that are to be assigned to the corresponding object access roles, it is a lookup for the object-level grants.                                               |
| config/databases.yml    | The databases file is used to specify the databases to be created and the object access roles that should be created under each database.                                                                      |
| config/warehouses.yml   | The warehouses file is used to specify the warehouses to be created, as well as the environment functional role permissions to be granted to the warehouse.                                                    |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_apply"></a> [always\_apply](#input\_always\_apply) | Toggle to always apply on all objects. Used for when there are changes to the grants that need to be retroatively granted to roles | `bool` | `false` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | A comment to apply to all resources | `string` | `"Created by terraform"` | no |
| <a name="input_create_datadog_user"></a> [create\_datadog\_user](#input\_create\_datadog\_user) | Create the datadog user (true\|false) | `bool` | `false` | no |
| <a name="input_create_fivetran_user"></a> [create\_fivetran\_user](#input\_create\_fivetran\_user) | Create the fivetran user (true\|false) | `bool` | `false` | no |
| <a name="input_create_parent_roles"></a> [create\_parent\_roles](#input\_create\_parent\_roles) | Whether or not you want to create the parent roles (for production deployment only) | `bool` | `false` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all Snowflake resources | `map(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment we are deploying, for environment separation and naming purposes | `string` | n/a | yes |
| <a name="input_governance_database_name"></a> [governance\_database\_name](#input\_governance\_database\_name) | The name to set for governance database | `string` | `"GOVERNANCE"` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the project, for naming and tagging purposes | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region that we will deploy into, as well as for naming purposes | `string` | n/a | yes |
| <a name="input_snowflake_account"></a> [snowflake\_account](#input\_snowflake\_account) | The name of the Snowflake account that we will be deploying into | `string` | n/a | yes |
| <a name="input_snowflake_datadog_password"></a> [snowflake\_datadog\_password](#input\_snowflake\_datadog\_password) | The snowflake user password to set for datadog monitoring | `string` | `""` | no |
| <a name="input_snowflake_fivetran_password"></a> [snowflake\_fivetran\_password](#input\_snowflake\_fivetran\_password) | The snowflake user password to set for fivetran ingestion | `string` | `""` | no |
| <a name="input_snowflake_role"></a> [snowflake\_role](#input\_snowflake\_role) | The role in Snowflake that we will use to deploy by default | `string` | n/a | yes |
| <a name="input_snowflake_username"></a> [snowflake\_username](#input\_snowflake\_username) | The name of the Snowflake user that we will be utilizing to deploy into the snowflake\_account | `string` | n/a | yes |
| <a name="input_snowflake_warehouse_size"></a> [snowflake\_warehouse\_size](#input\_snowflake\_warehouse\_size) | The size of the Snowflake warehouse that we will be utilizing to run queries in the snowflake\_account | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags and their allowed values to create in Snowflake. This will also create a database and schema to house the tags | `map(list(string))` | `{}` | no |
| <a name="input_tags_schema_name"></a> [tags\_schema\_name](#input\_tags\_schema\_name) | The name to set for tags schema | `string` | `"TAGS"` | no |
| <a name="input_warehouse_auto_suspend"></a> [warehouse\_auto\_suspend](#input\_warehouse\_auto\_suspend) | The auto\_suspend (seconds) of the Snowflake warehouse that we will be utilizing to run queries in the snowflake\_account | `map(number)` | n/a | yes |

## Deployment

1. Update the `backend tfvars` file to point to the appropriate S3 backend (if required)
2. Update the `tfvars` file with any variable changes that may be required
3. Navigate to `GitHub Actions` and trigger `Plan Snowflake Infra`
    1. Select `Run Workflow`
    2. From the drop down menu choose the target environment from `Plan to`
    3. Select `Run Workflow` and verify that the plan is showing what we want to deploy is expected
4. Navigate to `GitHub Actions` and trigger `Deploy Snowflake Infra`
    1. Select `Run Workflow`
    2. From the drop down menu choose the target environment from `Plan to`
    3. (Optional) If you have added a new role which requires grants to all existing objects, you can set `Re-run all grants` to `true`
    4. Select `Run Workflow` and to deploy the changes verified above


