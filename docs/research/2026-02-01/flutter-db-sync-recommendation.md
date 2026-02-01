# Flutter DB + Sync recommendation (Memo) — benchmarked against Moodiary

Benchmark: Moodiary <https://github.com/ZhuJHua/moodiary>

Moodiary stack signals:
- Local DB: **Isar**
- Sync: **WebDAV** (incremental via a `sync.json` map + tombstones)
- Optional encryption for synced diary payloads

This doc recommends a DB choice and a sync model that can start local-only and later support SaaS.

---

## 1) Local DB: options and recommendation

### Option A — Isar (recommended)
Pros:
- Very fast local queries; good for timeline/search.
- Moodiary uses it → parity-friendly mental model.
- Strong for mobile/desktop.

Cons:
- Web support historically limited/complex (depends on Isar version/runtime).

### Option B — Drift (SQLite)
Pros:
- Rock-solid, SQL, migrations are mature.
- Easy to reason about for sync (explicit schema).
- Web can work (via sqlite wasm) but adds complexity.

Cons:
- Performance + DX depends on schema/indexing choices.

### Option C — Realm
Pros:
- Sync story exists (Atlas Device Sync historically), but licensing/product direction may be a constraint.

Recommendation:
- **Isar for Phase 1**, because parity target is Moodiary and we want speed + offline performance.
- Add a repository abstraction so we can move to SQLite later if web becomes critical.

---

## 2) Data model (minimum for parity)

### Core entities
- `Entry`
  - `id` (UUID)
  - `createdAt`, `updatedAt`
  - `deletedAt` (tombstone)
  - `title`, `body`
  - `editorType` (plain/markdown/rich)
  - `mood` (enum or 0..N)
  - `location` (lat/lng + label)
  - `categoryId` (nullable)
  - `tagIds` (many-to-many)
  - `attachmentIds` (one-to-many)
  - `revision` (int) optional for conflict handling

- `Attachment`
  - `id`, `entryId`
  - `type` (image/audio/video/drawing)
  - `path` (local path)
  - `mime`, `size`, `checksum`
  - `createdAt`, `deletedAt`

- `Category`, `Tag`

### Why tombstones matter
Moodiary’s WebDAV sync uses string values like `"delete"` in the sync map. Memo should make deletion explicit with `deletedAt` so:
- conflicts are resolvable
- incremental sync is stable

---

## 3) Sync model (do this once, do it right)

### 3.1 Sync invariants
- Every object has a stable `id`.
- Every mutation updates `updatedAt`.
- Deletion sets `deletedAt` (no hard deletes until compaction).

### 3.2 Incremental sync approach (Moodiary-inspired)
Moodiary uses:
- `sync.json`: `{ entryId -> lastModifiedIso | "delete" }`

Memo v1 equivalent:
- A **remote index** mapping object IDs to their latest revision state.
- A **manifest per entry** that enumerates attachments + checksums.

Suggested remote artifacts (WebDAV-style):
- `/entries/<entryId>.json` (or `.bin` encrypted)
- `/manifests/<entryId>.json` (attachments list + checksums)
- `/attachments/<entryId>/<attachmentId>.<ext>`
- `/index/sync.json` (map of entryId -> updatedAt or delete tombstone)

This supports:
- download missing/newer entries
- upload local newer entries
- garbage collection of deleted entries and removed attachments

### 3.3 Conflict strategy (explicit)
Start with:
- **Last-write-wins** at entry level (based on `updatedAt`),
- but record `previousUpdatedAt` to detect “true conflict”.

If conflict detected:
- keep both: create a “conflict copy” entry and notify user.

### 3.4 Encryption (optional but planned)
Moodiary:
- encrypt diary JSON -> `.bin` on WebDAV when enabled.

Memo:
- allow “encrypt payload before upload” using a user key.
- derive per-entry keys using HKDF(salt = entryId).
- store only ciphertext remotely.

---

## 4) Remote adapter choices

### WebDAV (fastest parity)
Pros:
- Matches Moodiary’s user expectations.
- Easy backup story; many users already have Nextcloud.

Cons:
- Harder to provide collaborative features; performance varies by server.

### SaaS backend (later)
- Build the same sync engine with a different adapter.
- Keep the on-disk manifest/index semantics so exports remain portable.

---

## 5) What to implement first (engineering plan)

1) Define core models + repository interfaces in `packages/core`.
2) Implement Isar repositories + file store.
3) Implement sync engine with a “NullRemote” adapter for local-only testing.
4) Implement WebDAV adapter (if parity demands it in Phase 1).
5) Add encryption option last (after correctness).

---

## 6) Quality metrics (non-negotiable)
- Sync success rate
- Conflict rate
- Mean sync time for N=100, 1k entries
- Export/import success rate (with media)
