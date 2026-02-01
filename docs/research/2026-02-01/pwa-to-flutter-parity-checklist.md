# PWA → Flutter parity checklist (Memo)

Source PWA feature list: `memo/README.md` (vanilla JS PWA).
Target app: `apps/mobile` (Flutter mobile-first).

## Status legend
- ✅ Implemented in Flutter
- 🟡 Partially / scaffolded
- ❌ Not implemented yet

## Core entry
- ✅ Create/edit entries (title, datetime, text) — implemented (CRUD flow)
- ❌ Mood (3-level)
- ❌ Tags
- ❌ Location attach/edit
- ❌ Pin/unpin entries
- ❌ Tasks: mark as task + done

## Browsing & organization
- ❌ Search by text
- ❌ Filter by mood
- ❌ Sort by date/title
- 🟡 Calendar navigation (dependency added; UI not complete)
- ❌ Quick tag filters / saved filters

## Stats & habit features
- ❌ Streak
- ❌ Words today/week
- ❌ Daily word goal + progress
- ❌ Daily focus

## Map
- ❌ Map view (Leaflet equivalent)
- ❌ Location picker (current location + label/symbol)
- ❌ Timeline slider + heat toggle

## Backup / portability
- ❌ Export JSON
- ❌ Import JSON (restore/merge)

## UI / platform
- ❌ Theme toggle (light/dark)
- ✅ Basic navigation/routing (go_router)

## What’s implemented in Flutter right now
- Entry domain model + local persistence (Drift/SQLite)
- Entry list → detail → editor flow
- Tests pass (`flutter test`)

## Recommended build order (mobile-first)
1) Editor parity: mood + tags + task + pin + search
2) Calendar day view (Moodiary-style “return path”)
3) Habit loop: daily goal + streak + weekly stats
4) Export/import
5) Map + location picker (later, after core retention loops)

This checklist should be updated as features land.
