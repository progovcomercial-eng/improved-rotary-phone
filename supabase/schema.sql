-- ALE CLUBE: base inicial de dados para Supabase/PostgreSQL.
-- Execute apenas em um projeto novo/revisado. Não contém dados reais nem credenciais.
create extension if not exists pgcrypto;

create type public.app_role as enum ('owner','admin','manager','secretary','sales','finance');
create type public.membership_status as enum ('pending','active','past_due','cancelled','expired');
create type public.payment_status as enum ('pending','approved','declined','cancelled','refunded');
create type public.appointment_status as enum ('requested','confirmed','cancelled','completed','no_show');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null,
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);

create or replace function public.has_role(required_roles public.app_role[])
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = (select auth.uid()) and role = any(required_roles)
  );
$$;

create table public.membership_plans (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  billing_period text not null check (billing_period in ('monthly','annual')),
  price_cents integer not null check (price_cents >= 0),
  benefits jsonb not null default '[]'::jsonb,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.memberships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  plan_id uuid not null references public.membership_plans(id),
  status public.membership_status not null default 'pending',
  started_at timestamptz,
  expires_at timestamptz,
  external_subscription_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  image_url text,
  price_cents integer not null check (price_cents >= 0),
  member_price_cents integer check (member_price_cents is null or member_price_cents >= 0),
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  status text not null default 'pending' check (status in ('pending','paid','processing','shipped','ready_for_pickup','cancelled','refunded')),
  total_cents integer not null check (total_cents >= 0),
  fulfillment_method text check (fulfillment_method in ('delivery','pickup')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  quantity integer not null check (quantity > 0),
  unit_price_cents integer not null check (unit_price_cents >= 0)
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  order_id uuid references public.orders(id),
  membership_id uuid references public.memberships(id),
  provider text not null check (provider in ('mercado_pago','kiwify','other')),
  provider_payment_id text,
  status public.payment_status not null default 'pending',
  amount_cents integer not null check (amount_cents >= 0),
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  check (order_id is not null or membership_id is not null)
);

create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  service_name text not null,
  professional_name text,
  starts_at timestamptz not null,
  status public.appointment_status not null default 'requested',
  customer_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_user_id uuid references auth.users(id),
  action text not null,
  entity_type text not null,
  entity_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index memberships_user_idx on public.memberships(user_id, created_at desc);
create index orders_user_idx on public.orders(user_id, created_at desc);
create index payments_user_idx on public.payments(user_id, created_at desc);
create index appointments_user_idx on public.appointments(user_id, starts_at desc);

alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.membership_plans enable row level security;
alter table public.memberships enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payments enable row level security;
alter table public.appointments enable row level security;
alter table public.audit_log enable row level security;

create policy "profiles_read_self_or_staff" on public.profiles for select to authenticated
using (id = (select auth.uid()) or public.has_role(array['owner','admin','manager','secretary','sales','finance']::public.app_role[]));
create policy "profiles_update_self_or_staff" on public.profiles for update to authenticated
using (id = (select auth.uid()) or public.has_role(array['owner','admin','manager']::public.app_role[]))
with check (id = (select auth.uid()) or public.has_role(array['owner','admin','manager']::public.app_role[]));

create policy "roles_read_self_or_admin" on public.user_roles for select to authenticated
using (user_id = (select auth.uid()) or public.has_role(array['owner','admin']::public.app_role[]));

create policy "plans_public_read_active" on public.membership_plans for select
using (is_active or public.has_role(array['owner','admin','manager','finance']::public.app_role[]));
create policy "plans_staff_manage" on public.membership_plans for all to authenticated
using (public.has_role(array['owner','admin','manager']::public.app_role[]))
with check (public.has_role(array['owner','admin','manager']::public.app_role[]));

create policy "products_public_read_active" on public.products for select
using (is_active or public.has_role(array['owner','admin','manager','sales']::public.app_role[]));
create policy "products_staff_manage" on public.products for all to authenticated
using (public.has_role(array['owner','admin','manager','sales']::public.app_role[]))
with check (public.has_role(array['owner','admin','manager','sales']::public.app_role[]));

create policy "memberships_read_owner_or_staff" on public.memberships for select to authenticated
using (user_id = (select auth.uid()) or public.has_role(array['owner','admin','manager','secretary','finance']::public.app_role[]));
create policy "memberships_staff_manage" on public.memberships for all to authenticated
using (public.has_role(array['owner','admin','manager','finance']::public.app_role[]))
with check (public.has_role(array['owner','admin','manager','finance']::public.app_role[]));

create policy "orders_read_owner_or_staff" on public.orders for select to authenticated
using (user_id = (select auth.uid()) or public.has_role(array['owner','admin','manager','sales','finance']::public.app_role[]));
create policy "orders_customer_create" on public.orders for insert to authenticated
with check (user_id = (select auth.uid()));
create policy "orders_staff_manage" on public.orders for update to authenticated
using (public.has_role(array['owner','admin','manager','sales','finance']::public.app_role[]))
with check (public.has_role(array['owner','admin','manager','sales','finance']::public.app_role[]));

create policy "order_items_read_through_order" on public.order_items for select to authenticated
using (exists(select 1 from public.orders o where o.id=order_id and (o.user_id=(select auth.uid()) or public.has_role(array['owner','admin','manager','sales','finance']::public.app_role[]))));
create policy "order_items_customer_create" on public.order_items for insert to authenticated
with check (exists(select 1 from public.orders o where o.id=order_id and o.user_id=(select auth.uid()) and o.status='pending'));

create policy "payments_read_owner_or_staff" on public.payments for select to authenticated
using (user_id=(select auth.uid()) or public.has_role(array['owner','admin','finance']::public.app_role[]));
-- Sem INSERT/UPDATE para clientes: status deve vir do webhook verificado no servidor.

create policy "appointments_read_owner_or_staff" on public.appointments for select to authenticated
using (user_id=(select auth.uid()) or public.has_role(array['owner','admin','manager','secretary']::public.app_role[]));
create policy "appointments_customer_request" on public.appointments for insert to authenticated
with check (user_id=(select auth.uid()) and status='requested');
create policy "appointments_staff_manage" on public.appointments for update to authenticated
using (public.has_role(array['owner','admin','manager','secretary']::public.app_role[]))
with check (public.has_role(array['owner','admin','manager','secretary']::public.app_role[]));

create policy "audit_staff_read" on public.audit_log for select to authenticated
using (public.has_role(array['owner','admin']::public.app_role[]));
-- Escrita de pagamentos, papéis, auditoria e confirmações: somente serviço de backend com service_role.
