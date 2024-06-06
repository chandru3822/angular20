alter table if exists flow.project
  add column if not exists search_city varchar generated always as (trim(lower(translate(city, '*,.-& ', '')))) stored;

create index if not exists search_city_search_idx
  on flow.project using gin (search_city public.gin_trgm_ops);

alter table if exists flow.project
  add column if not exists search_postal_code varchar generated always as (trim(lower(translate(project.postal_code, '*,.&', '')))) stored;

create index if not exists search_postal_code_search_idx
  on flow.project using gin (search_postal_code public.gin_trgm_ops);

alter table if exists flow.project
  add column if not exists search_date_created varchar generated always as (timezone('US/Mountain'::text, timezone('UTC'::text, date_created))::date) stored;

create index if not exists search_date_created_search_idx
  on flow.project using gin (search_date_created public.gin_trgm_ops);

create index if not exists company_project_status_type_idx
  on flow.company_project_status_type using gin (trim(lower(translate(project_status_type, '*,.&', ''))) public.gin_trgm_ops);

create index if not exists search_state_search_idx
  on flow.state using gin (lower(trim(abbreviation)) public.gin_trgm_ops);
