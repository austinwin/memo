# Moodiary mobile flows: parity analysis + Memo checklist

Benchmark repo: <https://github.com/ZhuJHua/moodiary>

This is a mobile-flow-centric view of parity (calendar/media/categories) using code evidence from Moodiary.

---

## 1) Home navigation (mobile)

**What Moodiary does**
- Bottom navigation bar on mobile (and rail on desktop): Diary / Calendar / Media / Setting.
- Expanding FAB for new entry with editor choices (markdown/plain/rich).

**Memo parity**
- [ ] Bottom nav with these destinations (or equivalent)
- [ ] Global “new entry” button, 1 tap
- [ ] Optional editor type chooser (default to last-used)

---

## 2) Calendar flow

**What Moodiary does (confirmed in `CalendarPage`)**
- Uses `calendar_date_picker2`.
- Highlights only days that contain entries (selectableDayPredicate).
- Day cells are colored by entry count (0..5+) via interpolation.
- Selecting a date triggers scroll animation to that date’s entries.

Key UX details to copy:
- “Activity heatmap” day coloring (low effort, high retention).
- Calendar + list side-by-side on large screens; stacked on mobile.

**Memo parity checklist**
- [ ] Calendar month view
- [ ] Heatmap coloring by entry count
- [ ] Tap day → show entries for that day (or jump to day section)
- [ ] Month change keeps context (jump to last day with entries)

**Memo improvements to beat Moodiary**
- [ ] Quick filters above list (tag/category/mood)
- [ ] Range selection mode (week/month filter)

---

## 3) Media hub flow

**What Moodiary does (confirmed in `MediaPage`)**
- Media hub is a dedicated page.
- Top actions:
  - date picker dialog that only allows selection of dates containing media
  - media type dropdown (image/audio/video)
  - “clean useless files” action
- Body:
  - grouped sections by date
  - per-type components (`MediaImageComponent`, `MediaAudioComponent`, `MediaVideoComponent`)

**Memo parity checklist**
- [ ] Media hub page
- [ ] Media type filter (images P0; audio/video P1)
- [ ] Jump-to-date for days with media
- [ ] Grouped-by-date layout
- [ ] Orphan cleanup (detect attachments not referenced by DB)

**Memo improvements to beat Moodiary**
- [ ] Deep link: tap media → open owning entry
- [ ] Filter media by tag/category/mood/date range

---

## 4) Categories flow

**What Moodiary does**
- Journal page shows a scrollable TabBar:
  - “All” tab + one tab per category.
- A bottom sheet provides category selection.
- Category management is accessible from Settings (`CategoryManagerPage`): add/edit/delete.

Strengths:
- Category switching is 1-tap once set up.

Weakness:
- TabBar can become unwieldy with many categories.

**Memo parity checklist**
- [ ] Categories (CRUD)
- [ ] “All + category views” navigation
- [ ] Category picker sheet for long lists

**Memo improvements to beat Moodiary**
- [ ] Saved views (smart filters)
- [ ] Pin favorite categories/views
- [ ] Fast tag-first UX (tags remain primary)

---

## 5) Summary: what matters most on mobile

If Memo wants to beat Moodiary *on mobile*, we must ship:
1) Calendar heatmap + date-driven browsing
2) Media hub with type toggle + date jump + deep link
3) Categories/tags that feel instant (no waiting, no jank)

And we win if we add:
- better saved views + search
- clearer offline/sync state
- fewer taps to attach media and find it later
