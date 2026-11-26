# Requirements — PHANTOM
## Goal
Deliver a working, demonstrable BBS-inspired community network.

## P0 — Competition MVP
1. Visitor can understand the product from the landing page.
2. Visitor can browse public rooms and their descriptions.
3. Authenticated member can join/leave a public room.
4. Room members can send and receive messages in real time.
5. Members can publish searchable archive entries.
6. Members can report abusive content; moderators can remove it.
7. UI is responsive, keyboard accessible, and usable on low bandwidth.
8. Demo data is clearly identified; no fake live metrics.

## P1
9. Public archive reading works offline after first visit.
10. Draft messages queue locally and sync safely when online.
11. AI can summarize public archive entries with visible AI attribution.
12. One small turn-based multiplayer text game.

## Quality / security
- Enforce access in database RLS, not just UI.
- Private rooms and messages are never public.
- Validate/sanitize user input and uploads.
- Never expose secrets in browser bundles.
- Preserve original content alongside AI summaries.
- Provide empty, loading, error, and offline states.