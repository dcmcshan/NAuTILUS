#!/usr/bin/env bash
# Create Route 53 CNAME record: nautilus.terpedia.com -> <owner>.github.io
# Requires: AWS CLI configured (aws route53 list-hosted-zones, change-resource-record-sets)
# Run from repo root: ./scripts/setup-route53-nautilus.sh
# Optional: GITHUB_OWNER=YourOrg ./scripts/setup-route53-nautilus.sh

set -e
cd "$(dirname "$0")/.."

SUBDOMAIN="${SUBDOMAIN:-nautilus}"
PARENT_DOMAIN="${PARENT_DOMAIN:-terpedia.com}"
FQDN="${SUBDOMAIN}.${PARENT_DOMAIN}"

# GitHub Pages target for project sites: owner.github.io (use repo owner so org repos get org.github.io)
if [[ -n "$GITHUB_OWNER" ]]; then
  TARGET="$GITHUB_OWNER.github.io"
else
  TARGET="$(gh repo view --json owner -q .owner.login 2>/dev/null || gh api user -q .login 2>/dev/null || true).github.io"
fi
if [[ -z "$TARGET" ]]; then
  echo "Set GITHUB_OWNER (e.g. your GitHub username or org), or run 'gh auth login'"
  exit 1
fi

echo "=== Route 53: $FQDN -> $TARGET ==="

# Find hosted zone for terpedia.com
ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='${PARENT_DOMAIN}.'].Id" --output text 2>/dev/null | head -1)
if [[ -z "$ZONE_ID" ]]; then
  echo "No Route 53 hosted zone found for $PARENT_DOMAIN. Create one in the AWS console or set PARENT_DOMAIN."
  exit 1
fi
# Strip /hostedzone/ prefix if present for change batch
ZONE_ID="${ZONE_ID#/hostedzones/}"

# Create CNAME change batch
TMP=$(mktemp)
cat > "$TMP" << EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${FQDN}.",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{"Value": "${TARGET}."}]
      }
    }
  ]
}
EOF

echo "Creating CNAME record in zone $ZONE_ID..."
aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" --change-batch "file://$TMP"
rm -f "$TMP"

echo "Done. Allow a few minutes for DNS propagation, then enable HTTPS in repo Settings → Pages for $FQDN."
