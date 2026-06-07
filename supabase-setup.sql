-- ═══════════════════════════════════════════════════════════
-- HuynhProduct Portfolio · Supabase Schema
-- Paste into Supabase Dashboard → SQL Editor → Run
-- ═══════════════════════════════════════════════════════════

-- Projects (Experience + My Products pages)
create table if not exists projects (
  id            uuid        primary key default gen_random_uuid(),
  slug          text        unique not null,
  page          text        not null check (page in ('experience','products')),
  company_group text        not null default '',
  group_color   text        not null default '#7c3aed',
  group_meta    text        not null default '',
  group_order   int         not null default 0,
  title         text        not null default '',
  pill_text     text        not null default '',
  panel_co      text        not null default '',
  panel_desc    text        not null default '',
  bg_class      text        not null default '',
  bg_style      text        not null default '',
  cover_url     text        not null default '',
  full_width    boolean     not null default false,
  has_detail    boolean     not null default false,
  ext_link      text        not null default '',
  co_tag        text        not null default '',
  d_intro       text        not null default '',
  d_meta        jsonb       not null default '[]',
  d_stats       jsonb       not null default '[]',
  d_sections    jsonb       not null default '[]',
  sort_order    int         not null default 0,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

-- Case Studies
create table if not exists case_studies (
  id          uuid        primary key default gen_random_uuid(),
  title       text        not null default '',
  tag         text        not null default '',
  color_cls   text        not null default 'f',
  link        text        not null default '#',
  sort_order  int         not null default 0,
  created_at  timestamptz default now()
);

-- PM Topics
create table if not exists pm_topics (
  id          uuid        primary key default gen_random_uuid(),
  title       text        not null default '',
  description text        not null default '',
  icon_svg    text        not null default '',
  items       jsonb       not null default '[]',
  cta_label   text        not null default 'Read articles →',
  full_width  boolean     not null default false,
  sort_order  int         not null default 0,
  created_at  timestamptz default now()
);

-- ── RLS (reads public, writes open — protected by admin URL) ──
alter table projects     enable row level security;
alter table case_studies enable row level security;
alter table pm_topics    enable row level security;

create policy "public_read"  on projects     for select using (true);
create policy "admin_write"  on projects     for all    using (true) with check (true);
create policy "public_read"  on case_studies for select using (true);
create policy "admin_write"  on case_studies for all    using (true) with check (true);
create policy "public_read"  on pm_topics    for select using (true);
create policy "admin_write"  on pm_topics    for all    using (true) with check (true);

-- ── Auto-update updated_at ────────────────────────────────────
create or replace function _touch_updated_at()
returns trigger language plpgsql as
$$ begin new.updated_at = now(); return new; end; $$;

create trigger trg_touch_projects
  before update on projects
  for each row execute function _touch_updated_at();

-- ── Storage bucket for cover images ──────────────────────────
-- Run this separately if the bucket doesn't exist:
-- insert into storage.buckets (id, name, public) values ('covers', 'covers', true);
