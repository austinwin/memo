# Branching policy

**Policy:** All agents commit and push directly to `main`.

## Why
We’re optimizing for speed and tight iteration. Risky changes should be guarded with feature flags rather than long-lived branches.

## Required workflow
1. `git checkout main`
2. `git pull --ff-only origin main`
3. Make changes
4. `git commit -am "<message>"` (or `git add -A` then commit)
5. `git push origin main`

## Existing remote feature branches
Remote branches may exist from earlier work (e.g. `feature/memo-detail`). They are **not** the active workflow going forward.
