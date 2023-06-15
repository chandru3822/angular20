drop function if exists flow.add_system_activity(bigint, bigint, bigint, bigint, bigint, bigint, text);
  CREATE OR REPLACE FUNCTION flow.add_system_activity(p_activity_id bigint,
                                                      p_object_type_id bigint,
                                                      p_source_id bigint,
                                                      p_user_id bigint,
                                                      p_pps_id bigint,
                                                      p_ppse_id bigint,
                                                      p_note_override text default null)
    RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    v_company_activity_note text;
    v_company_activity_id bigint;
    v_new_id bigint;
BEGIN
  --determines if the company has the selected activity enabled
  select ca.id, ca.note
      into v_company_activity_id, v_company_activity_note
    from flow.company_activity ca
  where ca.archived is false
  and ca.activity_id = p_activity_id;


  if v_company_activity_id is not null then
    if p_object_type_id = 1 then
      --pps wont be null if event is null so we can use that for linked
      insert into flow.project_activity(project_id, note, created_by_id, modified_by_id, activity_type_id, linked, linked_pps_id, linked_ppse_id)
      values (p_source_id, coalesce(p_note_override::text, v_company_activity_note), p_user_id, p_user_id, 1, (p_pps_id is not null), p_pps_id, p_ppse_id)
      returning id into v_new_id;

      --add any necessary hashtags to the system activity
      insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, created_by_id, modified_by_id)
      select v_new_id, cah.hashtag_id, p_user_id, p_user_id
      from flow.company_activity_hashtag cah
      where cah.company_activity_id = v_company_activity_id
        and cah.archived is false;
    end if;
  end if;

END
$$
