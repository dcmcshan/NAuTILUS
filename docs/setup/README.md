# NAuTILUS site setup

## nautilus.terpedia.com (GitHub Pages + Route 53)

- **GitHub:** Repo and GitHub Pages are set up. The site is built from the **main** branch, **/docs** folder. Custom domain **nautilus.terpedia.com** is configured.
- **Live (before DNS):** https://Terpedia.github.io/NAuTILUS/
- **After DNS:** https://nautilus.terpedia.com (once Route 53 points the subdomain to GitHub).

### What you need to do

1. **Route 53**  
   In the AWS account that has the **terpedia.com** hosted zone, create a CNAME:
   - **Name:** nautilus.terpedia.com (or `nautilus` in the terpedia.com zone)
   - **Value:** Terpedia.github.io  

   From this repo:
   ```bash
   ./scripts/setup-route53-nautilus.sh
   ```
   Or follow [ROUTE53-NAUTILUS.md](./ROUTE53-NAUTILUS.md) (console or CLI).

2. **HTTPS**  
   After DNS propagates, in the repo **Settings → Pages** turn on **Enforce HTTPS** (GitHub will issue the certificate once it can verify the domain).

**Note:** The repo is under the **Terpedia** org. GitHub Pages is served from **Terpedia.github.io/NAuTILUS/**. The CNAME target for nautilus.terpedia.com must be **Terpedia.github.io**. If you previously pointed DNS to a user account, re-run `./scripts/setup-route53-nautilus.sh` to update the record (it uses the repo owner automatically).
