-- Base privada para sincronizar o estado do Gerenciador de Projetos.
-- Execute no SQL Editor do projeto Supabase antes de conectar o site.

create table if not exists public.app_state (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

revoke all on table public.app_state from anon, authenticated;
grant select, insert, update, delete on table public.app_state to authenticated;

drop policy if exists "Read own app state" on public.app_state;
create policy "Read own app state"
  on public.app_state for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Insert own app state" on public.app_state;
create policy "Insert own app state"
  on public.app_state for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Update own app state" on public.app_state;
create policy "Update own app state"
  on public.app_state for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Delete own app state" on public.app_state;
create policy "Delete own app state"
  on public.app_state for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create or replace function public.set_app_state_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists app_state_updated_at on public.app_state;
create trigger app_state_updated_at
  before update on public.app_state
  for each row execute function public.set_app_state_updated_at();

