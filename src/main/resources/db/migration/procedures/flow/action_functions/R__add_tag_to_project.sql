-- drop function if exists flow.assign_tag_to_project(p_project_id bigint, p_user_id bigint, tag_id bigint, add_tag boolean);
CREATE OR REPLACE FUNCTION flow.assign_tag_to_project(p_project_id bigint, p_user_id bigint, p_tag_id bigint,
                                                      p_remove_tag boolean)
  returns boolean AS
$BODY$
declare
  v_request_is_valid boolean;
BEGIN

  --check that the project company id and the tag company id are the same in case the user screwed it up
  select (select cp.company_id
          from flow.project p
                 inner join flow.company_process cp on cp.id = p.company_process_id
          where p.id = p_project_id) = (select t.company_id
                                        from flow.tag t
                                        where t.id = p_tag_id)
  into v_request_is_valid;

  if v_request_is_valid is true then

    if (p_remove_tag is true) then
      update flow.project_tag
      set archived       = true,
          modified_by_id = p_user_id,
          date_modified  = now()
      where project_id = p_project_id
        and tag_id = p_tag_id;
    else
      insert into flow.project_tag(project_id, tag_id, date_created, created_by_id)
      select p_project_id, p_tag_id, now(), p_user_id
      where not exists(
        select id
        from flow.project_tag
        where project_id = p_project_id
          and tag_id = p_tag_id
          and archived is false
        );
    end if;
    return true;
  else
    return false;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
