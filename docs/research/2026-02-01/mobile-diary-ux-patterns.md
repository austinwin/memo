# Mobile diary UX patterns (Flutter-first Memo)

Context: Director pivoted to **mobile-first Flutter**. Benchmark: Moodiary (<https://github.com/ZhuJHua/moodiary>)

This doc focuses on proven mobile diary UX patterns and what we should copy/avoid to beat Moodiary’s day-to-day flows.

---

## 1) The “core loop” (optimize relentlessly)

**Open → create entry → enrich (mood/tags/media) → save → later find it**

Mobile UX principles:
- One-thumb primary actions (bottom-aligned)
- Minimal friction to start writing
- Strong “I can find this later” affordances (tags/category/mood are fast)

Design targets:
- Time-to-first-entry (TTFE) < 30–60s
- “New entry” reachable in 1 tap from anywhere

---

## 2) Navigation patterns that work for diaries

### 2.1 Bottom navigation (Moodiary uses it)
Moodiary has a bottom nav bar on mobile and a rail on desktop (`HomeNavigatorBar`). Tabs include Diary/Calendar/Media/Settings.

Recommendation for Memo:
- Bottom nav with 3–5 destinations:
  - **Journal** (timeline)
  - **Calendar**
  - **Media**
  - **Search** (optional; could be a modal instead)
  - **Settings**

### 2.2 Floating “New entry” FAB (Moodiary expands FAB)
Moodiary’s FAB expands to choose editor type (markdown/plain/rich).

Recommendation:
- Keep a single FAB for “New entry”.
- If we offer multiple editors, use a **long-press or expand sheet**:
  - New: Plain
  - New: Markdown
  - New: Rich text (later)

Avoid:
- Making editor choice a blocker; default should be last-used.

---

## 3) Calendar UX (Moodiary’s strongest mobile flow)

Moodiary calendar page does two clever things:
1) **Heatmap-like day coloring** based on number of entries per day (0..5+) using interpolated color.
2) Selecting a date scrolls/jumps the list of entries for that month.

Patterns to adopt:
- Calendar with activity heatmap (small but sticky)
- Tap day → shows entries (list) immediately
- Month switch that keeps context (jump to most recent day with entries)

Memo enhancements to beat Moodiary:
- Date range filter (week/month)
- Quick filters: mood/tag/category chips above the list
- “On this day” resurfacing (optional)

---

## 4) Media hub UX (Moodiary’s other sticky flow)

Moodiary has a dedicated **Media** page:
- Filter by **media type** (image/audio/video)
- Jump by **date picker** to days that contain media
- Grouped by date in a scrollable list
- Has a utility action: “clean useless files”

Patterns to adopt:
- Media hub is not optional; it’s how users recall moments.
- Group by date; provide type toggles.
- Provide “jump to date” affordance.

Memo enhancements to beat Moodiary:
- Media search (by tag/category)
- “Show entry” deep-link from any media item
- Offline-first thumbnails and lazy loading
- File cleanup as an integrity feature (detect orphaned attachments)

---

## 5) Categories/tags UX (Moodiary’s approach)

Moodiary’s journal timeline uses:
- **TabBar**: “All” + one tab per category (scrollable)
- A category choice bottom sheet (menu icon)
- Full category manager page (add/edit/delete)

Patterns to adopt:
- Categories as top-level views can be fast and satisfying.
- BUT: too many categories makes TabBar unwieldy.

Recommendation for Memo:
- Keep **Tags** as primary lightweight organization.
- Keep **Categories** as optional higher-level grouping.
- If categories exceed N (e.g., 6–8), switch to:
  - “All” + “Categories” tab that opens a sheet/list
  - or a segmented control + category picker

Memo enhancements to beat Moodiary:
- Saved views (e.g., tag+mood+date filters)
- Pinned categories/saved views

---

## 6) Entry composition UX (mobile-first)

Make entry composition delightful:
- Large, comfortable text area
- Visible timestamp editing (calendar/time picker)
- Fast add mood (one tap)
- Fast add tags (typeahead)
- Attachment row: camera, photo, audio record, drawing

Avoid:
- Deep nested settings during writing.

---

## 7) Offline-first UX patterns (user-facing)

Users need confidence:
- Subtle “Saved locally” state
- Sync indicator that doesn’t feel scary
- Clear errors only when action is needed

Moodiary shows a sync icon and a syncing indicator.

Memo should:
- Show small status in app bar: Offline / Syncing / Synced
- Provide a Sync dashboard with last sync time, queued ops, errors

---

## 8) UX parity priorities vs Moodiary (mobile)

P0 parity flows:
- Journal timeline + fast create entry
- Calendar heatmap + date-to-entries
- Media hub (images at least)
- Categories/tags management

P1 to beat:
- Search/saved views
- Media deep-linking to entries
- Better offline/sync transparency
