# Moodiary benchmark gap analysis (Phase 1)

Benchmark repo: https://github.com/ZhuJHua/moodiary

Decision: **Memo ships PWA web-first SaaS** (fast iteration). Native/wrappers later.

## Moodiary “minimum bar” (from README)
- Cross-platform apps (Flutter)
- Material Design polish
- Multiple editors (markdown/plain/rich)
- Multimedia attachments (pics/audio/video/draw)
- Search + categorization
- Custom themes + custom fonts
- Data security (password + biometric)
- Import/export (all data) + share single entry
- Backup/sync (LAN sync + WebDAV)
- Trail map / footprints
- Intelligent assistant (LLM access) + sentiment analysis
- Local NLP (privacy-forward; experimental)

## Memo baseline (from README)
- Offline-first PWA + localStorage
- Entries: title, datetime, text, mood (3-level), tags
- Pinning; tasks; search/filter/sort
- Writing stats (streak, word counts, daily goal)
- Daily focus
- Map view (Leaflet) + location picker
- Import/export JSON
- Theme toggle

## Gap list (what we must close to beat Moodiary)

### A) UI polish + core journaling UX (highest priority)
1. **Editor upgrades**
   - Add **Markdown** editor mode (preview + shortcuts) and keep plain text.
   - Optional “rich text” later (Phase 2 unless easy).
2. **Delight & ergonomics**
   - Better typography, spacing scale, consistent components, keyboard shortcuts.
   - Mobile-first: bottom nav, one-tap new entry, quick mood/tag chips.
3. **Search quality**
   - Full-text search is already present; add **highlighting**, “search within tag”, and saved filters.

### B) Data durability + cross-device (SaaS blockers)
1. **Account + cloud sync**
   - Auth (email magic link or OAuth) + server-side storage.
   - Offline-first sync model (local cache + background sync).
2. **Backup/export**
   - Export should include **media attachments** and be versioned.
   - Provide encrypted export option (password-protected zip) later.

### C) Multimedia (feature parity)
1. Attachments per entry:
   - Images first (drag/drop + mobile picker)
   - Audio notes (record)
   - Video (upload)
   - Drawing/sketch (canvas) (optional)

### D) Security
1. Web equivalent of “password/biometric”:
   - App lock PIN + optional WebAuthn/passkey gate.
   - Encryption-at-rest for server data (KMS) + client-side encryption later.

### E) Trail map
- Memo already has a map view. To beat Moodiary:
  - Improve map UX (clusters, filters by tag/mood, date range)
  - “Footprints timeline” polish

### F) AI assistant (Phase 1.5 / Phase 2)
- Start with **local-only** features: prompts, reflection templates, sentiment on-device (where possible).
- Cloud LLM features behind explicit opt-in + privacy policy.

## Proposed Phase 1 execution order (PWA-first)
1. **SaaS foundation**: auth + hosted storage + basic sync (must-have to call it SaaS)
2. **UI polish sprint**: new nav + editor improvements + consistent design system
3. **Attachments v1**: images
4. **Advanced search + organization**: highlights, saved filters, better tagging
5. **Map delight**: clusters + filters + smoother timeline

## “Beating” definition (Phase 1)
We win if:
- Time-to-first-entry < 60 seconds
- Sync works reliably across devices
- UI looks modern and feels faster than Moodiary
- We match core parity: attachments (images) + improved editor + strong search + polished map
