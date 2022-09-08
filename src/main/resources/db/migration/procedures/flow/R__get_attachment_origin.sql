-- DROP FUNCTION IF EXISTS flow.attachment_linked(bigint);
CREATE OR REPLACE FUNCTION flow.attachment_linked(p_attachment_id bigint, p_project_id bigint, p_pps_id bigint,
                                                  p_pps_event_id bigint)
  RETURNS boolean as

$BODY$
declare
  v_attachment_is_linked boolean;
BEGIN

  if (p_pps_event_id is not null) then
    select true
    into v_attachment_is_linked
    from flow.project_process_step_event_attachment ppsea
    where ppsea.project_process_step_event_id = p_pps_event_id
      and ppsea.attachment_id = p_attachment_id
      and ppsea.archived is false
      and ppsea.linked is true;
  elseif (p_pps_id is not null) then
    select true
    into v_attachment_is_linked
    from flow.project_process_step_attachment ppsa
    where ppsa.project_process_step_id = p_pps_id
      and ppsa.attachment_id = p_attachment_id
      and ppsa.archived is false
      and ppsa.linked is true;
  elseif (p_project_id is not null) then
    select true
    into v_attachment_is_linked
    from flow.project_attachment pa
    where pa.project_id = p_project_id
      and pa.attachment_id = p_attachment_id
      and pa.archived is false
      and pa.linked is true;
  end if;

  return case when v_attachment_is_linked is null then false else v_attachment_is_linked end;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
