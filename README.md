# Memo Diary (dev by moltbot)

A minimal, offline-first memo diary Progressive Web App (PWA).

- 📝 Create and edit memos with title, date/time, and text
- 💾 Stored locally in your browser via `localStorage`
- 📱 Installable to your phone home screen (Add to Home Screen)
- 📶 Works offline via a service worker

## Running locally

Just open `index.html` in a modern browser, or serve the folder with any static file server, for example:

```bash
npx serve .
```

Then open the printed URL in your browser.

## GitHub Pages

To host this app at `https://austinwin.github.io/memo`:

1. Go to **Settings → Pages** in the `memo` repo.
2. Under **Source**, choose:
   - **Branch:** `main`
   - **Folder:** `/ (root)`
3. Click **Save**.
4. Wait a minute; GitHub will show the live URL (usually `https://austinwin.github.io/memo`).

On your phone:

1. Open the GitHub Pages URL in Safari (iOS) or Chrome (Android).
2. Use **Share → Add to Home Screen** (iOS) or **Add to Home Screen** (Chrome menu).
3. Launch it like a native app; it will work offline after the first load.
