# Developer standup

## Today
- Mobile app scaffold exists at `apps/mobile`.
- **DB decision:** Drift (SQLite).

## Shipped (main)
### Parity chunk A (mood + tags + tasks + pin + search)
- Added Entry parity fields:
  - Mood (3-level)
  - Tags
  - Tasks (checklist)
  - Pin/unpin
- Added search (title/body) on entry list.
- Persisted everything locally via Drift schema v3.

### Calendar MVP + delete undo
- Month calendar w/ heat + dots → day entries list → create/edit.
- Delete with Undo snackbar (list swipe + detail delete).
- `flutter test` passes.

## Next (parity-gated)
- Chunk B: calendar day flow polish (day list → detail → edit; return path).
- Chunk C: habit loop.
