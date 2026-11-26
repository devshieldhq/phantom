-- PHANTOM RLS helpers and auth profile bootstrap.
-- SECURITY DEFINER helpers avoid recursive RLS policy evaluation.
create or replace function public.is_room_member(target_room uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.room_members where room_id = target_room and user_id = auth.uid()) $$;

create or replace function public.is_public_room(target_room uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.rooms where id = target_room and is_public = true) $$;

drop policy if exists "public rooms readable" on public.rooms;
drop policy if exists "memberships readable" on public.room_members;
drop policy if exists "self join public room" on public.room_members;
drop policy if exists "self leave room" on public.room_members;
drop policy if exists "room messages readable" on public.messages;
drop policy if exists "members send messages" on public.messages;

create policy "rooms readable" on public.rooms for select
using (is_public or public.is_room_member(id));
create policy "memberships readable" on public.room_members for select
using (user_id = auth.uid() or public.is_public_room(room_id));
create policy "self join public room" on public.room_members for insert
with check (user_id = auth.uid() and public.is_public_room(room_id));
create policy "self leave room" on public.room_members for delete
using (user_id = auth.uid());
create policy "room messages readable" on public.messages for select
using (public.is_room_member(room_id) or public.is_public_room(room_id));
create policy "members send messages" on public.messages for insert
with check (user_id = auth.uid() and public.is_room_member(room_id));

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
declare base_name text;
begin
  base_name := lower(regexp_replace(coalesce(split_part(new.email, '@', 1), 'member'), '[^a-z0-9_]', '', 'g'));
  if length(base_name) < 3 then base_name := 'member'; end if;
  insert into public.profiles (id, username, display_name)
  values (new.id, left(base_name, 16) || '_' || substr(replace(new.id::text, '-', ''), 1, 6), coalesce(new.raw_user_meta_data->>'display_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();
