# NAuTILUS scripts

## GitHub Pages + custom domain (nautilus.terpedia.com)

1. **Publish site and enable custom domain (gh)**  
   From repo root:
   ```bash
   chmod +x scripts/setup-github-pages.sh
   ./scripts/setup-github-pages.sh
   ```
   - Initializes git (if needed), commits, creates GitHub repo (if needed), pushes.
   - Enables GitHub Pages from branch `main`, folder `/docs`.
   - Sets custom domain to **nautilus.terpedia.com** and enforces HTTPS.

2. **Point DNS at GitHub (Route 53)**  
   From repo root:
   ```bash
   chmod +x scripts/setup-route53-nautilus.sh
   ./scripts/setup-route53-nautilus.sh
   ```
   - Creates CNAME **nautilus.terpedia.com** → **&lt;owner&gt;.github.io** in the **terpedia.com** hosted zone.
   - Requires AWS CLI and a Route 53 hosted zone for terpedia.com.
   - Optional: `GITHUB_OWNER=YourOrg ./scripts/setup-route53-nautilus.sh`

Manual Route 53 steps and troubleshooting: [docs/setup/ROUTE53-NAUTILUS.md](../docs/setup/ROUTE53-NAUTILUS.md).
