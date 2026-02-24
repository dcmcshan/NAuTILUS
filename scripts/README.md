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
   The **terpedia.com** zone is managed with the **dan-syzygyx** AWS profile. From repo root:
   ```bash
   chmod +x scripts/setup-route53-nautilus.sh
   AWS_PROFILE=dan-syzygyx ./scripts/setup-route53-nautilus.sh
   ```
   - Creates CNAME **nautilus.terpedia.com** → **Terpedia.github.io** in the **terpedia.com** hosted zone.

Manual Route 53 steps and troubleshooting: [docs/setup/ROUTE53-NAUTILUS.md](../docs/setup/ROUTE53-NAUTILUS.md).
