alter table flow.postal_code_zone
add column if not exists remote boolean not null default false;
;
alter table flow.postal_code_zone
  add column if not exists company_timezone_id int references flow.company_timezone(id);

insert into flow.postal_code_zone (company_id, zone_name, created_by_id, distribution_time_frame_days, schedulable_future_days, remote, company_timezone_id)
select 3, 'Inside Sales', 2350555, 14, 7, true, 6
    where not exists (select id from flow.postal_code_zone where remote is true)
;

alter table flow.postal_code_zone_user
  add column if not exists company_timezone_id int references flow.company_timezone(id);

drop function if exists brs.get_total_lead_allocation(integer, boolean);

drop function if exists brs.get_allocation_by_zone(integer);
