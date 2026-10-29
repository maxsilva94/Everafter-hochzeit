-- In Supabase SQL Editor ausführen. Vorher zwei Auth-Benutzer anlegen.
create table if not exists public.members (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.workspace (
  id integer primary key check (id = 1),
  data jsonb not null,
  version bigint not null default 1
);
alter table public.members enable row level security;
alter table public.workspace enable row level security;
revoke all on public.members from anon, authenticated;
revoke all on public.workspace from anon;
grant select on public.workspace to authenticated;
create policy "Members may read workspace" on public.workspace
  for select to authenticated using (
    exists (select 1 from public.members m where m.user_id = (select auth.uid()))
  );
create or replace function public.save_workspace(new_data jsonb, expected_version bigint)
returns bigint
language plpgsql security definer set search_path = ''
as $$
declare result_version bigint;
begin
  if auth.uid() is null or not exists
    (select 1 from public.members where user_id = auth.uid()) then
    raise exception 'ACCESS_DENIED' using errcode = '42501';
  end if;
  update public.workspace
    set data = new_data, version = version + 1
    where id = 1 and version = expected_version
    returning version into result_version;
  if result_version is null then
    raise exception 'VERSION_CONFLICT' using errcode = '40001';
  end if;
  return result_version;
end;
$$;
revoke all on function public.save_workspace(jsonb,bigint) from public, anon;
grant execute on function public.save_workspace(jsonb,bigint) to authenticated;
insert into public.workspace(id,data) values (1,'{"settings":{"couple":"Die Hochzeit","date":"","budget":20000},"events":[{"id":"jga","name":"Junggesellenabschied","date":"","location":"","notes":"","status":"Geplant"},{"id":"standesamt","name":"Standesamt","date":"","location":"","notes":"","status":"Geplant"},{"id":"feier","name":"Hochzeitsfeier","date":"","location":"","notes":"","status":"Geplant"}],"tasks":[],"guests":[],"expenses":[],"budgets":[{"name":"Location","amount":0},{"name":"Catering & Getränke","amount":0},{"name":"Musik & Unterhaltung","amount":0},{"name":"Dekoration & Blumen","amount":0},{"name":"Outfit & Styling","amount":0},{"name":"Fotografie & Video","amount":0},{"name":"Transport","amount":0},{"name":"Geschenke","amount":0},{"name":"Sonstiges","amount":0}]}')
on conflict (id) do nothing;
-- Anschließend separat mit beiden echten Benutzer-UUIDs ausführen:
-- insert into public.members(user_id) values ('UUID_PERSON_1'),('UUID_PERSON_2');
do $$ begin
  alter publication supabase_realtime add table public.workspace;
exception when duplicate_object then null;
end $$;
