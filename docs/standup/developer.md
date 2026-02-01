# Developer standup

## Today
- Mobile app scaffold exists at `apps/mobile`.
- **DB decision:** Drift (SQLite).

## Shipped (main)
- Added Drift + sqlite deps and ran codegen.
- Implemented core `Entry` domain model.
- Implemented local persistence with Drift (`entries` table) + `EntryRepository`.
- Wired mobile UX flow with `go_router` + Riverpod:
  - Entry list
  - Entry detail
  - Entry editor (create + edit)
- Fixed widget test teardown by using an in-memory Drift DB override; `flutter test` passes.

## Next
- Calendar browsing flow (day view → entries for day → editor).
- UX upgrades: autosave, better empty-state, delete confirmation/snackbar, title-from-body heuristics.
