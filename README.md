# terraform-snowflake-rbac-infra
https://github.com/Infostrux-Solutions/terraform-snowflake-rbac-infra/actions/workflows/deploy.yaml/badge.svg
The infrastructure stack deploys snowflake databases, warehouses, roles, and grants based on the configuration in the `./config` directory. See `Configuration` below.

## Prerequisites

<details>
<summary>AWS Authentication Requirements</summary>
<br>

Terraform needs credentials to connect to the remote backend. Multiple configurations are available, and Terraform provides <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs">complete documentation</a>  on how to set up the credentials. It's best practice to use <a href="https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/">temporary credentials</a> to connect GitHub with AWS.
<br>

Once the above is complete, you must set up an environment in GitHub Settings (development, production) and add a secret to it, `AWS_ROLE_ARN,` with the role ARN created during the instructions above.
</details>
<br/>

<details>
<summary>Snowflake Authentication provider requirements</summary>
<br>
In Terraform, each <a href="https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs">provider</a> requires credentials to manage resources on our behalf. Below, you will find the variables we use to connect to Snowflake.

- **account** - (required) Both the name and the region (ex: corp.us-east-1). It can also come from the `SNOWFLAKE_ACCOUNT` environment variable.
- **user** - (required) It can come from the `SNOWFLAKE_USER` environment variable.
- **private_key** - (required) A private key for using keypair authentication. It can be a source from the `SNOWFLAKE_PRIVATE_KEY` environment variable.
- **role** - (optional) Snowflake role to use for operations. If left unset, the user's default role will be used. It can come from the `SNOWFLAKE_ROLE` environment variable.
- **authenticator** - (required) When using `private_key` you must specify `authenticator = "JWT"` otherwise Terraform will return `Error: 260002: password is empty`.

The developer will configure the account, username, role, and authenticator in the terraform `.tfvars` file.
</details>
<br/>

<details>
<summary>Snowflake User key Creation</summary>
<br>
If you don't already have a dedicated user in your Snowflake account for running Terraform, see the <a href="https://docs.snowflake.com/en/user-guide/key-pair-auth">offical documentation</a> for up-to-date instructions.

<br>

In your development environment, run the following command to generate a key pair:

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out terraform.p8 -nocrypt
openssl rsa -in terraform.p8 -pubout -out terraform.pub
```

The next step is to associate the public key with your snowflake user.
In the Snowflake console, execute the `create user` command with the `USERADMIN` role, exclude the public key delimiters in the SQL statement. Execute the `grant role` commands with the `SECURITYADMIN` role.

```SQL
create user TERRAFORM rsa_public_key='MIIBIjANBgkqh...';
grant role SYSADMIN to user TERRAFORM;
grant role SECURITYADMIN to user TERRAFORM;
```

You can execute a DESCRIBE USER command to verify the user's public key.

```SQL
desc user TERRAFORM;
```

The private key must be created as a GitHub environment secret named `SNOWFLAKE_PRIVATE_KEY` in each environment.
</details>

## Configuration

| File                    | Description |
| ----------------------- | ------------- |
| config/roles.yml        | The roles file is used to grant access roles to the environment functional roles (`environment_roles`) as well as to grant the environment functional roles to the top-level account roles. (`account_roles`) |
| config/permissions.yml  | The permissions file is used to specify the grants that are to be assigned to the corresponding object access roles, it is a lookup for the object-level grants                                               |
| config/databases.yml    | The databases file is used to specify the databases to be created and the object access roles that should be created under each database                                                                     |
| config/warehouses.yml   | The warehouses file is used to specify the warehouses to be created, as well as the environment functional role permissions to be granted to the warehouse      
| config/users.yml        | The users file is used to specify the users to be created, as well as to set the default warehouse, default role and grant the default role to the user |

## Adding roles
### Functional roles
1. Navigate to the `config/roles.yml` file
2. If creating an environment level role add a new `key:value` sequences under `environment_roles`
    1. The key should be the name of the role (terraform will prepend the environment and project)
    2. The value should be a list of object access roles defined in `config/databases.yml`
3. If creating an account level role add a new `key:value` sequences under `account_roles`
    1. The key should be the name of the role you would like to create
    2. The value should be the `function roles` that you would like to grant to the account level role (Do not grant object level roles)
### Object roles
1. Navigate to the `config/databases.yml` file
2. We create either a read (`r`) or a read/write (`rw`) role under each named database. We have a `key:value` sequences under each database name, the `key` is `roles` the value is an sequences of role names (`r, rw`)
3. For each of the roles we defined in `step 2` we must create a lookup to define the permissions we want to set to the `r` and `rw` roles, we define the permissions in `config/permissions.yml`
    1. Navigate to `config/permissions.yml`
    2. Each object `database, warehouse, etc` has its own `key:value` sequences to define the object we want to grant permissions on `key` and the permissions we want to grant `value` this is repeated for each role we defined in `step 2`
## Adding Databases
1. Navigate to the `config/databases.yml` file
2. Add a new block with the name of the new database (terraform will prepend the environment and project) and the object roles you would like to create under the new database name (`r, rw`)
```
  database_name: 
    roles:
      - r
      - rw
