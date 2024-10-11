drop function if exists flow.add_project_children( bigint,  bigint,  bigint,
                                                   bigint,  bigint);
  CREATE OR REPLACE FUNCTION flow.add_project_children(p_parent_project_id bigint, p_company_id bigint, p_user_id bigint,
                                                       p_num_projects_to_create bigint, p_company_process_id bigint)
    RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    v_project_company_id bigint;
    v_contact_id bigint;
    v_parent_project_name text;
    v_existing_child_project_count bigint = 0;
    v_new_project_name text;
BEGIN

    -- a tiny bit of security that they dont mass create when their user has the wrong company
    select c.company_id, p.project_name, c.id
    into v_project_company_id, v_parent_project_name, v_contact_id
    from flow.project p
        inner join flow.contact c on p.contact_id = c.id
    where p.id = p_parent_project_id;

    if(v_project_company_id != p_company_id) then
        return;
    end if;

    select count(1)
        into v_existing_child_project_count
    from flow.project p
    where p.parent_id = p_parent_project_id
      and p.company_process_id = p_company_process_id
      and p.archived is false;

    for i in 1..p_num_projects_to_create
    loop
        v_existing_child_project_count = v_existing_child_project_count + 1;
        v_new_project_name = concat('Shell #', v_existing_child_project_count, ' [', v_parent_project_name, ']');
        --Shell # ((count of existing child projects of this type)+1) [Community Name]

        --do project creation here
        perform flow.create_project(v_contact_id, v_new_project_name, p_company_process_id, p_user_id, p_parent_project_id);
    end loop;

END;
$$
