# Memo pricing proposal (aligned to Moodiary benchmark)

Goal: monetize without harming trust. Diary apps are privacy-sensitive; pricing must be simple and value-based.

## Guiding principles
- **Free tier** must be fully usable for journaling.
- Monetize on: cross-device convenience, storage, advanced organization, and privacy upgrades.
- Avoid “paywalling writing”.

## Suggested tiers

### Free — $0
Best for: single-device or light multi-device.
- Unlimited entries
- Mood + tags + basic search
- Basic export (JSON)
- Map view basic (no advanced filters)
- Limited attachments (e.g., images up to N / month or small storage cap)

### Plus — $5/mo (or $50/yr)
Best for: daily journalers.
- Full sync across devices
- Attachments v1 (images) with meaningful storage (e.g., 10–50 GB)
- Advanced search + saved filters
- Export ZIP including media
- Email/priority support (lightweight)

### Privacy — $9/mo (or $90/yr)
Best for: users who want stronger guarantees.
- Everything in Plus
- **Client-side encryption** option (E2EE-style: server stores ciphertext)
- App lock + passkey/WebAuthn protection
- “Private AI mode”: off by default; if enabled, stricter controls + clearer audit (see below)

### Team / Family (optional later) — $12–20/mo
Best for: shared journals.
- Shared spaces with granular permissions
- Shared travel journal map

## Add-ons / constraints
- Storage overages: $2–5 per extra 50 GB (avoid surprise bills).
- AI usage-based: if AI becomes expensive, gate by credits/month on Plus/Privacy.

## AI trust positioning
- Default: AI features **off** until enabled.
- Clear toggles:
  - “Never send diary text to cloud” (still allow local prompts/statistics)
  - “Send selected entries only” vs “all entries”
- Provide an “AI data receipt” view: last request time, what was sent (high-level), retention policy.

## Competitive notes (Moodiary)
- Moodiary is open-source and offers WebDAV sync and LLM integration. Memo competes by:
  - frictionless onboarding
  - reliable sync
  - polished web UX
  - paid privacy features that are easy to understand (especially client-side encryption)