```
## Adding Warehouses
1. Navigate to the `config/warehouses.yml` file
2. Add a new block with the name of the new warehouse (terraform will prepend the environment and project) under the `key:value` mapping
    1. Under the new `key` you can add a `key:value` literal to set the `auto_suspend` or `size` on the warehouse
    2. Under the new `key` you can add a `key:value` mapping called `roles` to grant permissions to functional roles defined in `config/roles.yml`. The `key` is the role name and the `value` is a sequences of permissions on the warehouse to grant
```
  warehouse_name:
    auto_suspend: 60
    roles:
      analyst:
        - usage
        - operate
```
## Adding Users
1. Navigate to the `config/users.yml` file
2. Under the `key:value` mapping `users` you can define the name of the role `key` (terraform will prepend the environment and project)
3. The `value` under the mapping created on `step 2` can be either the role or the warehouse to assign to the user
    1. To grant a role to the user add a `key:value` literal with `role: name_of_role`
    2. To grant access to use a warehouse to the user add a `key:value` literal with `warehouse: name_of_warehouse`


## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_apply"></a> [always\_apply](#input\_always\_apply) | Toggle to always apply on all objects. Used for when there are changes to the grants that need to be retroatively granted to roles | `bool` | `false` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | A comment to apply to all resources | `string` | `"Created by terraform"` | no |
| <a name="input_create_parent_roles"></a> [create\_parent\_roles](#input\_create\_parent\_roles) | Whether or not you want to create the parent roles (for production deployment only) | `bool` | `false` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all Snowflake resources | `map(string)` | n/a | yes |
| <a name="input_default_warehouse_auto_suspend"></a> [default\_warehouse\_auto\_suspend](#input\_default\_warehouse\_auto\_suspend) | The auto\_suspend (seconds) of the Snowflake warehouse that we will be utilizing to run queries in the snowflake\_account | `number` | `600` | no |
| <a name="input_default_warehouse_size"></a> [default\_warehouse\_size](#input\_default\_warehouse\_size) | The size of the Snowflake warehouse that we will be utilizing to run queries in the snowflake\_account | `string` | `"xsmall"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment we are deploying, for environment separation and naming purposes | `string` | n/a | yes |
| <a name="input_governance_database_name"></a> [governance\_database\_name](#input\_governance\_database\_name) | The name to set for governance database | `string` | `"GOVERNANCE"` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the project, for naming and tagging purposes | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region that we will deploy into, as well as for naming purposes | `string` | n/a | yes |
| <a name="input_snowflake_account"></a> [snowflake\_account](#input\_snowflake\_account) | The name of the Snowflake account that we will be deploying into | `string` | n/a | yes |
| <a name="input_snowflake_role"></a> [snowflake\_role](#input\_snowflake\_role) | The role in Snowflake that we will use to deploy by default | `string` | n/a | yes |
| <a name="input_snowflake_user"></a> [snowflake\_user](#input\_snowflake\_user) | The name of the Snowflake user that we will be utilizing to deploy into the snowflake\_account | `string` | n/a | yes |
| <a name="input_tag_admin_role"></a> [tag\_admin\_role](#input\_tag\_admin\_role) | The name to set for the tag admin | `string` | `"TAG_ADMIN"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags and their allowed values to create in Snowflake. This will also create a database and schema to house the tags | `map(list(string))` | `{}` | no |
| <a name="input_tags_schema_name"></a> [tags\_schema\_name](#input\_tags\_schema\_name) | The name to set for tags schema | `string` | `"TAGS"` | no |

## Deployment

1. Update the `backends/backend-{env}.tfvars` file to point to the appropriate S3 backend (if required)
2. Update the `environments/{env}.tfvars` file with any variable changes that may be required
3. Navigate to `GitHub Actions` and trigger `Plan Snowflake Infra`
    1. Select `Run Workflow`
    2. From the drop down menu choose the target environment from `Plan to`
    3. Select `Run Workflow` and verify that the plan is showing what we want to deploy is expected
4. Navigate to `GitHub Actions` and trigger `Deploy Snowflake Infra`
    1. Select `Run Workflow`
    2. From the drop down menu choose the target environment from `Plan to`
    3. (Optional) If you have added a new role which requires grants to all existing objects, you can set `Re-run all grants` to `true`
    4. Select `Run Workflow` and to deploy the changes verified above


