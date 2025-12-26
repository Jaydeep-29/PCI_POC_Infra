# Fill these and save as terraform.tfvars

# Finite allow-list for inbound to ALB (PCI 1.3.1)
allowed_inbound_ips = ["185.238.220.138/32"]

# ACM certificate for HTTPS listener
acm_certificate_arn = "arn:aws:acm:REGION:ACCOUNT:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Optional
# key_name = "my-keypair"

secureweb_cidrs = ["203.0.113.10/32"]
