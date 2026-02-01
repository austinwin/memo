# Memo: 30/60/90 day roadmap (benchmarking Moodiary)

North Star (proposed): **Weekly Active Journalers (WAJ)** = users who create **≥3 entries/week** (or complete ≥3 “reflection actions”/week).

Assumption: Memo ships **web-first SaaS** (PWA), mobile-friendly, offline-first cache, with optional premium privacy features.

---

## Day 0–30: “Ship the SaaS core” (reliability + onboarding)

### Goal
Cross-device journaling that “just works” with a crisp writing experience.

### Must-ship outcomes
- **Auth + accounts** (magic link or OAuth) + basic billing hooks (even if free).
- **Cloud sync** with offline-first cache + background sync.
- **Entry model v1** stable (id, created_at, updated_at, title/body, mood, tags, location, attachments metadata).
- **Export v1**: JSON export/import that is versioned and includes metadata.

### UX upgrades
- **Editor v1**: plain + **markdown** mode (preview + shortcuts).
- Keyboard shortcuts on desktop; mobile-first quick-entry affordances.
- Search highlighting + filters (tag, mood, date range).

### Engineering / risk reduction
- Pick a **conflict strategy** now (last-write-wins + per-field merge later; surface “conflicts” explicitly).
- Telemetry: sync success rate, time-to-first-entry, WAJ.

### Success criteria
- New user → first entry in <60 seconds.
- Sync works across two devices with <1% error rate in basic flows.

---

## Day 31–60: “Close Moodiary parity where it matters” (attachments + map)

### Goal
Deliver Moodiary-like “minimum bar” features that users feel immediately.

### Must-ship outcomes
- **Attachments v1**: images
  - desktop drag/drop, mobile picker, thumbnails, delete/replace.
  - include in export as a ZIP bundle (or export manifest + media).
- **Map / trail v1**:
  - map view with clusters
  - filters by date range + tag + mood
  - “moments” / “footprints” list tied to map

### QoL
- Saved filters (“Smart views”): e.g., “Work notes”, “Bad days”, “Trips”.
- Better typography + spacing + component consistency (design system pass).

### Success criteria
- ≥30% of WAJs attach at least one image within first 2 weeks.
- Map view used by ≥15% of WAJs weekly.

---

## Day 61–90: “Differentiate” (privacy + AI + portability)

### Goal
Do what Moodiary hints at (AI + privacy) but with a clearer trust model.

### Must-ship outcomes
- **Privacy & lock**:
  - app lock PIN (web) + optional passkey/WebAuthn gate
  - encryption-at-rest server-side (baseline) + optional **client-side encryption** (premium)
- **AI assistant v1 (opt-in)**:
  - “reflect on last week” summaries, tag suggestions, mood trends
  - explicit data-use UX (what’s sent, retention)
  - start with non-sensitive prompts/templates; add full diary-chat later
- **Import expansion**:
  - import from common formats (Markdown folder, Day One JSON if feasible)

### Success criteria
- Paid conversion begins (1–3% early, depending on acquisition quality).
- WAJ retention improves week-over-week.

---

## Notes from Moodiary scan that inform this roadmap
- Moodiary’s WebDAV sync supports **optional encryption** and incremental sync via a `sync.json` flag map. Memo should implement an equivalent concept, but with stronger conflict handling + observability.
- Moodiary’s “trail map” is a retention feature; ship a polished map early.
- Moodiary has AI (Tencent Hunyuan) + local NLP experiments; Memo can differentiate by making privacy UX and consent *excellent*.
