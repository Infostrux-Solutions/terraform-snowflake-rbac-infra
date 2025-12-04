# AWS IAM Policies for Terraform State Management

This directory contains IAM policies required for managing Terraform state in an S3 bucket.

## Files

- `iam-policy-terraform-state.json`: Full access policy for Terraform state operations (read/write)
- `iam-policy-terraform-state-readonly.json`: Read-only policy for CI/CD pipelines or read-only access

## Policy Details

### Full Access Policy (`iam-policy-terraform-state.json`)

This policy grants the following permissions:
- **S3 Bucket Access**: List bucket, get bucket versioning, ACL, and location
- **S3 Object Access**: Get, put, and delete objects in the state bucket

**Resources:**
- S3 Bucket: `infx-dev-terraform-state-us-west-2`

### Read-Only Policy (`iam-policy-terraform-state-readonly.json`)

This policy grants read-only access for:
- Viewing Terraform state files
- Listing bucket contents
- Useful for CI/CD pipelines that only need to read state

## How to Use

### Option 1: Using AWS CLI

#### Create the IAM Policy

```bash
# Create the full access policy
aws iam create-policy \
  --policy-name TerraformStateAccess \
  --policy-document file://iam-policy-terraform-state.json \
  --description "Policy for Terraform state management in S3"

# Create the read-only policy
aws iam create-policy \
  --policy-name TerraformStateReadOnly \
  --policy-document file://iam-policy-terraform-state-readonly.json \
  --description "Read-only policy for Terraform state access"
```

#### Attach Policy to IAM User

```bash
# Get the policy ARN (replace ACCOUNT_ID with your AWS account ID)
POLICY_ARN="arn:aws:iam::ACCOUNT_ID:policy/TerraformStateAccess"

# Attach to a user
aws iam attach-user-policy \
  --user-name terraform-user \
  --policy-arn $POLICY_ARN
```

#### Attach Policy to IAM Role

```bash
# Attach to a role (e.g., for EC2 instances or CI/CD)
aws iam attach-role-policy \
  --role-name terraform-role \
  --policy-arn $POLICY_ARN
```

### Option 2: Using Terraform

You can also manage these policies using Terraform. Here's an example:

```hcl
resource "aws_iam_policy" "terraform_state" {
  name        = "TerraformStateAccess"
  description = "Policy for Terraform state management in S3"
  policy      = file("${path.module}/iam-policy-terraform-state.json")
}

resource "aws_iam_user_policy_attachment" "terraform_state" {
  user       = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.terraform_state.arn
}
```

### Option 3: Using AWS Console

1. Navigate to IAM → Policies → Create Policy
2. Click on the JSON tab
3. Copy and paste the contents of `iam-policy-terraform-state.json`
4. Review and name the policy (e.g., `TerraformStateAccess`)
5. Create the policy
6. Attach it to the desired IAM user or role

## Customization

### Update Bucket Name

If your S3 bucket name differs, update the `Resource` ARN in both policy files:

```json
"Resource": "arn:aws:s3:::YOUR-BUCKET-NAME"
```

### Add Multiple Buckets

If you have multiple state buckets, add additional statements:

```json
{
  "Sid": "TerraformStateBucketAccess",
  "Effect": "Allow",
  "Action": [
    "s3:ListBucket",
    "s3:GetBucketVersioning"
  ],
  "Resource": [
    "arn:aws:s3:::bucket-1",
    "arn:aws:s3:::bucket-2"
  ]
}
```

## Security Best Practices

1. **Least Privilege**: Only grant the minimum permissions required
2. **Use Roles**: Prefer IAM roles over users for applications and CI/CD
3. **Enable MFA**: Require MFA for IAM users with state access
4. **Bucket Encryption**: Ensure S3 bucket encryption is enabled (already configured in your backend)
5. **Versioning**: Enable S3 bucket versioning for state file recovery
6. **Access Logging**: Enable S3 access logging to monitor state file access

## Troubleshooting

### Access Denied Errors

If you encounter access denied errors:

1. Verify the policy is attached to your IAM user/role
2. Check that the bucket name matches exactly
3. Ensure the region is correct (us-west-2)
4. Verify the IAM user/role has the correct trust relationships (for roles)

