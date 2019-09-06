-- DROP FUNCTION IF EXISTS flow.get_notes(integer, integer);
CREATE OR REPLACE FUNCTION flow.get_notes(p_primary_id INTEGER, p_object_type_id INTEGER)

RETURNS TABLE(id int, note text, parent_id int, date_created timestamp, date_modified timestamp,
              created_by_id int, created_by text, modified_by_id int, primary_id int) AS

$BODY$
DECLARE
BEGIN

    case when p_object_type_id = 1 then
        RETURN QUERY
            select n.id,
                   n.note,
                   n.parent_id,
                   n.date_created,
                   n.date_modified,
                   n.created_by_id,
                   creator.first_name || ' ' || creator.last_name as created_by,
                   n.modified_by_id,
                   pn.project_id as primary_id
            from flow.note n
                 inner join flow.project_note pn on pn.id = n.id
                 inner join flow.user creator on creator.id = n.created_by_id
            where n.archived is not true
              and pn.project_id = p_primary_id;
    when p_object_type_id = 2 then
        RETURN QUERY
            select n.id,
                   n.note,
                   n.parent_id,
                   n.date_created,
                   n.date_modified,
                   n.created_by_id,
                   creator.first_name || ' ' || creator.last_name as created_by,
                   n.modified_by_id,
                   cn.customer_id as primary_id
            from flow.note n
                 inner join flow.customer_note cn on cn.id = n.id
                 inner join flow.user creator on creator.id = n.created_by_id
            where n.archived is not true
              and cn.customer_id = p_primary_id;
    when p_object_type_id = 3 then
        RETURN QUERY
          -- we dont have user notes yet
          select *
          from flow.user;
    when p_object_type_id = 4 then
        select n.id,
               n.note,
               n.parent_id,
               n.date_created,
               n.date_modified,
               n.created_by_id,
               creator.first_name || ' ' || creator.last_name as created_by,
               n.modified_by_id,
               pn.project_process_step_id as primary_id
        from flow.note n
                 inner join flow.project_process_step_note pn on pn.id = n.id
                 inner join flow.user creator on creator.id = n.created_by_id
        where n.archived is not true
          and pn.project_process_step_id = p_primary_id;
    end case;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;
