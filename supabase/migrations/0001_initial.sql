-- PHANTOM initial schema
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null check (char_length(username) between 3 and 24),
  display_name text not null default '',
  bio text not null default '',
  created_at timestamptz not null default now()
);
create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  description text not null default '',
  is_public boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create table if not exists public.room_members (
  room_id uuid references public.rooms(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('member','moderator','owner')),
  joined_at timestamptz not null default now(),
  primary key (room_id, user_id)
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index if not exists messages_room_created_idx on public.messages(room_id, created_at desc);
create table if not exists public.archive_entries (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users(id) on delete set null,
  title text not null check (char_length(title) between 3 and 160),
  body text not null,
  summary text,
  is_public boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists archive_search_idx on public.archive_entries using gin (to_tsvector('english', title || ' ' || body));

alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.room_members enable row level security;
alter table public.messages enable row level security;
alter table public.archive_entries enable row level security;

create policy "profiles readable" on public.profiles for select using (true);
create policy "profile owner insert" on public.profiles for insert with check (auth.uid() = id);
create policy "profile owner update" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy "public rooms readable" on public.rooms for select using (is_public or exists (select 1 from public.room_members m where m.room_id = id and m.user_id = auth.uid()));
create policy "memberships readable" on public.room_members for select using (user_id = auth.uid() or exists (select 1 from public.rooms r where r.id = room_id and r.is_public));
create policy "self join public room" on public.room_members for insert with check (user_id = auth.uid() and exists (select 1 from public.rooms r where r.id = room_id and r.is_public));
create policy "self leave room" on public.room_members for delete using (user_id = auth.uid());
create policy "room messages readable" on public.messages for select using (exists (select 1 from public.room_members m where m.room_id = room_id and m.user_id = auth.uid()) or exists (select 1 from public.rooms r where r.id = room_id and r.is_public));
create policy "members send messages" on public.messages for insert with check (user_id = auth.uid() and exists (select 1 from public.room_members m where m.room_id = room_id and m.user_id = auth.uid()));
create policy "public archive readable" on public.archive_entries for select using (is_public or author_id = auth.uid());
create policy "authors create archive" on public.archive_entries for insert with check (author_id = auth.uid());
create policy "authors update archive" on public.archive_entries for update using (author_id = auth.uid()) with check (author_id = auth.uid());

insert into public.rooms (slug, name, description) values
('the-lobby','The Lobby','Meet the community and find your way around.'),
('build-in-public','Build in Public','Share works in progress and get feedback.'),
('lost-and-found','Lost & Found','Recover ideas, guides, and forgotten knowledge.'),
('after-hours','After Hours','Late-night thoughts and conversations.')
on conflict (slug) do nothing;

alter publication supabase_realtime add table public.messages;