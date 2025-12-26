# Discussion Notes (audit in 5 days)

## What failed in the initial setup
- Inbound: reachable from anywhere (0.0.0.0/0 on port 80).
- Outbound: default allow-all egress from CDE components.

## POC controls implemented
### PCI 1.3.1 (Inbound)
- Only the ALB is internet-facing.
- ALB inbound is restricted to a finite allow-list of client IPs (CIDRs).
- App EC2 inbound only from ALB security group.
- DB inbound only from app security group.

### PCI 1.3.2 (Outbound)
- App egress is limited to:
  - DNS to VPC CIDR
  - TCP/443 (required for secureweb.com and example.com bootstrap)
  - TCP/3306 to DB SG
- DB egress is limited to DNS within VPC only.

## Limitation (and how to answer it)
Security groups cannot allow by FQDN/domain (secureweb.com). For the POC, allow TCP/443
and explain the next-step hardening.

## If final solution takes longer than 5 days (fastest path)
- Keep CDE private (no public IPs), enforce strict SGs, and ship the change record.
- Add AWS Network Firewall in the egress path with deny-by-default policy and allow rules.
- Alternatively: central egress proxy with allow-listing and logging (org dependent).
