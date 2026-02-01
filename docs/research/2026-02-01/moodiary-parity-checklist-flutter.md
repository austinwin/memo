# Moodiary parity checklist (Flutter-first Memo)

Benchmark: <https://github.com/ZhuJHua/moodiary>

Purpose: a concrete checklist of what Memo must implement to credibly “beat Moodiary” on feature coverage + polish.

Legend:
- **P0** = required to claim parity
- **P1** = strong differentiator / expected by power users
- **P2** = nice-to-have

---

## A) Core journaling UX

### A1. Create/edit entries
- [ ] (P0) Fast create entry (one tap)
- [ ] (P0) Title + body
- [ ] (P0) Autosave + draft recovery
- [ ] (P1) Templates / prompts
- [ ] (P1) Version history (optional)

### A2. Editor modes
Moodiary: plain + markdown + rich text.
- [ ] (P0) Plain text
- [ ] (P0) Markdown editor with preview
- [ ] (P1) Rich text editor
- [ ] (P1) Keyboard shortcuts (desktop/mobile external keyboard)

### A3. Organization
- [ ] (P0) Tags
- [ ] (P0) Categories (incl. nested categories if feasible)
- [ ] (P1) Saved filters / smart views
- [ ] (P1) Full-text search with highlighting

---

## B) Attachments (media)

Moodiary supports: images, audio, video, drawing.

### B1. Images
- [ ] (P0) Add image from camera/gallery
- [ ] (P0) Thumbnail grid in entry
- [ ] (P1) Compression + resize
- [ ] (P1) Annotate/crop

### B2. Audio
- [ ] (P1) Record audio note
- [ ] (P1) Playback controls

### B3. Video
- [ ] (P1) Attach video
- [ ] (P2) Generate thumbnails

### B4. Drawing
- [ ] (P2) In-app sketch/drawing attachment

---

## C) Map / “trail”

Moodiary: trail map / footprints; uses clustering.
- [ ] (P0) Add location to entry (picker + current location)
- [ ] (P0) Map view of entries
- [ ] (P1) Clusters + filters (date range, tag, mood)
- [ ] (P1) Timeline ↔ map linking

---

## D) Themes + fonts

Moodiary: custom theme, light/dark, custom fonts.
- [ ] (P0) Light/dark
- [ ] (P1) Theme color palettes
- [ ] (P1) Import fonts / font selection

---

## E) Security

Moodiary: password + biometric unlock; encryption in sync.
- [ ] (P0) App lock PIN
- [ ] (P0) Biometric unlock (FaceID/TouchID/Android)
- [ ] (P1) Encrypt local data (DB or export)
- [ ] (P1) Encrypt synced payloads (if sync enabled)

---

## F) Backup / export / import

Moodiary: import/export all data; WebDAV backup.
- [ ] (P0) Export all entries (JSON)
- [ ] (P0) Import JSON (versioned schema)
- [ ] (P1) Export ZIP including media
- [ ] (P1) WebDAV backup/sync
- [ ] (P2) LAN transfer

---

## G) AI assistant + local NLP

Moodiary: Tencent Hunyuan assistant + local TFLite NLP experiments.
- [ ] (P2) AI assistant (opt-in)
- [ ] (P2) Local NLP (on-device sentiment/keyword)

---

## H) Polish / delight
- [ ] (P0) Calendar/timeline view
- [ ] (P0) Smooth scrolling performance with 1k+ entries
- [ ] (P1) Media hub (browse all attachments)
- [ ] (P1) Recycle bin / undo delete
- [ ] (P1) Streaks / stats (optional)

---

## “Beat Moodiary” definition (practical)
Memo wins if:
- parity on P0 items
- ≥3 P1 items shipped with better UX than Moodiary (e.g., search, map filters, export, sync reliability)
- sync/backup + export never surprise users (correctness > breadth)
