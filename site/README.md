# NAuTILUS site (Astro)

The [nautilus.terpedia.com](https://nautilus.terpedia.com) site is built with **Astro** and output to `../docs` for GitHub Pages.

## Setup

```bash
cd site
npm install
```

## Develop

```bash
npm run dev
```

Open http://localhost:4321/NAuTILUS/ (or the URL Astro prints).

## Build (publish to GitHub Pages)

```bash
npm run build
```

This writes static files into **../docs**. Commit and push `docs/` to publish.

- **CNAME** and **.nojekyll** are in `public/` and are copied into `docs/` on build.
- Proposal docs live in `src/content/docs/` (markdown). Edit there and rebuild to update the site.

**First-time switch from Jekyll:** The build adds `index.html`, `results/`, doc pages, and `_astro/` to `docs/`. To avoid serving both old `.md` and new HTML, remove the previous Jekyll files from `docs/` (e.g. `index.md`, `results.md`, `_config.yml`, `01-*.md` … `06-*.md`) before or after the first build. The canonical source for proposal content is now `site/src/content/docs/`.
