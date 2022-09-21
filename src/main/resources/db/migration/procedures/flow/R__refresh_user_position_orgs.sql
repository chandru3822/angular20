drop function if exists flow.refresh_user_position_orgs();
CREATE OR REPLACE FUNCTION flow.refresh_user_position_orgs()

  RETURNS TABLE
          (
            id             bigint,
            note           text,
            archived       boolean,
            parent_id      bigint,
            date_created   timestamp,
            date_modified  timestamp,
            created_by_id  bigint,
            created_by     text,
            modified_by_id bigint,
            primary_id     bigint,
            child_notes    json
          )
AS

$BODY$
DECLARE
BEGIN
  refresh materialized view flow.user_positions_materialized_vw;
  refresh materialized view flow.user_position_hierarchy_materialized_vw;

  delete from flow.user_positions_vw;
  delete from flow.user_position_hierarchy_vw;

  insert into flow.user_positions_vw
  select *
  from flow.user_positions_materialized_vw;

  insert into flow.user_position_hierarchy_vw
  select *
  from flow.user_position_hierarchy_materialized_vw;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
