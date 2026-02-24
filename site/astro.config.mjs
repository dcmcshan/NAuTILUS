import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  site: 'https://terpedia.com',
  base: '/NAuTILUS',
  trailingSlash: 'always',
  build: {
    outDir: '../docs',
    assets: '_astro',
  },
  vite: {
    build: {
      assetsInlineLimit: 0,
    },
  },
});
