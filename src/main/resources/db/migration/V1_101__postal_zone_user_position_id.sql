alter table flow.position
    add column if not exists scheduler boolean not null default false;

alter table flow.postal_code_zone_user
add column if not exists user_position_id int references flow.user_position(id);

alter table flow.postal_code_zone_user
drop column if exists user_id;

alter table flow.user_positions_vw
add column if not exists position_scheduler boolean;

-- refresh the materialized views
delete from flow.user_positions_vw;
delete from flow.user_position_hierarchy_vw;
refresh materialized view flow.user_positions_materialized_vw;
refresh materialized view flow.user_position_hierarchy_materialized_vw;
insert into flow.user_positions_vw
select * from flow.user_positions_materialized_vw;
insert into flow.user_position_hierarchy_vw
select * from flow.user_position_hierarchy_materialized_vw;
