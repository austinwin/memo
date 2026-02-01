# Developer standup

## Today
- Mobile app scaffold exists at `apps/mobile`.
- **DB decision:** Drift (SQLite).

## Shipped (main)
- Added `table_calendar` and implemented **Calendar MVP**:
  - Month view w/ heat + dots
  - Tap day → day entries list → create/edit
- Extended Drift schema for calendar/day browsing:
  - `dayKey` column (yyyy-MM-dd)
  - day-scoped queries + month day-counts
- Added delete UX improvements:
  - Swipe-to-delete on list w/ **Undo snackbar**
  - Delete on detail w/ **Undo snackbar**
- Improved empty state copy.
- `flutter test` passes.

## Next
- Calendar MVP polishing:
  - make day list open detail (not editor) and add an Edit affordance
  - better heat scaling / markers
- Editor UX: autosave, title-from-body heuristics.
