-- drop function if exists flow.check_bom_attachment(p_pps_id bigint,
--                                                      p_ppse_id bigint,
--                                                      p_attachment_type_id bigint,
--                                                      p_display_name_match_text varchar);
CREATE OR REPLACE FUNCTION brs.check_bom_attachment(p_pps_id bigint,
                                                                      p_ppse_id bigint)
  returns boolean AS
$BODY$
declare
--   v_request_is_valid boolean;
  v_matching_attachment_ids int[];
BEGIN

  if(p_ppse_id is not null) then
    select array_agg(att.id)::int[]
      into v_matching_attachment_ids
    from flow.project_process_step_event_attachment ppsa
           inner join flow.attachment att on att.id = ppsa.attachment_id
    where att.archived is false
      and ppsa.archived is false
      and ppsa.project_process_step_event_id = p_ppse_id
      and att.attachment_type_id = 45;
  else
    select array_agg(att.id)::int[]
      into v_matching_attachment_ids
    from flow.project_process_step_attachment ppsa
           inner join flow.attachment att on att.id = ppsa.attachment_id
    where att.archived is false
      and ppsa.archived is false
      and ppsa.project_process_step_id = p_pps_id
      and att.attachment_type_id = 45;
  end if;

  if array_length(v_matching_attachment_ids, 1) = 1 then
      return true;
  else
    return false;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
