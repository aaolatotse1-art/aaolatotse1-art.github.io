-- ═══════════════════════════════════════════════════════════════════════
--  Portfolio analytics — Supabase setup
--  Run once in Supabase → SQL Editor → New query → paste → Run.
--
--  Security model
--   • Public visitors (the "anon" role) can only INSERT events. They cannot
--     read, change or delete anything.
--   • Only a signed-in user whose email matches OWNER_EMAIL below can READ.
--   • Enforced by Postgres Row Level Security on the server, not by the page.
-- ═══════════════════════════════════════════════════════════════════════

-- 1 ▸ CHANGE THIS to the email you will sign in with on admin.html
create or replace function public.portfolio_owner_email()
returns text language sql immutable as $$ select 'aaolatotse1@gmail.com'::text $$;
grant execute on function public.portfolio_owner_email() to anon, authenticated;

-- 2 ▸ Events table
create table if not exists public.site_events (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  event_type      text not null check (event_type in (
                    'pageview','section_view','page_leave','resume_download','resume_view','resume_tab',
                    'github_click','project_open','project_expand','filter_projects','certificate_open',
                    'contact_click','contact_submit','social_click','video_play')),
  visitor_id      uuid not null,
  session_id      uuid not null,
  is_new_visitor  boolean,
  path            text check (char_length(path) <= 200),
  section         text check (char_length(section) <= 60),
  label           text check (char_length(label) <= 120),
  value           integer check (value between 0 and 86400),
  referrer        text check (char_length(referrer) <= 200),
  utm_source      text check (char_length(utm_source) <= 100),
  utm_campaign    text check (char_length(utm_campaign) <= 100),
  device          text check (char_length(device) <= 20),
  browser         text check (char_length(browser) <= 30),
  os              text check (char_length(os) <= 20),
  screen          text check (char_length(screen) <= 20),
  language        text check (char_length(language) <= 20),
  timezone        text check (char_length(timezone) <= 60)
);

create index if not exists site_events_created_at_idx on public.site_events (created_at desc);
create index if not exists site_events_type_idx       on public.site_events (event_type, created_at desc);

-- 3 ▸ Row Level Security
alter table public.site_events enable row level security;

drop policy if exists "visitors can record events" on public.site_events;
create policy "visitors can record events"
  on public.site_events for insert to anon, authenticated
  with check (created_at > now() - interval '5 minutes');   -- no back-dated rows

drop policy if exists "owner can read events" on public.site_events;
create policy "owner can read events"
  on public.site_events for select to authenticated
  using ( lower(auth.jwt() ->> 'email') = lower(public.portfolio_owner_email()) );

drop policy if exists "owner can delete events" on public.site_events;
create policy "owner can delete events"
  on public.site_events for delete to authenticated
  using ( lower(auth.jwt() ->> 'email') = lower(public.portfolio_owner_email()) );

-- 4 ▸ Table privileges (belt and braces alongside RLS)
revoke all on public.site_events from anon, authenticated;
grant usage on schema public to anon, authenticated;
grant insert on public.site_events to anon, authenticated;
grant select, delete on public.site_events to authenticated;

-- 5 ▸ Live updates on the dashboard (optional; the dashboard also polls every 30 s)
do $$ begin
  alter publication supabase_realtime add table public.site_events;
exception when others then null; end $$;

-- 6 ▸ Optional: keep 13 months of history. Needs the pg_cron extension
--     (Database → Extensions → pg_cron). Uncomment after enabling it.
-- select cron.schedule('trim-site-events', '15 2 * * *',
--   $$ delete from public.site_events where created_at < now() - interval '13 months' $$);
