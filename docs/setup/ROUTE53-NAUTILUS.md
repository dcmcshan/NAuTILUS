# Route 53 setup for nautilus.terpedia.com

Point **nautilus.terpedia.com** to your GitHub Pages site using AWS Route 53.

---

## Prerequisites

- **terpedia.com** must be in a Route 53 hosted zone (you have the zone ID).
- AWS CLI configured: `aws sts get-caller-identity` works.
- GitHub Pages is enabled for the NAuTILUS repo and custom domain is set to **nautilus.terpedia.com** in repo **Settings → Pages**.

---

## Option 1: Script (recommended)

From repo root:

```bash
# Use default GitHub user from gh
./scripts/setup-route53-nautilus.sh

# Or set org/owner explicitly
GITHUB_OWNER=YourOrg ./scripts/setup-route53-nautilus.sh
```

The script creates a **CNAME** record:

- **Name:** nautilus.terpedia.com  
- **Value:** `<owner>.github.io`  
- **TTL:** 300  

---

## Option 2: AWS Console

1. Open **Route 53 → Hosted zones** and select the **terpedia.com** zone.
2. **Create record**
   - Record name: `nautilus`
   - Record type: **CNAME**
   - Value: `YOUR_GITHUB_USERNAME.github.io` (or `YourOrg.github.io` for an org repo)
   - TTL: 300
3. **Create records**.

---

## Option 3: AWS CLI by hand

```bash
# Set your GitHub username or org
GITHUB_OWNER=your-username

# List hosted zones and copy the Id for terpedia.com (e.g. Z123...)
aws route53 list-hosted-zones --query "HostedZones[?Name=='terpedia.com.']"

# Create change batch file change.json:
cat > change.json << EOF
{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "nautilus.terpedia.com.",
      "Type": "CNAME",
      "TTL": 300,
      "ResourceRecords": [{"Value": "${GITHUB_OWNER}.github.io."}]
    }
  }]
}
EOF

# Apply (replace ZONE_ID with your hosted zone ID)
aws route53 change-resource-record-sets --hosted-zone-id ZONE_ID --change-batch file://change.json
```

---

## After DNS is set

1. **Propagation:** Wait 5–15 minutes (up to 48 hours in rare cases).
2. **GitHub:** In repo **Settings → Pages**, ensure **Custom domain** is `nautilus.terpedia.com` and **Enforce HTTPS** is checked. GitHub will provision a certificate.
3. **Verify:** Open https://nautilus.terpedia.com — you should see the NAuTILUS research proposal and results index.

---

## Troubleshooting

- **CNAME not resolving:** Confirm the record in Route 53 and that the target is exactly `owner.github.io` (no trailing slash). Use `dig nautilus.terpedia.com` to see what the world resolves.
- **GitHub “Domain’s DNS record is incorrect”:** Ensure the CNAME points to `owner.github.io` (the account that owns the repo), not to `owner.github.io/NAuTILUS`.
- **HTTPS not working:** Wait for GitHub to finish certificate provisioning (often a few minutes after DNS is correct), then re-save the custom domain or enable “Enforce HTTPS” again.
