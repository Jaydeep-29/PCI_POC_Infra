# PCI-DSS 1.3.1 / 1.3.2 – AWS POC (Terraform)

This POC addresses the audit findings:
- **1.3.1 (Inbound)**: only required inbound traffic is allowed to reach the CDE.
- **1.3.2 (Outbound)**: only required outbound traffic is allowed from the CDE.

## What this builds
- New VPC with:
  - **2 public subnets** (ALB requirement)
  - **2 private subnets** (app + db)
  - Internet Gateway + **NAT Gateway**
- **ALB (internet-facing)** with HTTPS listener and finite IP allow-list
- **EC2 app instance** (private subnet, no public IP)
- **EC2 MySQL instance** (private subnet, no public IP)
- Security Groups implementing inbound/outbound restrictions

## Why outbound to 0.0.0.0/0:443 exists
The app must reach `secureweb.com` (daily ops) and `example.com` (bootstrap package).
Security Groups cannot enforce FQDN rules (domain-based allow-listing), so the POC limits
egress to **TCP/443 only** (+ DNS). In discussion, propose final hardening via:
- AWS Network Firewall (and/or) egress proxy + allow-listing + logging.

## Inputs you must provide
- `allowed_inbound_ips`: finite allow-list CIDRs (example: ["203.0.113.10/32"])
- `acm_certificate_arn`: ACM cert for HTTPS listener (same region)

## Run
```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Validate (quick)
- App & DB instances: **no public IPs**
- ALB: only reachable from allow-listed IPs
- App can resolve DNS and reach HTTPS (secureweb.com)
- DB accepts 3306 only from the app security group

## Files
- `main.tf`: infra resources
- `user_data/`: bootstrap scripts
- `docs/diagram.png`: simple architecture diagram
- `docs/discussion-notes.md`: “5-day audit” alternatives & talking points
