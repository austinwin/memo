# Moodiary repo deep scan (tech + product learnings)

Repo: <https://github.com/ZhuJHua/moodiary>

Scope: code-level scan beyond README to extract (a) what’s truly implemented, (b) where it’s incomplete, and (c) what a web-first SaaS journal (“Memo”) should borrow/avoid.

## 1) What Moodiary *actually* ships (confirmed in code)

### 1.1 Core stack
- **Flutter** app with **GetX** (state) + **Isar** (local DB).
- Hybrid: **Rust** integrated via **flutter_rust_bridge** (`flutter_rust_bridge.yaml`, `rust_builder/`).
- Multi-platform targets: Android/iOS/Desktop.

### 1.2 Storage & domain model
- Local persistence via Isar models (e.g., `Diary`, `Category`).
- Heavy focus on file-based media management (per-entry folders / filenames) alongside DB metadata.

### 1.3 Editors & content types
- Multiple editor experiences implied by dependencies and UI components:
  - `flutter_quill` + `flutter_quill_extensions` (rich text)
  - `flutter_markdown` / `markdown_widget` (markdown)
  - Plain text pathways
- Attachments:
  - Images (`image_picker`, compression)
  - Audio (`record`, `audioplayers`)
  - Video (`video_player`, `chewie`, `fvp`)
  - Drawing (`flutter_drawing_board`)

### 1.4 Sync/backup (WebDAV is real; LAN is mixed)
There are **two distinct WebDAV sync implementations**:

1) **`WebDavUtil` (feature-complete, util style)**
- File: `lib/utils/webdav_util.dart`
- Implements real incremental sync using a `sync.json` flag map:
  - server map: `{ diaryId -> ISO8601 timestamp | "delete" }`
  - download when server has diary ID missing locally or newer timestamp
  - upload when local is newer or missing on server
  - supports **optional encryption** for diary payloads (`.bin` vs `.json`)
  - uploads/deletes attachments + thumbnails

2) **`SyncService` + `WebdavSyncServiceImpl` (new abstraction, incomplete)**
- Files: `lib/services/sync/sync.dart`, `lib/services/sync/impl/webdav_impl.dart`
- Many methods are explicitly `Unimplemented` or return “未实现”.
- Strong signal: codebase is mid-refactor to a cleaner sync abstraction.

LAN sync:
- Pubspec includes `shelf` / `shelf_multipart` (Dart HTTP server).
- There is also a **separate Ktor server** module under `server/` (Kotlin/Netty).
  - Currently looks like **skeleton/placeholder** (routing returns `Hello World`).

### 1.5 Security primitives (implemented)
- Local auth: `local_auth` for biometrics.
- Encryption:
  - `encrypt` package + app utilities show **AES-GCM** support in changelog.
  - Secure key storage via `flutter_secure_storage` and `SecureStorageUtil` usage in WebDAV encryption flow.
- WebDAV encrypted diary sync:
  - If enabled, diary JSON is encrypted → `.bin` uploaded.
  - Key derivation appears to use diary ID as salt + a user key from secure storage.

### 1.6 AI assistant (implemented) + local NLP (partial)
- **Cloud LLM**: Tencent **Hunyuan** API integration.
  - Files: `lib/api/api.dart`, `lib/utils/signature_util.dart`, `lib/pages/assistant/*`
  - Supports model selection: `hunyuan-lite/standard/pro/turbo`
  - Uses streaming responses; app builds chat transcript UI.
- **Local NLP**:
  - README describes MobileBERT SQuAD.
  - Code references TFLite model path: `assets/tflite/model_quant.tflite`.

### 1.7 Map / “trail”
- Uses `flutter_map` + caching + clustering.
- This is a notable “delight” differentiator vs simple map pinning.

### 1.8 Performance / export
- Changelog notes **Rust zip export** to increase export speed.
- Video backend moving to ffmpeg (changelog).

## 2) Where Moodiary is weak / incomplete (opportunities)

### 2.1 Sync system fragmentation
- The “new” sync service abstraction exists but is incomplete.
- The “old” WebDAV util is feature-complete but tightly coupled to app internals.

Opportunity for Memo:
- Ship **one** sync model end-to-end (offline-first + conflict strategy + auditability) and make it boring/reliable.

### 2.2 Server-side story is not cohesive
- Ktor server module exists but is skeletal.
- LAN sync is implied, but the repo does not read like a stable, supported “self-hosted sync server” product.

Opportunity for Memo:
- If Memo is SaaS, lean into a simple hosted sync.
- If you later add “self-host”, make it a first-class, documented product (Docker, migrations, backups).

### 2.3 AI is featureful but privacy-sensitive
- Cloud LLM is integrated (good UX), but diary apps face high privacy scrutiny.

Opportunity for Memo:
- Default posture: **privacy-first + opt-in** for cloud AI.
- Provide “local-only” insights first (lightweight sentiment, prompts) and clear data boundaries.

## 3) “Steal this” list for Memo (pragmatic borrowings)

1) **Sync flag map concept** (entry-id → modified timestamp / delete tombstone)
   - Simple, debuggable, works for incremental sync.
2) **Encrypted sync payload** option (client-side) as a premium/privacy upsell.
3) **Attachment folder strategy** (entry-scoped folders) for export/import portability.
4) **Trail map polish**: clusters + filters + time range is a strong retention lever.
5) **Multiple editor modes** (at least plain + markdown) — meet users where they are.

## 4) “Avoid this” list for Memo

- Shipping two competing sync systems for long.
- Under-documented server modules that imply capabilities users can’t actually rely on.
- AI features without an explicit permissioning + privacy UX.

## 5) Implications for Memo’s product plan

If Memo is web-first SaaS:
- Beat Moodiary by being **faster to ship**, **cleaner UX**, and **more reliable cross-device**.
- Moodiary’s strength is *native breadth* (media + system integrations). Memo’s edge should be:
  - instant onboarding
  - sync that never surprises
  - modern UI
  - export portability
  - privacy posture users can understand
