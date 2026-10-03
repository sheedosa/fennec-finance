-- Fennec Productions finance — run this once in your Supabase project
-- Dashboard → SQL Editor → New query → paste → Run

create extension if not exists "pgcrypto";

create table if not exists projects (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  client      text,
  status      text not null default 'Active' check (status in ('Pitching','Active','Delivered','Closed')),
  budget      numeric(14,2) not null default 0,
  notes       text,
  created_at  timestamptz not null default now()
);

create table if not exists invoices (
  id          uuid primary key default gen_random_uuid(),
  number      text not null unique,
  project_id  uuid references projects(id) on delete set null,
  client      text,
  issued      date not null default current_date,
  due         date,
  amount      numeric(14,2) not null default 0,          -- LYD
  status      text not null default 'Draft' check (status in ('Draft','Sent','Paid','Cancelled')),
  notes       text,
  created_at  timestamptz not null default now()
);

create table if not exists transactions (
  id          uuid primary key default gen_random_uuid(),
  date        date not null default current_date,
  project_id  uuid references projects(id) on delete set null,
  direction   text not null check (direction in ('In','Out')),
  category    text not null,
  payee       text,
  description text,
  amount      numeric(14,2) not null,
  currency    text not null default 'LYD',
  fx_rate     numeric(10,4) not null default 1,           -- rate to LYD at time of entry
  amount_lyd  numeric(14,2) generated always as (amount * fx_rate) stored,
  method      text not null default 'Cash' check (method in ('Cash','Bank Transfer','Cheque','Card')),
  receipt     text,
  invoice_id  uuid references invoices(id) on delete set null,
  created_at  timestamptz not null default now()
);

-- one-row-per-key settings: fx rates, categories, payees
create table if not exists settings (
  key         text primary key,
  value       jsonb not null,
  updated_at  timestamptz not null default now()
);

insert into settings (key, value) values
  ('fx_rates', '{"LYD":1,"USD":6.85,"EUR":7.40}'),
  ('categories', '[
    {"name":"Crew & Talent","direction":"Out","department":"Production"},
    {"name":"Equipment","direction":"Out","department":"Production"},
    {"name":"Locations & Permits","direction":"Out","department":"Production"},
    {"name":"Transport & Fuel","direction":"Out","department":"Production"},
    {"name":"Catering & Accommodation","direction":"Out","department":"Production"},
    {"name":"Travel","direction":"Out","department":"Production"},
    {"name":"Post-Production","direction":"Out","department":"Post"},
    {"name":"Office & Admin","direction":"Out","department":"Overhead"},
    {"name":"Marketing","direction":"Out","department":"Overhead"},
    {"name":"Bank & FX Fees","direction":"Out","department":"Overhead"},
    {"name":"Other Expense","direction":"Out","department":"Overhead"},
    {"name":"Client Payment","direction":"In","department":"Revenue"},
    {"name":"Deposit / Advance","direction":"In","department":"Revenue"},
    {"name":"Grant / Sponsorship","direction":"In","department":"Revenue"},
    {"name":"Other Income","direction":"In","department":"Revenue"}
  ]'),
  ('payees', '["Petty Cash"]')
on conflict (key) do nothing;

create index if not exists transactions_date_idx on transactions(date desc);
create index if not exists transactions_project_idx on transactions(project_id);
create index if not exists invoices_project_idx on invoices(project_id);

-- Security: only signed-in users can read or write. Create users in
-- Dashboard → Authentication → Users → Add user (email + password).
alter table projects     enable row level security;
alter table invoices     enable row level security;
alter table transactions enable row level security;
alter table settings     enable row level security;

do $$
declare t text;
begin
  foreach t in array array['projects','invoices','transactions','settings'] loop
    execute format('drop policy if exists "team access" on %I', t);
    execute format('create policy "team access" on %I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;
