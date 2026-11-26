# PHANTOM
### The internet never really dies.

PHANTOM is a modern resurrection of Bulletin Board Systems (BBS): a community-first digital space with terminal-inspired rooms, live conversations, and a shared knowledge archive.

## MVP
- Terminal-inspired landing and room dashboard
- Community rooms and real-time messaging
- Searchable knowledge archive
- Accounts and profiles
- Offline-friendly reading and draft queue
- AI-assisted archive summaries (later milestone)

## Stack
- Next.js App Router + TypeScript
- Tailwind CSS
- Supabase Auth, Postgres, Realtime, and Storage
- IndexedDB/service worker for offline support
- Provider-neutral AI adapter

## Local setup
1. Install Node.js 20+.
2. Run `npm install`.
3. Copy `.env.example` to `.env.local` and fill in Supabase values.
4. Run `npm run dev`.

## Project rules
- Keep the core usable without AI.
- Preserve original archive content; label AI-generated summaries.
- Enforce authorization with Supabase RLS.
- Never expose service-role keys in client code.
- Validate uploads and user input; rate-limit writes.
- Do not cache private messages in shared offline storage.

## Build order
See [project tasks](.kiro/specs/phantom-platform/tasks.md).
