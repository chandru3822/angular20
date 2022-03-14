alter table brs.funnel add column if not exists closer_appt_outcome_int_values int[];
alter table brs.funnel add column if not exists exclude_values boolean not null default false;
alter table brs.funnel add column if not exists use_project_details boolean not null default false;
alter table brs.funnel add column if not exists hide_future boolean not null default false;
alter table brs.funnel add column if not exists only_future boolean not null default false;
alter table brs.funnel add column if not exists show_checked_in_column boolean not null default false;
alter table brs.funnel add column if not exists archived boolean not null default false;
alter table brs.funnel add column if not exists use_self_gen_sources boolean not null default false;
alter table brs.funnel add column if not exists use_brs_sources boolean not null default false;

update brs.funnel set funnel_type_id = 1 where id in (15,16,17,25,18,19,20,22,24,23,11);
update brs.funnel set funnel_type_id = 2 where id in (12,13,10,26);
update brs.funnel set funnel_type_id = 3 where id in (9,3,4,5,6,7,21,8);
update brs.funnel set display_order = 4 where id = 10;
update brs.funnel set display_order = 3 where id = 26;
update brs.funnel set use_brs_sources = true where id in (12, 10);
update brs.funnel set use_self_gen_sources = true where id in (13, 10);

update brs.funnel as f set
  closer_appt_outcome_int_values = c.int_vals,
 exclude_values = c.exclude_values,
  hide_future = c.hide_future,
  only_future = c.only_future,
  show_checked_in_column = c.show_checked_in_column
from (values
        (15, array[4]::int[], false, false, false, false),
        (16, array[59, 61, 16685]::int[], false, false, false, false),
        (17, array[4, 59, 61, 16685]::int[], true, false, false, false),
        (25, array[15327]::int[], false, false, false, false),
        (18, array[56]::int[], false, true, false, true),
        (19, array[3]::int[],  false, false, false, true),
        (20, array[58]::int[], false, true, false, true),
        (22, array[57]::int[], false, true, false, true),
        (24, array[60]::int[], false, false, false, true),
        (23, array[4,59,61,56,3,58,57,60,2,1139,1140,16685,15327]::int[], true, false, true, true),
        (11, array[2, 1139, 1140]::int[], false, false, false, true),
        (9, null, false, false, false, false),
        (3, null, false, false, false, false),
        (4, null, false, false, false, false),
        (5, null, false, false, false, false),
        (6, null, false, false, false, false),
        (7, null, false, false, false, false),
        (21,null, false, false, false, false),
        (8, null, false, false, false, false)
     ) as c(funnel_id, int_vals, exclude_values, hide_future, only_future, show_checked_in_column)
where c.funnel_id = f.id
;

--drop functions so they can be refactored
drop function if exists brs.rpt_closer_funnel_standard(date,date,integer[],integer[]);
drop function if exists brs.rpt_closer_funnel_standard_event_based(date,date,integer[],integer[]);
drop function if exists brs.rpt_closer_funnel_standard_drilldown(date,date,integer, integer[],integer[],boolean);
drop function if exists brs.rpt_closer_funnel_standard_and_cohort_drilldown(date,date,integer, integer[],integer[],boolean);
drop function if exists brs.rpt_closer_funnel_standard_and_cohort_drilldown(date,date,integer, integer[],integer[],boolean,boolean);
drop function if exists brs.rpt_closer_funnel_appts_created_pipeline(date,date,integer[],integer[]);
drop function if exists brs.rpt_closer_funnel_appts_created_pipeline_drilldown(date,date,integer[],integer[]);
drop function if exists brs.rpt_closer_funnel_appt_date_cohort(date,date,integer[],integer[]);
drop function if exists brs.rpt_closer_funnel_appt_date_cohort_drilldown(date,date,integer, integer[],integer[],boolean);
