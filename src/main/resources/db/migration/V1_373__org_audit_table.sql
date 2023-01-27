create table if not exists flow.org_audit
(
  id                         bigserial constraint org_audit_pk primary key,
  org_id integer,
  org_name                   varchar(200),
  parent_org_id              bigint,
  org_type_id                bigint,
  active_flag                     boolean,
  archived                   boolean,
  schedulable                boolean,
  company_timezone_id        bigint,
  company_state_id           bigint,
  created_by_id              bigint,
  modified_by_id             bigint,
  date_created               timestamp,
  date_modified              timestamp,
  default_appointment_length integer
);


select *
from flow.org o
order by date_modified desc
;

select * 
from flow.org_audit oa 
