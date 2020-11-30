alter table flow.user_positions_vw
add column if not exists company_state_id int;

alter table flow.user_positions_vw
    drop column if exists state_id;

DROP FUNCTION if exists flow.search_contacts(character varying, integer, boolean, boolean, integer, integer, integer);

-- refresh the materialized views
delete from flow.user_positions_vw;
delete from flow.user_position_hierarchy_vw;
refresh materialized view flow.user_positions_materialized_vw;
refresh materialized view flow.user_position_hierarchy_materialized_vw;
insert into flow.user_positions_vw
select * from flow.user_positions_materialized_vw;
insert into flow.user_position_hierarchy_vw
select * from flow.user_position_hierarchy_materialized_vw;
