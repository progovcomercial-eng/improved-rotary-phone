-- ALE CLUBE: funções administrativas seguras
-- Execute este script no SQL Editor do projeto Supabase associado ao ALE CLUBE.
create table if not exists public.app_user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','manager','staff')),
  created_at timestamptz not null default now()
);
alter table public.app_user_roles enable row level security;

-- Usuário autenticado só pode consultar a própria função.
drop policy if exists "Users can read their own role" on public.app_user_roles;
create policy "Users can read their own role"
on public.app_user_roles for select to authenticated
using (auth.uid() = user_id);

-- Função SECURITY DEFINER evita recursão na policy da tabela de roles.
create or replace function public.current_app_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select role from public.app_user_roles where user_id = (select auth.uid()) limit 1
$$;
revoke all on function public.current_app_role() from public;
grant execute on function public.current_app_role() to authenticated;

-- Apenas o owner já cadastrado pode administrar funções.
drop policy if exists "Owner manages app roles" on public.app_user_roles;
create policy "Owner manages app roles"
on public.app_user_roles for all to authenticated
using (public.current_app_role() = 'owner')
with check (public.current_app_role() = 'owner');

-- Após criar o primeiro usuário no Supabase Auth, associe seu UUID:
-- insert into public.app_user_roles(user_id, role)
-- values ('UUID-DO-USUARIO', 'owner');
