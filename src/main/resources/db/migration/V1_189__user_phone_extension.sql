-- drop this trigger or else updating the user records takes forever
drop trigger if exists user_view_trg on flow."user";

alter table flow."user"
  add column if not exists phone_extension varchar(10);

-- add column to user_positions_vw
alter table flow.user_positions_vw
  add column if not exists phone_extension varchar(10);

-- these are all the cfga's for the Phone Extension Field
update flow."user" u
set phone_extension = (select text_value
                       from flow.user_custom_field_value cfv
                       where custom_field_group_assignment_id in (291,378,17913,7831,7832,7833,7834,7835,7836,7837,7838,7839,7840,7841,7842,7843)
                         and text_value is not null
                         and u.id = cfv.user_id
                         and text_value != '')
;

-- archive all the phone extension cfga's
update flow.custom_field_group_assignment
set archived = true
where custom_field_id in (3664,9428,3663,3662,3661,3660,3659,3658,3657,3656,3655,3654,3653,3652,487,437);

-- add the trigger back
create trigger user_view_trg
  after insert or update or delete
  on flow."user"
  for each row
execute procedure flow.refresh_user_records();

-- might need to run these after the release, but can't do it as part of the fw migration cuz this runs before the procedure files
-- delete from flow.user_positions_vw;
-- delete from flow.user_position_hierarchy_vw;
-- refresh materialized view flow.user_positions_materialized_vw;
-- refresh materialized view flow.user_position_hierarchy_materialized_vw;
-- insert into flow.user_positions_vw
-- select * from flow.user_positions_materialized_vw;
-- insert into flow.user_position_hierarchy_vw
-- select * from flow.user_position_hierarchy_materialized_vw;
