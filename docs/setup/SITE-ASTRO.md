# NAuTILUS site — Astro

The live site at **nautilus.terpedia.com** is built with **Astro** (not Jekyll). Source lives in **site/**.

## Build and publish

```bash
cd site
npm install
npm run build
```

The build writes into **docs/** (GitHub Pages source). Commit and push `docs/` to publish.

## Local preview

```bash
cd site
npm run dev
```

Open the URL shown (e.g. http://localhost:4321/NAuTILUS/).

## Editing content

- **Home, results:** `site/src/pages/index.astro`, `site/src/pages/results.astro`
- **Proposal docs:** `site/src/content/docs/*.md` (markdown)
- **Layout / global styles:** `site/src/layouts/BaseLayout.astro`, `site/src/styles/global.css`
- **Header, footer:** `site/src/components/Header.astro`, `site/src/components/Footer.astro`

See **site/README.md** for more.
