-- Referenzschema für EverAfter (bereits im Supabase-Projekt installiert).
-- Zugriff: Nur Auth-Nutzer, deren UUID in public.members enthalten ist.
create table if not exists public.members (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.workspace (
  id integer primary key check (id=1),
  data jsonb not null,
  version bigint not null default 1
);
alter table public.members enable row level security;
alter table public.workspace enable row level security;
revoke all on public.members from anon, authenticated;
revoke all on public.workspace from anon;
grant select on public.members to authenticated;
grant select, update on public.workspace to authenticated;
drop policy if exists "Members see own membership" on public.members;
create policy "Members see own membership" on public.members
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "Only wedding members can read" on public.workspace;
create policy "Only wedding members can read" on public.workspace
  for select to authenticated using (
    exists(select 1 from public.members where user_id = (select auth.uid()))
  );
drop policy if exists "Only wedding members can update" on public.workspace;
create policy "Only wedding members can update" on public.workspace
  for update to authenticated
  using (exists(select 1 from public.members where user_id = (select auth.uid())))
  with check (exists(select 1 from public.members where user_id = (select auth.uid())));
-- Bereits angelegte Funktion save_workspace aktualisiert Datensatz nur bei passender Version.
-- Accounts in Authentication -> Users anlegen, dann Mitglieder per UUID eintragen.
-- Niemals private Passwörter oder service_role Schlüssel ins GitHub-Projekt schreiben.
