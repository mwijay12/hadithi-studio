# Hadithi Studio landing page

A separate Vite/React marketing website. It does not replace the Flutter app or provide a web reader. Existing app artwork is copied into `public/images` for a standalone deploy.

```sh
cd website
npm ci
npm run dev
npm run build
```

For Vercel, set the project root to `website`, framework preset to Vite, and output directory to `dist`. The browser reader is not available yet; the page intentionally does not link to an unfinished app or collect visitor data. Validate the content and privacy wording before a public launch.
