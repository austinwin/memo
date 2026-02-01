# Memo Diary

A minimal, offline-first memo diary Progressive Web App (PWA).

## ✨ Features

- 📝 **Create & Edit Memos**: Title, date/time, text, mood, location, and task status
- 📌 **Pin Important Entries**: Pin/unpin memos for quick access
- ✅ **Task Tracking**: Mark memos as tasks, check off when done, view open tasks
- 🏷️ **Tags**: Add lightweight tags to entries and filter your log by tag (e.g. marketing, product, ops)
- 📅 **Writing Stats**: Streak, last entry, week count, word counts, daily goal progress
- 🎯 **Daily Goal**: Set a daily writing goal and see progress
- 🔍 **Search & Filter**: Search by text, filter by mood, sort by date/title
- 🗺️ **Map View**: Visualize memos with locations on an interactive map (Leaflet)
- 📍 **Location Picker**: Add/edit location with symbol and label, use current location
- 📤 **Export/Import**: Backup all memos to JSON, restore or merge backups
- 📱 **Installable PWA**: Add to home screen, works offline via service worker
- 🔄 **Sync & Recovery**: Import/export for device migration or manual backup
- 🖥️ **Responsive UI**: Mobile-first, works on desktop and mobile browsers

## 🗂️ App Structure

```
memo/
├── index.html          # Main HTML, links to src/main.js
├── styles.css          # App styles
├── service-worker.js   # Offline support
├── src/
│   ├── main.js         # Entry point, wires modules and events
│   ├── config/
│   │   └── constants.js    # Storage keys, settings, pagination
│   ├── modules/
│   │   ├── MemoManager.js  # Sorting, filtering, stats, timeline logic
│   │   ├── MapManager.js   # Map rendering, location picker
│   │   └── PWA.js          # Service worker, install prompt
│   ├── services/
│   │   └── Storage.js      # LocalStorage, import/export
│   ├── ui/
│   │   ├── Renderer.js     # DOM rendering, pagination, stats
│   │   └── Toast.js        # Toast notifications
│   └── utils/
│       ├── date.js         # Date formatting helpers
│       └── helpers.js      # Word count, mobile view
```

## 🛠️ How to Extend

- **Add a new feature/view**:
  - Add pure logic to `src/modules/` (e.g., filtering, sorting, stats)
  - Add UI rendering to `src/ui/Renderer.js` or a new UI module
  - Wire up events in `src/main.js` (bind DOM, update state, call render)
- **Add a new config/setting**:
  - Define in `src/config/constants.js`
  - Use in relevant modules/services
- **Add a new service (e.g., sync, cloud)**:
  - Create a new file in `src/services/`
  - Import and use in `src/main.js`
- **Add a new UI component**:
  - Create in `src/ui/`
  - Use in `Renderer.js` or main entry
- **Add a new utility/helper**:
  - Place in `src/utils/`
  - Import where needed

### Example: Add a "Tags" Feature
1. Add tag logic to `MemoManager.js` (parse, filter, group)
2. Add tag UI to `Renderer.js` (render tags, filter controls)
3. Update `main.js` to handle tag events and state
4. Update `Storage.js` to persist tags

## 🚀 Running Locally

Open `index.html` in a modern browser, or serve with any static file server:

```bash
npx serve .
```

## 🌐 Deploying to GitHub Pages

1. Go to **Settings → Pages** in the repo
2. Set source to `main` branch, root folder
3. Save and wait for the live URL

## 📦 Backup & Restore

- **Export**: Click Export to download all memos as JSON
- **Import**: Click Import to restore or merge a backup
- Data is stored in your browser (`localStorage`)

## 🧩 Technologies
- Vanilla JS (ES Modules)
- Leaflet (Map)
- Service Worker (Offline)
- LocalStorage (Persistence)

## 📝 License
MIT

---

**Contributions welcome!**
