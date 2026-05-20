# Terraform – Spring PetClinic on AWS ECS Fargate

## Architecture

```
Internet
  │
  ▼
┌──────────┐      ┌──────────────┐      ┌──────────────┐
│   ALB    │─────▶│  ECS Fargate │─────▶│  RDS MySQL   │
│ (public) │      │  (private)   │      │  (db subnet) │
└──────────┘      └──────────────┘      └──────────────┘
     │                   │
   HTTPS              Secrets
   (ACM)             Manager
```

## Prerequisites

| Item | Description |
|------|-------------|
| AWS Account | With sufficient permissions for VPC, ECS, RDS, ALB, IAM, KMS, Secrets Manager, ECR, CloudWatch |
| Terraform | >= 1.6 |
| AWS CLI | v2, configured with appropriate profile |
| ACM Certificate | Valid certificate ARN in `ap-northeast-1` for your domain |
| S3 Bucket + DynamoDB Table | For remote state (optional, see `versions.tf`) |
| Docker | For building container images |

## Quick Start

```bash
# 1. Initialize
cd terraform
terraform init

# 2. Create variable file
cat > terraform.tfvars <<'EOF'
env             = "dev"
aws_region      = "ap-northeast-1"
certificate_arn = "arn:aws:acm:ap-northeast-1:123456789012:certificate/xxxxxxxx"
EOF

# 3. Plan
terraform plan -out=tfplan

# 4. Apply
terraform apply tfplan
```

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `ap-northeast-1` | AWS region |
| `env` | string | `dev` | Environment name |
| `project` | string | `petclinic` | Project name |
| `certificate_arn` | string | **required** | ACM certificate ARN |
| `vpc_cidr` | string | `10.20.0.0/16` | VPC CIDR block |
| `rds_instance_class` | string | `db.t4g.medium` | RDS instance class |
| `rds_multi_az` | bool | `true` | Enable Multi-AZ for RDS |
| `ecs_desired_count` | number | `2` | Desired ECS task count |
| `ecs_autoscaling_min` | number | `2` | Min ECS tasks (Auto Scaling) |
| `ecs_autoscaling_max` | number | `6` | Max ECS tasks (Auto Scaling) |
| `ecs_task_cpu` | number | `1024` | CPU units per task |
| `ecs_task_memory` | number | `2048` | Memory (MiB) per task |

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC ID |
| `alb_dns_name` | ALB DNS name (point your domain here) |
| `ecr_repository_url` | ECR repository URL for Docker images |
| `ecs_cluster_name` | ECS cluster name |
| `ecs_service_name` | ECS service name |
| `rds_endpoint` | RDS endpoint |
| `db_secret_arn` | Secrets Manager ARN for DB credentials |

## Module Structure

```
terraform/
├── main.tf           # Root module – wires all child modules
├── variables.tf      # Input variables
├── outputs.tf        # Root outputs
├── locals.tf         # Local values (naming, CIDRs, tags)
├── versions.tf       # Provider & backend configuration
├── README.md         # This file
└── modules/
    ├── network/      # VPC, subnets (public/private/db × 2 AZ), IGW, NAT, route tables
    ├── alb/          # ALB, HTTPS listener, HTTP→HTTPS redirect, target group, SG
    ├── ecs/          # ECR, ECS cluster, Fargate service, task definition, IAM roles, auto scaling
    └── rds/          # RDS MySQL, KMS encryption, Secrets Manager, DB subnet group, SG
```

## Remote State Bootstrap

Uncomment the `backend "s3"` block in `versions.tf` and create the resources:

```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket petclinic-terraform-state \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

aws s3api put-bucket-versioning \
  --bucket petclinic-terraform-state \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket petclinic-terraform-state \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'

# Create DynamoDB lock table
aws dynamodb create-table \
  --table-name petclinic-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-northeast-1

# Re-initialize with the new backend
terraform init -migrate-state
```

## Initial Deployment

1. **Terraform apply** – provisions VPC, RDS, ECS cluster, ALB, ECR, etc.
2. **Build & push Docker image** – see `.github/workflows/deploy.yml`
3. **Verify** – check ALB DNS name, ECS service events, RDS connectivity
4. **DNS** – point your domain (Route 53 / external) to the ALB DNS name

## Rollback Procedures

### Application rollback (ECS)

```bash
# List recent task definitions
aws ecs list-task-definitions --family-prefix petclinic-dev-app --sort DESC

# Update service to a previous task definition
aws ecs update-service \
  --cluster petclinic-dev-cluster \
  --service petclinic-dev-app \
  --task-definition petclinic-dev-app:<PREVIOUS_REVISION> \
  --force-new-deployment

# Wait for stabilization
aws ecs wait services-stable \
  --cluster petclinic-dev-cluster \
  --services petclinic-dev-app
```

### Infrastructure rollback (Terraform)

```bash
# Revert to a previous state version
# If using S3 backend with versioning:
aws s3api list-object-versions \
  --bucket petclinic-terraform-state \
  --prefix envs/dev/terraform.tfstate

# Restore a previous version
aws s3api get-object \
  --bucket petclinic-terraform-state \
  --key envs/dev/terraform.tfstate \
  --version-id <VERSION_ID> \
  terraform.tfstate.backup

# Or revert the Terraform code and re-apply
git revert <COMMIT_HASH>
terraform plan -out=tfplan
terraform apply tfplan
```

### Database rollback (RDS)

```bash
# Restore from automated backup
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier petclinic-dev-mysql \
  --target-db-instance-identifier petclinic-dev-mysql-restored \
  --restore-time <ISO-8601-TIMESTAMP>
```
