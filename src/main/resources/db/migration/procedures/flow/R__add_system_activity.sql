drop function if exists flow.add_system_activity(bigint, bigint, bigint, bigint, bigint);
  CREATE OR REPLACE FUNCTION flow.add_system_activity(p_activity_id bigint,
                                                      p_object_type_id bigint,
                                                      p_project_id bigint,
                                                      p_pps_id bigint,
                                                      p_ppse_id bigint)
    RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    v_company_activity_note text;
BEGIN
  --determines if the company has the selected activity enabled
  select ca.note
      into v_company_activity_note
    from flow.company_activity ca
  where ca.archived is false
  and ca.activity_id = p_activity_id;

  if v_company_activity_note is not null then
    if p_object_type_id = 1 then
      --pps wont be null if event is null so we can use that for linked
      insert into flow.project_activity(project_id, note, created_by_id, modified_by_id, activity_type_id, linked, linked_pps_id, linked_ppse_id)
      values (p_project_id, v_company_activity_note, 2417170, 2417170, 1, (p_pps_id is not null), p_pps_id, p_ppse_id);
    end if;
  end if;

END;
$$
