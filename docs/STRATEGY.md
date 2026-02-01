# Strategy Update: Flutter-first (Director decision)

## Decision
We are pivoting from “PWA web-first SaaS” to **Flutter-first** so we can ship:
- Mobile apps (iOS/Android)
- Desktop (macOS/Windows/Linux)
- Web (including PWA-like installability)

## Phase 1 benchmark
- **Moodiary** (must beat): https://github.com/ZhuJHua/moodiary

## What stays true
- We still aim to beat Moodiary on **feature coverage + UI polish** first.
- We still commit/push to `main` only.

## Near-term implications
- Create a new Flutter app in-repo (or migrate incrementally) while preserving data export/import.
- Choose local DB (likely Isar/Drift) and sync model for future SaaS.
- Rebuild core journaling UX first, then parity features (calendar, media hub, categories/saved views, recycle bin, backup/sync UX).

## Working rules
- Main-only commits: see `docs/BRANCHING.md`
- Outputs:
  - Content: `/docs/content/...`
  - Research: `/docs/research/...`
  - Standups: `/docs/standup/...`
