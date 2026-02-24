#!/usr/bin/env bash
# Setup NAuTILUS GitHub repo and GitHub Pages with custom domain nautilus.terpedia.com
# Requires: gh (GitHub CLI) authenticated, git
# Run from repo root: ./scripts/setup-github-pages.sh

set -e
cd "$(dirname "$0")/.."

REPO_NAME="${REPO_NAME:-NAuTILUS}"
CUSTOM_DOMAIN="${CUSTOM_DOMAIN:-nautilus.terpedia.com}"

echo "=== NAuTILUS GitHub + Pages setup ==="
echo "Repo: $REPO_NAME  Custom domain: $CUSTOM_DOMAIN"
echo ""

# Ensure gh is authenticated
if ! gh auth status &>/dev/null; then
  echo "Run: gh auth login"
  exit 1
fi

OWNER=$(gh api user -q .login 2>/dev/null || true)
if [[ -z "$OWNER" ]]; then
  echo "Could not get GitHub username. Is gh authenticated?"
  exit 1
fi
echo "GitHub owner: $OWNER"

# Initialize git if needed
if [[ ! -d .git ]]; then
  git init
  git branch -M main
  echo "Initialized git (branch main)."
fi

# Add all and commit if there are changes
git add -A
if git diff --staged --quiet 2>/dev/null; then
  echo "No staged changes; skipping commit."
else
  git commit -m "Add NAuTILUS docs and GitHub Pages site (nautilus.terpedia.com)"
  echo "Committed."
fi

# Create repo on GitHub if it doesn't exist (no remote or remote not reachable)
if ! git remote get-url origin &>/dev/null; then
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
  echo "Created GitHub repo and pushed."
else
  # Push to origin
  git push -u origin main 2>/dev/null || git push origin main
  echo "Pushed to origin."
fi

# Create Pages site if not exists (POST only accepts source)
echo ""
echo "Enabling GitHub Pages (source: main, /docs)..."
CREATE_JSON=$(mktemp)
cat > "$CREATE_JSON" << 'CREATE'
{"source": {"branch": "main", "path": "/docs"}}
CREATE
gh api "repos/$OWNER/$REPO_NAME/pages" -X POST --input "$CREATE_JSON" 2>/dev/null || true
rm -f "$CREATE_JSON"

# Set custom domain and enforce HTTPS (PUT updates full config)
echo "Setting custom domain: $CUSTOM_DOMAIN"
PUT_JSON=$(mktemp)
cat > "$PUT_JSON" << EOF
{
  "source": {"branch": "main", "path": "/docs"},
  "cname": "$CUSTOM_DOMAIN",
  "https_enforced": true
}
EOF
gh api "repos/$OWNER/$REPO_NAME/pages" -X PUT --input "$PUT_JSON"
rm -f "$PUT_JSON"

echo ""
echo "=== GitHub Pages configured ==="
echo "  Site (after build): https://$OWNER.github.io/$REPO_NAME/"
echo "  Custom domain (after DNS): https://$CUSTOM_DOMAIN"
echo ""
echo "Next: Create DNS record in Route 53 so $CUSTOM_DOMAIN points to $OWNER.github.io"
echo "  Run: ./scripts/setup-route53-nautilus.sh"
echo "  Or see: docs/setup/ROUTE53-NAUTILUS.md"
