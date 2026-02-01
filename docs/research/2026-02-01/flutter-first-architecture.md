# Flutter-first architecture (Memo) — benchmarked against Moodiary

Director decision: **Flutter-first** (iOS/Android priority; desktop + web later). Benchmark remains Moodiary: <https://github.com/ZhuJHua/moodiary>

This doc proposes a pragmatic, scalable Flutter architecture that (a) reaches Moodiary feature parity fast, and (b) leaves room for a future SaaS sync backend without rewriting the app.

---

## 1) Target properties (what “good” looks like)

### Product
- **Fast journaling loop**: open → create entry → attach media → search/filter → revisit.
- **Offline-first** by default.
- **Privacy-first** defaults (lock + optional encryption, clear AI boundaries).

### Engineering
- Clear separation between:
  - UI/state
  - domain use-cases
  - persistence (DB + file store)
  - sync engine
- Easy to add platforms (desktop/web) without redoing core logic.

---

## 2) Repo layout (recommended)

Keep this repo; add Flutter app(s) in-repo.

```
/apps
  /mobile                 # Flutter app (iOS/Android first)
/packages
  /core                   # shared domain, services, sync engine, models
  /ui                     # design system, reusable widgets (optional)
  /plugins                # platform abstractions (files, biometrics, etc.) (optional)
/docs
```

Why: Moodiary is a single Flutter app repo; that’s fine early. Memo can stay simple but still isolate core logic so desktop/web can reuse it.

---

## 3) Feature modules (vertical slices)

Use feature-first folders inside the app and keep domain objects in `packages/core`.

Example:
```
/apps/mobile/lib
  /app                    # app shell, routing, theme, bootstrap
  /features
    /journal              # create/edit/view entry, editor modes
    /search               # search UX, filters
    /attachments          # image/audio/video/drawing
    /categories_tags
    /calendar_timeline
    /map_trail
    /backup_sync
    /security_lock
    /assistant_ai
  /shared
    /widgets
    /formatting
    /localization
```

Moodiary has many capabilities (editors, media, map, sync). A feature-first structure prevents “utils sprawl” as parity grows.

---

## 4) State management + navigation (recommendation)

Moodiary uses **GetX**. For Memo, pick one approach and standardize.

### Recommendation
- **Riverpod** (or `flutter_riverpod`) for state + DI
- **go_router** for routing

Why:
- Testability and modularity are strong.
- Works well with feature modules.

Alternative (if we want maximal speed initially):
- Keep it simple with **GetX** to mirror Moodiary’s patterns.

Decision rule:
- If we expect multi-team scaling and deeper sync complexity → Riverpod.
- If we want fastest parity shipping with fewer abstractions → GetX.

---

## 5) Domain-driven layers (minimal, not academic)

### UI layer
- View widgets + controllers/notifiers.
- No direct DB/sync calls.

### Domain layer (in `packages/core`)
- Entities: `Entry`, `Attachment`, `Tag`, `Category`, `LocationPoint`.
- Use-cases: `CreateEntry`, `UpdateEntry`, `SearchEntries`, `SyncNow`.

### Data layer
- Repositories:
  - `EntryRepository` (DB)
  - `AttachmentRepository` (file store + metadata)
  - `SyncRepository` (remote adapter)

### Infrastructure
- DB impl (Isar/Drift)
- file storage impl
- WebDAV/S3/Supabase adapters later

---

## 6) Cross-cutting systems we must design early

### 6.1 File store (attachments)
Moodiary stores media in per-entry folders and syncs them via WebDAV.

Memo should adopt:
- `attachments/<entryId>/<attachmentId>.<ext>`
- `thumbnails/<entryId>/<attachmentId>.jpg` (for videos/images)
- Keep metadata in DB (type, size, checksum, createdAt).

### 6.2 Encryption
Moodiary supports encrypted WebDAV diary payloads (`.bin` vs `.json`).

Memo should plan for:
- **Local encryption** (optional) for DB and/or exported archives.
- **Sync encryption** (optional) where remote stores ciphertext.

Design note:
- Do not invent crypto. Prefer libsodium-compatible primitives or well-reviewed Dart packages.

### 6.3 Sync engine boundaries
Sync must be a first-class module (not “some util file”). Moodiary’s code shows the cost of evolving from util → abstraction mid-stream.

Memo should implement:
- a single sync engine interface from day 1
- multiple adapters later (WebDAV first if needed; cloud later)

---

## 7) Platform plan (phased)

Phase 1:
- iOS/Android app shell + local DB + editor + attachments + search + map.

Phase 2:
- Desktop wrappers: focus on keyboard UX, drag/drop attachments.

Phase 3:
- Web: only if necessary; Flutter web storage + file APIs vary.

---

## 8) Parity drivers to mirror from Moodiary

From code scan:
- Moodiary has multiple editor modes, media attachments, WebDAV sync with incremental sync map, encryption option, map trail.

Memo should prioritize the same “sticky” drivers:
1) **Editor delight** (markdown + rich text later)
2) **Attachments** (images first)
3) **Map/trail** (clusters + filters)
4) **Reliable sync/backup** (WebDAV or cloud)
5) **Security lock**
