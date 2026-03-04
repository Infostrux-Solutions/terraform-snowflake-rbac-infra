# AWS IAM Policies for Terraform State Management

This directory contains IAM policies required for managing Terraform state in an S3 bucket.

## Files

- `iam-policy-terraform-state.json`: Full access policy for Terraform state operations (read/write)
- `iam-trust-policy.json`: Trust policy for IAM role to allow GitHub Actions OIDC authentication

## Policy Details

### Full Access Policy (`iam-policy-terraform-state.json`)

This policy grants the following permissions:
- **S3 Bucket Access**: List bucket, get bucket versioning, ACL, and location
- **S3 Object Access**: Get, put, and delete objects in the state bucket

**Resources:**
- S3 Bucket: `infostrux-sandbox-terraform-state-us-west-2`

### Trust Policy (`iam-trust-policy.json`)

This trust policy allows GitHub Actions to assume an IAM role using OIDC authentication:
- **Principal**: GitHub Actions OIDC provider
- **Repository**: `Infostrux-Solutions/terraform-snowflake-rbac-infra`
- **Branches**: All branches (no branch restriction)

## Prerequisites: Setting Up OIDC Identity Provider

Before creating IAM roles for GitHub Actions, you need to configure an OIDC identity provider in AWS IAM.

### Step 1: Create OIDC Identity Provider

The OIDC identity provider allows GitHub Actions to authenticate with AWS using temporary credentials.

**Note**: If you already have an OIDC identity provider for GitHub Actions in your AWS account, you can skip this step. You can check if it exists via AWS using:

```bash
aws iam list-open-id-connect-providers
```

#### Using AWS CLI

```bash
# Create the OIDC identity provider for GitHub Actions
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --region us-west-2
```

**Note**: The thumbprint may change. If you encounter issues, you can get the current thumbprint using:

```bash
# Get the current thumbprint from GitHub's OIDC endpoint
echo | openssl s_client -servername token.actions.githubusercontent.com -showcerts -connect token.actions.githubusercontent.com:443 2>/dev/null | \
  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
  openssl x509 -fingerprint -noout -sha1 | \
  sed 's/.*=//' | tr '[:upper:]' '[:lower:]'
```

#### Using AWS Console

1. Navigate to IAM → Identity providers → Add provider
2. Select **OpenID Connect**
3. Provider URL: `https://token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Click **Add provider**

### Step 2: Create IAM Role for GitHub Actions

After creating the OIDC identity provider, create an IAM role that GitHub Actions can assume.

#### Using AWS CLI

```bash
# Create the IAM role with the trust policy
aws iam create-role \
  --role-name GitHubActionsTerraformRole \
  --assume-role-policy-document file://iam-trust-policy.json \
  --description "IAM role for GitHub Actions to access Terraform state in S3" \
  --region us-west-2

# Get the policy ARN (replace ACCOUNT_ID with your AWS account ID)
POLICY_ARN="arn:aws:iam::ACCOUNT_ID:policy/TerraformStateAccess"

# Attach the Terraform state policy to the role
aws iam attach-role-policy \
  --role-name GitHubActionsTerraformRole \
  --policy-arn $POLICY_ARN
```

#### Using AWS Console

1. Navigate to IAM → Roles → Create role
2. Select **Web identity**
3. Identity provider: Choose `token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Click **Next**
6. In the permissions section, attach the `TerraformStateAccess` policy (create it first using the steps below)
7. Role name: `GitHubActionsTerraformRole`
8. Description: "IAM role for GitHub Actions to access Terraform state in S3"
9. Create the role
10. After creating the role, edit the trust relationship and replace it with the contents of `iam-trust-policy.json`

### Step 3: Configure GitHub Secrets

Once the IAM role is created, add the role ARN to your GitHub repository secrets:

1. Navigate to your GitHub repository → Settings → Secrets and variables → Actions
2. For each environment (development, production), add:
   - Secret name: `AWS_ROLE_ARN`
   - Secret value: `arn:aws:iam::ACCOUNT_ID:role/GitHubActionsTerraformRole`

**Note**: Replace `ACCOUNT_ID` with your AWS account ID (e.g., `531175092231`).


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

### OIDC Authentication Issues

If GitHub Actions cannot assume the IAM role:

1. **Verify OIDC Provider Exists**:
   ```bash
   aws iam list-open-id-connect-providers
   ```
   Ensure `token.actions.githubusercontent.com` is listed.

2. **Check Trust Policy**: Verify the trust policy on your IAM role matches `iam-trust-policy.json`:
   ```bash
   aws iam get-role --role-name GitHubActionsTerraformRole --query 'Role.AssumeRolePolicyDocument'
   ```

3. **Verify GitHub Secret**: Ensure `AWS_ROLE_ARN` is set correctly in GitHub repository secrets/environment secrets.

4. **Check Repository Name**: Verify the repository name in the trust policy matches your actual repository:
   - Current: `Infostrux-Solutions/terraform-snowflake-rbac-infra`
   - Update if your repository name differs

5. **Verify GitHub Actions Permissions**: Ensure your GitHub Actions workflow has the required permissions:
   ```yaml
   permissions:
     id-token: write  # Required for OIDC
     contents: read  # Required to checkout code
   ```

6. **Check AWS Region**: Ensure the OIDC provider and IAM role are in the same region as your S3 bucket (us-west-2).

