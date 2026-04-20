-- =========================================================================
-- TwoThumbs initial schema
-- =========================================================================
-- Apply via Supabase Dashboard > SQL Editor, or `supabase db push` with CLI.
-- =========================================================================

create extension if not exists pgcrypto;

-- =========================================================================
-- Tables
-- =========================================================================

create table public.profiles (
  id              uuid primary key references auth.users(id) on delete cascade,
  country_code    text not null,
  occupation      text not null,
  gender          text not null check (gender in ('m','f','x')),
  age_bucket      text check (age_bucket in ('18-24','25-34','35-44','45-54','55+')),
  needs_halal     boolean not null default false,
  preferred_lang  text not null default 'en',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create table public.restaurants (
  id                    uuid primary key default gen_random_uuid(),
  google_place_id       text unique not null,
  name                  text not null,
  name_i18n             jsonb,
  address               text,
  lat                   double precision,
  lng                   double precision,
  phone                 text,
  category              text,
  is_halal              boolean not null default false,
  halal_cert_type       text check (halal_cert_type in ('certified','self-reported','muslim-friendly')),
  google_rating         numeric(2,1),
  google_review_count   int,
  google_cached_at      timestamptz,
  photo_refs            text[],
  created_at            timestamptz not null default now()
);

create index restaurants_coord_idx    on public.restaurants (lat, lng);
create index restaurants_halal_idx    on public.restaurants (is_halal) where is_halal = true;
create index restaurants_category_idx on public.restaurants (category);

create table public.reviews (
  id              uuid primary key default gen_random_uuid(),
  restaurant_id   uuid not null references public.restaurants(id) on delete cascade,
  user_id         uuid not null references public.profiles(id) on delete cascade,
  rating          smallint not null check (rating in (2, 1, -1, -2)),
  comment         text,
  tags            text[],
  photos          text[],
  -- Demographic snapshot at review time (filled by trigger from profile)
  snap_country    text not null,
  snap_occupation text not null,
  snap_gender     text not null,
  snap_age_bucket text,
  created_at      timestamptz not null default now(),
  unique (restaurant_id, user_id)
);

create index reviews_restaurant_idx         on public.reviews (restaurant_id);
create index reviews_user_idx               on public.reviews (user_id);
create index reviews_restaurant_country_idx on public.reviews (restaurant_id, snap_country);

create table public.bookmarks (
  user_id       uuid not null references public.profiles(id) on delete cascade,
  restaurant_id uuid not null references public.restaurants(id) on delete cascade,
  created_at    timestamptz not null default now(),
  primary key (user_id, restaurant_id)
);

create table public.halal_reports (
  id             uuid primary key default gen_random_uuid(),
  restaurant_id  uuid not null references public.restaurants(id) on delete cascade,
  user_id        uuid not null references public.profiles(id) on delete cascade,
  report_type    text not null check (report_type in ('certified','self-reported','muslim-friendly','not-halal')),
  evidence_url   text,
  verified       boolean not null default false,
  created_at     timestamptz not null default now()
);

-- =========================================================================
-- Functions & Triggers
-- =========================================================================

-- Auto-fill demographic snapshot from profile when review is inserted.
-- NOTE: using standard string literal (not dollar-quoting) for maximum
-- compatibility with SQL editors that split on ';' inside $$ blocks.
-- No single quotes appear in body, so no escaping needed.
create or replace function public.fill_review_snapshot()
returns trigger
language plpgsql
security definer
set search_path = public
as '
begin
  new.snap_country    := coalesce(new.snap_country,    (select country_code from public.profiles where id = new.user_id));
  new.snap_occupation := coalesce(new.snap_occupation, (select occupation   from public.profiles where id = new.user_id));
  new.snap_gender     := coalesce(new.snap_gender,     (select gender       from public.profiles where id = new.user_id));
  new.snap_age_bucket := coalesce(new.snap_age_bucket, (select age_bucket   from public.profiles where id = new.user_id));
  return new;
end;
';

create trigger reviews_fill_snapshot
  before insert on public.reviews
  for each row
  execute function public.fill_review_snapshot();

-- Keep profiles.updated_at fresh
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as '
begin
  new.updated_at := now();
  return new;
end;
';

create trigger profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at();

-- =========================================================================
-- Stats views (plain views for MVP — upgrade to materialized + pg_cron later)
-- =========================================================================

create view public.restaurant_stats as
select
  restaurant_id,
  count(*)                                      as n,
  count(*) filter (where rating =  2)           as n_double_up,
  count(*) filter (where rating =  1)           as n_up,
  count(*) filter (where rating = -1)           as n_down,
  count(*) filter (where rating = -2)           as n_double_down,
  avg(rating)::numeric(3,2)                     as score
from public.reviews
group by restaurant_id;

create view public.restaurant_stats_demo as
select
  restaurant_id,
  snap_country,
  snap_gender,
  snap_age_bucket,
  snap_occupation,
  count(*)                      as n,
  avg(rating)::numeric(3,2)     as score
from public.reviews
group by restaurant_id, snap_country, snap_gender, snap_age_bucket, snap_occupation;

-- =========================================================================
-- Row Level Security
-- =========================================================================

alter table public.profiles      enable row level security;
alter table public.restaurants   enable row level security;
alter table public.reviews       enable row level security;
alter table public.bookmarks     enable row level security;
alter table public.halal_reports enable row level security;

-- profiles: own read/write only
create policy "profiles_self_read"   on public.profiles for select using (auth.uid() = id);
create policy "profiles_self_insert" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_self_update" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- restaurants: public read, writes only via service_role (Edge Function)
create policy "restaurants_public_read" on public.restaurants for select using (true);

-- reviews: public read, own write
create policy "reviews_public_read" on public.reviews for select using (true);
create policy "reviews_self_insert" on public.reviews for insert with check (auth.uid() = user_id);
create policy "reviews_self_update" on public.reviews for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "reviews_self_delete" on public.reviews for delete using (auth.uid() = user_id);

-- bookmarks: own only
create policy "bookmarks_self_all"
  on public.bookmarks for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- halal_reports: public read, self-insert
create policy "halal_reports_public_read" on public.halal_reports for select using (true);
create policy "halal_reports_self_insert" on public.halal_reports for insert with check (auth.uid() = user_id);

-- =========================================================================
-- Grants for views (views don't inherit RLS, but they query RLS-protected tables)
-- =========================================================================

grant select on public.restaurant_stats      to anon, authenticated;
grant select on public.restaurant_stats_demo to anon, authenticated;
