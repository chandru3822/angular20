-- DROP FUNCTION IF EXISTS flow.get_attachment_origin(integer,);
CREATE OR REPLACE FUNCTION flow.get_attachment_origin(p_attachment_id INTEGER)

RETURNS text AS

$BODY$
DECLARE
  v_origin text;
BEGIN

  with origins as (
    select 'Project' as origin
    from flow.project_attachment
    where attachment_id = p_attachment_id
      and linked is false
      and archived is false
    union
    select concat(ps.process_step_name, ' ', ppsa.project_process_step_id)::text as origin
    from flow.project_process_step_attachment ppsa
      inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
      inner join flow.process_step ps on pps.process_step_id = ps.id
    where ppsa.attachment_id = p_attachment_id
      and ppsa.linked is false
      and ppsa.archived is false
    union
    select concat(e.event_name,' ',ppse.id)::text as origin
    from flow.project_process_step_event_attachment ppsea
       inner join flow.project_process_step_event ppse on ppse.id = ppsea.project_process_step_event_id
       inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
       inner join flow.event e on pse.event_id = e.id
    where ppsea.attachment_id = p_attachment_id
      and ppsea.linked is false
      and ppsea.archived is false
    union
    select 'Contact' as origin
    from flow.contact_attachment
    where attachment_id = p_attachment_id
      and linked is false
      and archived is false
    union
    select 'User' as origin
    from flow.user_attachment
    where attachment_id = p_attachment_id
      and linked is false
      and archived is false
    union
    select 'Organization' as origin
    from flow.org_attachment
    where attachment_id = p_attachment_id
      and linked is false
      and archived is false
    )
    select origin::text into v_origin
      from origins;

  return v_origin;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
