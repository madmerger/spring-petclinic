# AWS Migration Starter Guide

This document describes the migration strategy for moving PetClinic from on-premises to AWS using a **replatform** (lift-tinker-and-shift) approach targeting **ECS Fargate + RDS PostgreSQL**.

---

## Architecture Overview

```
Internet
   │
   ▼
┌──────────────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)                                       │
│                                                          │
│  ┌─────────────────────────────┐                         │
│  │  Public Subnets (AZ-a, AZ-c)│                         │
│  │  ┌─────────────────────────┐│                         │
│  │  │  Application Load       ││                         │
│  │  │  Balancer (ALB)         ││                         │
│  │  └────────────┬────────────┘│                         │
│  │               │ NAT Gateway │                         │
│  └───────────────┼─────────────┘                         │
│                  │                                        │
│  ┌───────────────┼─────────────┐                         │
│  │  Private Subnets (AZ-a, AZ-c)│                        │
│  │               ▼             │                         │
│  │  ┌─────────────────────────┐│                         │
│  │  │  ECS Fargate Service    ││                         │
│  │  │  (Spring Boot App)      ││                         │
│  │  └────────────┬────────────┘│                         │
│  │               │             │                         │
│  │  ┌────────────▼────────────┐│                         │
│  │  │  RDS PostgreSQL         ││                         │
│  │  │  (db.t3.micro)          ││                         │
│  │  └─────────────────────────┘│                         │
│  └─────────────────────────────┘                         │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Directory Structure

```
├── Dockerfile                     # Multi-stage build (JDK 17)
├── .dockerignore                  # Excludes non-build files
├── terraform/
│   ├── main.tf                    # Root module wiring VPC → ALB → ECS → RDS
│   ├── variables.tf               # All configurable inputs
│   ├── outputs.tf                 # Key resource endpoints
│   ├── terraform.tfvars.example   # Sample variable values
│   └── modules/
│       ├── vpc/                   # VPC, subnets, NAT, route tables
│       ├── alb/                   # ALB, target group, HTTP listener
│       ├── ecs/                   # ECR, Fargate cluster/service/task, IAM
│       └── rds/                   # PostgreSQL, Secrets Manager, security group
├── .github/workflows/
│   └── aws-deploy.yml             # CI/CD: test → build → push ECR → deploy ECS
└── MIGRATION_STARTER.md           # This file
```

---

## Phase 1: Containerization (Dockerfile)

The multi-stage `Dockerfile` produces a minimal JRE-based image:

1. **Builder stage** (`eclipse-temurin:17-jdk`): downloads dependencies, compiles the app.
2. **Runtime stage** (`eclipse-temurin:17-jre`): copies the JAR, runs as non-root `appuser`.

### Build & run locally

```bash
# Build
docker build -t petclinic:latest .

# Run with embedded H2
docker run -p 8080:8080 petclinic:latest

# Run with external PostgreSQL
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=postgres \
  -e POSTGRES_URL=jdbc:postgresql://host.docker.internal:5432/petclinic \
  -e POSTGRES_USER=petclinic \
  -e POSTGRES_PASS=petclinic \
  petclinic:latest
```

---

## Phase 2: Infrastructure (Terraform)

### Prerequisites

- Terraform >= 1.5
- AWS CLI configured with appropriate credentials
- An S3 bucket + DynamoDB table for remote state (optional but recommended)

### Quick start

```bash
cd terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize and plan
terraform init
terraform plan

# Apply
terraform apply
```

### Module descriptions

| Module | Resources Created |
|--------|-------------------|
| **vpc** | VPC, 2 public subnets, 2 private subnets, Internet Gateway, NAT Gateway, route tables |
| **alb** | Application Load Balancer, target group (health check: `/actuator/health`), HTTP listener |
| **ecs** | ECR repository, ECS Fargate cluster, task definition, service, CloudWatch log group, IAM roles |
| **rds** | PostgreSQL 16.4 instance, DB subnet group, security group, Secrets Manager password |

### Key design decisions

- **Fargate** over EC2: no host management, built-in auto-scaling
- **Private subnets** for ECS + RDS: not publicly accessible
- **NAT Gateway** for outbound traffic from private subnets
- **Secrets Manager** for DB password: injected into ECS task via `secrets` block
- **Deployment circuit breaker** with auto-rollback on ECS
- **ECR lifecycle policy**: retains last 10 images

---

## Phase 3: CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/aws-deploy.yml`) runs on every push to `main`:

1. **Test job**: `./mvnw -B verify` (unit + integration tests)
2. **Build & Deploy job** (only on `main`):
   - Authenticates to AWS via IAM keys
   - Builds Docker image and pushes to ECR (tagged with commit SHA + `latest`)
   - Downloads current ECS task definition
   - Updates the task definition with the new image
   - Deploys to ECS with service stability wait

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM access key with ECR/ECS permissions |
| `AWS_SECRET_ACCESS_KEY` | IAM secret key |
| `AWS_REGION` | AWS region (e.g., `ap-northeast-1`) |

---

## Migration Phases (Roadmap)

### Phase 1 — Starter Package (this PR)
- [x] Dockerize the application
- [x] Terraform IaC skeleton (VPC, ALB, ECS, RDS)
- [x] CI/CD pipeline
- [x] Migration documentation

### Phase 2 — Database Migration
- [ ] Set up AWS DMS for live data replication from on-premises DB
- [ ] Create `application-aws.properties` profile with RDS connection
- [ ] Validate schema compatibility with PostgreSQL 16
- [ ] Run data integrity tests

### Phase 3 — Observability
- [ ] CloudWatch dashboards for ECS metrics
- [ ] X-Ray tracing integration
- [ ] CloudWatch alarms for CPU, memory, 5xx errors
- [ ] Centralized logging with CloudWatch Logs Insights

### Phase 4 — Security Hardening
- [ ] Enable HTTPS on ALB (ACM certificate)
- [ ] WAF rules on ALB
- [ ] Enable RDS encryption at rest + in transit
- [ ] VPC flow logs
- [ ] Least-privilege IAM policies audit

### Phase 5 — Production Readiness
- [ ] Multi-AZ RDS
- [ ] ECS auto-scaling policies
- [ ] Blue/green deployment strategy
- [ ] Route 53 DNS cutover plan
- [ ] Load testing and capacity planning
- [ ] Disaster recovery / backup validation

---

## Environment Configuration

The application uses Spring profiles to switch databases:

| Profile | Database | Connection Properties |
|---------|----------|-----------------------|
| (default) | H2 (embedded) | Auto-configured |
| `mysql` | MySQL | `MYSQL_URL`, `MYSQL_USER`, `MYSQL_PASS` |
| `postgres` | PostgreSQL | `POSTGRES_URL`, `POSTGRES_USER`, `POSTGRES_PASS` |

For AWS deployment, the `postgres` profile is activated via the `SPRING_PROFILES_ACTIVE` environment variable in the ECS task definition.

---

## Cost Estimate (dev environment)

| Resource | Spec | Estimated Monthly Cost |
|----------|------|------------------------|
| ECS Fargate | 0.5 vCPU, 1 GB (x2 tasks) | ~$30 |
| RDS PostgreSQL | db.t3.micro, 20 GB | ~$15 |
| ALB | 1 LCU average | ~$22 |
| NAT Gateway | 1 gateway + data | ~$35 |
| ECR | < 1 GB storage | ~$0.10 |
| CloudWatch | Logs + metrics | ~$5 |
| **Total** | | **~$107/month** |

> Costs are approximate for `ap-northeast-1`. Actual costs depend on traffic and usage patterns.
