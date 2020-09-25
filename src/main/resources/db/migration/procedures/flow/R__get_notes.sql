-- DROP FUNCTION IF EXISTS flow.get_notes(integer, integer);
CREATE OR REPLACE FUNCTION flow.get_notes(p_primary_id INTEGER, p_object_type_id INTEGER)

RETURNS TABLE(id int, note text, archived boolean, parent_id int, date_created timestamp, date_modified timestamp,
              created_by_id int, created_by text, modified_by_id int, primary_id int, child_notes json) AS

$BODY$
DECLARE
BEGIN

    case when p_object_type_id = 1 then
        RETURN QUERY
            select n.id,
                   n.note,
                   n.archived,
                   n.parent_id,
                   n.date_created,
                   n.date_modified,
                   n.created_by_id,
                   concat(creator.first_name, ' ', creator.last_name) as created_by,
                   n.modified_by_id,
                   pn.project_id as primary_id,
                   coalesce((
                                SELECT array_to_json(array_agg(row_to_json(childNotes)))
                                FROM (
                                         select n2.id,
                                                n2.note,
                                                n2.archived,
                                                n2.date_created as "dateCreated",
                                                n2.date_modified as "dateModified",
                                                n2.created_by_id as "createdById",
                                                concat(creator2.first_name, ' ', creator2.last_name) as "createdBy",
                                                n2.modified_by_id as "modifiedById",
                                                pn2.project_id as primaryId
                                         from flow.note n2
                                                  inner join flow.project_note pn2 on pn2.note_id = n2.id
                                                  inner join flow.user creator2 on creator2.id = n2.created_by_id
                                         where n2.archived is not true
                                           and n2.parent_id = n.id
                                         order by n2.date_created
                                     ) childNotes), '[]') AS "child_notes"
            from flow.note n
                     inner join flow.project_note pn on pn.note_id = n.id
                     inner join flow.user creator on creator.id = n.created_by_id
            where n.archived is not true
              and n.parent_id is null
              and pn.project_id = p_primary_id
            order by n.date_created desc;
    when p_object_type_id = 2 then
        RETURN QUERY
            select n.id,
                   n.note,
                   n.archived,
                   n.parent_id,
                   n.date_created,
                   n.date_modified,
                   n.created_by_id,
                   concat(creator.first_name, ' ', creator.last_name) as created_by,
                   n.modified_by_id,
                   cn.contact_id as primary_id,
                   coalesce((
                                SELECT array_to_json(array_agg(row_to_json(childNotes)))
                                FROM (
                                         select n2.id,
                                                n2.note,
                                                n2.archived,
                                                n2.date_created as "dateCreated",
                                                n2.date_modified as "dateModified",
                                                n2.created_by_id as "createdById",
                                                concat(creator2.first_name, ' ', creator2.last_name) as "createdBy",
                                                n2.modified_by_id as "modifiedById",
                                                cn2.contact_id as primaryId
                                         from flow.note n2
                                                  inner join flow.contact_note cn2 on cn2.note_id = n2.id
                                                  inner join flow.user creator2 on creator2.id = n2.created_by_id
                                         where n2.archived is not true
                                           and n2.parent_id = n.id
                                         order by n2.date_created
                                     ) childNotes), '[]') AS "child_notes"
            from flow.note n
                     inner join flow.contact_note cn on cn.note_id = n.id
                     inner join flow.user creator on creator.id = n.created_by_id
            where n.archived is not true
              and n.parent_id is null
              and cn.contact_id = p_primary_id
            order by n.date_created desc;
      when p_object_type_id = 4 then
        RETURN QUERY
          select n.id,
                 n.note,
                 n.archived,
                 n.parent_id,
                 n.date_created,
                 n.date_modified,
                 n.created_by_id,
                 concat(creator.first_name, ' ', creator.last_name) as created_by,
                 n.modified_by_id,
                 pn.project_process_step_id as primary_id,
                 coalesce((
                            SELECT array_to_json(array_agg(row_to_json(childNotes)))
                            FROM (
                                   select n2.id,
                                          n2.note,
                                          n2.archived,
                                          n2.date_created as "dateCreated",
                                          n2.date_modified as "dateModified",
                                          n2.created_by_id as "createdById",
                                          concat(creator2.first_name, ' ', creator2.last_name) as "createdBy",
                                          n2.modified_by_id as "modifiedById",
                                          pn2.project_process_step_id as primaryId
                                   from flow.note n2
                                          inner join flow.project_process_step_note pn2 on pn2.note_id = n2.id
                                          inner join flow.user creator2 on creator2.id = n2.created_by_id
                                   where n2.archived is not true
                                     and n2.parent_id = n.id
                                   order by n2.date_created
                                 ) childNotes), '[]') AS "child_notes"
          from flow.note n
                 inner join flow.project_process_step_note pn on pn.note_id = n.id
                 inner join flow.user creator on creator.id = n.created_by_id
          where n.archived is not true
            and n.parent_id is null
            and pn.project_process_step_id = p_primary_id
          order by n.date_created desc;
    when p_object_type_id = 3 then
        RETURN QUERY
            select n.id,
                   n.note,
                   n.archived,
                   n.parent_id,
                   n.date_created,
                   n.date_modified,
                   n.created_by_id,
                   concat(creator.first_name, ' ', creator.last_name) as created_by,
                   n.modified_by_id,
                   un.user_id as primary_id,
                   coalesce((
                                SELECT array_to_json(array_agg(row_to_json(childNotes)))
                                FROM (
                                         select n2.id,
                                                n2.note,
                                                n2.archived,
                                                n2.date_created as "dateCreated",
                                                n2.date_modified as "dateModified",
                                                n2.created_by_id as "createdById",
                                                concat(creator2.first_name, ' ', creator2.last_name) "createdBy",
                                                n2.modified_by_id as "modifiedById",
                                                cn2.contact_id as primaryId
                                         from flow.note n2
                                                  inner join flow.contact_note cn2 on cn2.note_id = n2.id
                                                  inner join flow.user creator2 on creator2.id = n2.created_by_id
                                         where n2.archived is not true
                                           and n2.parent_id = n.id
                                         order by n2.date_created
                                     ) childNotes), '[]') AS "child_notes"
            from flow.note n
                     inner join flow.user_note un on un.note_id = n.id
                     inner join flow.user creator on creator.id = n.created_by_id
            where n.archived is not true
              and n.parent_id is null
              and un.user_id = p_primary_id
            order by n.date_created desc;
      end case;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;
