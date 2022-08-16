-- DROP FUNCTION IF EXISTS flow.get_attachment_origin(integer);
CREATE OR REPLACE FUNCTION flow.get_attachment_origin(p_attachment_id INTEGER)

  RETURNS TABLE(origin_location text, origin_path text, object_type_id int, source_id int) AS

$BODY$
BEGIN

  return query
    with origins as (
      select 'Project' as origin,
             concat('/project/', pa.project_id) as origin_path_url,
             1 as obj_type_id,
             pa.project_id as src_id
      from flow.project_attachment pa
      where pa.attachment_id = p_attachment_id
        and pa.linked is false
        and pa.archived is false
      union
      select concat(ps.process_step_name, ' ', ppsa.project_process_step_id)::text as origin,
             concat('/project/', pps.project_id, '/processStep/', pps.id) as origin_path_url,
             4 as obj_type_id,
             pps.id as src_id
      from flow.project_process_step_attachment ppsa
             inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
             inner join flow.process_step ps on pps.process_step_id = ps.id
      where ppsa.attachment_id = p_attachment_id
        and ppsa.linked is false
        and ppsa.archived is false
      union
      select concat(e.event_name,' ',ppse.id)::text as origin,
             concat('/project/', pps.project_id, '/processStep/', pps.id, '/event/', ppse.id) as origin_path_url,
             6 as obj_type_id,
             ppse.id as src_id
      from flow.project_process_step_event_attachment ppsea
             inner join flow.project_process_step_event ppse on ppse.id = ppsea.project_process_step_event_id
             inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
             inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
             inner join flow.event e on pse.event_id = e.id
      where ppsea.attachment_id = p_attachment_id
        and ppsea.linked is false
        and ppsea.archived is false
      union
      select 'Contact' as origin,
             concat('/contact/', contact_id) as origin_path_url,
             2 as obj_type_id,
             contact_id as src_id
      from flow.contact_attachment
      where attachment_id = p_attachment_id
        and linked is false
        and archived is false
      union
      select 'User' as origin,
             concat('/user/', user_id) as origin_path_url,
             3 as obj_type_id,
             user_id as src_id
      from flow.user_attachment
      where attachment_id = p_attachment_id
        and linked is false
        and archived is false
      union
      select 'Organization' as origin,
             concat('/org/', org_id) as origin_path_url,
             5 as obj_type_id,
             org_id as src_id
      from flow.org_attachment
      where attachment_id = p_attachment_id
        and linked is false
        and archived is false
    )
    select origin::text,
           origin_path_url::text,
           obj_type_id::int,
           src_id::int
    from origins;




END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
