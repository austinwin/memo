# Mobile-first: local DB choice + offline-first design (Flutter)

Director direction: mobile-first Flutter, offline-first, parity vs Moodiary.

This doc is practical: what to build for a diary app where *everything must work offline* and feel fast.

---

## 1) Local DB choice (mobile priority)

### Recommendation: Isar (Phase 1)
Why:
- Moodiary already uses Isar successfully.
- Excellent performance for timeline browsing, full-text-ish queries, and large local datasets.
- Fits an offline-first diary where the device is the source of truth.

Risk / mitigation:
- Web portability can be harder → mitigate by:
  - repository interfaces + DTOs
  - keeping sync engine independent of DB

Alternative if we expect complex migrations + SQL queries:
- Drift (SQLite). More explicit schema control.

---

## 2) Offline-first architecture (how it should work)

### 2.1 Local-first write path
- All user actions write to the local DB immediately.
- UI updates from local DB streams/queries.

### 2.2 Outbox pattern (for sync)
Maintain a local **outbox** table/collection of pending operations:
- `opId`, `entityType`, `entityId`, `opType` (upsert/delete)
- `createdAt`, `attemptCount`, `lastError`

Why:
- resilient to crashes
- deterministic retries

### 2.3 Attachments are files + metadata
- Store attachment metadata in DB.
- Store bytes as files in app directory.
- Consider checksums to detect corruption and enable incremental upload.

---

## 3) Offline-first UX (what users see)

Mobile diary users need confidence:
- Always show subtle status: **Saved** / **Syncing** / **Offline**
- Never block writing due to network
- Sync errors should be non-blocking and actionable

Recommended screens:
- Sync dashboard (like Moodiary’s sync sheet), but include:
  - last sync time
  - queued operations
  - last error + retry

---

## 4) Sync strategy (parity-compatible)

Moodiary’s WebDAV sync uses a remote `sync.json` index (id → timestamp or delete tombstone).

Memo should implement the same conceptual model:
- stable IDs
- updatedAt timestamps
- tombstones (`deletedAt`)
- attachment manifests with checksums

Conflict handling (mobile-appropriate):
- detect true conflicts (remote updated since our last sync)
- keep both copies and notify

---

## 5) Performance constraints (mobile)

Non-negotiables:
- Timeline scroll is smooth at 1k+ entries
- Calendar month view must be instant
- Media hub needs lazy-loading and caching of thumbnails

Implementation notes:
- heavy JSON encode/decode and thumbnail work should run off the UI isolate
- batch DB reads
- precompute day-level aggregates for calendar heatmap (entries/day)

---

## 6) What to build first

P0:
1) Isar schema for Entry/Attachment/Tag/Category + outbox
2) Timeline + create/edit entry
3) Calendar heatmap aggregates
4) Image attachments + Media hub (images)

P1:
- WebDAV adapter (if required early)
- Audio/video attachments
- Encryption options
