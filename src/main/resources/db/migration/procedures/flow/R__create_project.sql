drop function if exists flow.create_project(p_contact_id bigint, p_project_name text,
                                            p_company_process_id bigint, p_current_user_id bigint,
                                            p_parent_id bigint);
  CREATE OR REPLACE FUNCTION flow.create_project(p_contact_id bigint, p_project_name text,
  p_company_process_id bigint, p_current_user_id bigint,
  p_parent_id bigint default null)
    RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    v_new_project_id bigint;
    v_new_pps_id bigint;
    v_new_pps_ids bigint[];
    v_object_category_id bigint;
    v_company_id bigint;
    v_city text;
    v_postal_code text;
    v_company_state_id bigint;
    v_company_country_id bigint;
    v_owner_user_position_id bigint;
    v_company_project_status_type_id bigint;
    v_customer_contact_type_id bigint = 1;
    v_project_object_type_id bigint = 1;
    v_project_created_activity_id bigint = 3;
    v_initial_process_steps jsonb;
    json_object jsonb;
BEGIN

    -- here is what happens in java:
    -- the contact type id is changed from lead to contact
    -- the contact full name is used for the project name -
            -- but for my current functionality i will pass in a project name (maybe a default if not passed in?)
    -- get the object category id for the new project, maybe pass in
    -- get the initial/default company project status for that object category
    -- add the project
    -- add system activity
    -- get initial process steps for this process
    -- using the contact id or null, insert all initial process steps

    --update the contact type to Customer instead of Lead
    update flow.contact
        set contact_type_id = v_customer_contact_type_id,
            date_modified = now(),
            modified_by_id = p_current_user_id
    where id = p_contact_id;

    --get some contact info for later
    select c.company_state_id, c.company_country_id, c.owner_user_position_id, c.city, c.postal_code
    into v_company_state_id, v_company_country_id, v_owner_user_position_id, v_city, v_postal_code
    from flow.contact c
    where c.id = p_contact_id;

    --get the object category id using the company_process_id
    select p.object_category_id, cp.company_id
        into v_object_category_id, v_company_id
    from flow.company_process cp
        inner join flow.process p on cp.process_id = p.id
    where cp.id = p_company_process_id
    and cp.archived is false;

    --get the initial project status available to this object category/process
    select oc.company_project_status_type_id
        into v_company_project_status_type_id
    from flow.object_category_company_project_status_type oc
        inner join flow.company_project_status_type cpst on oc.company_project_status_type_id = cpst.id and cpst.archived is false and cpst.is_default is true
    where oc.object_category_id = v_object_category_id
    and oc.archived is false
    and cpst.company_id = v_company_id;

    --add the project
    insert into flow.project (contact_id, company_process_id, project_name, company_project_status_type_id, city, company_state_id, company_country_id, postal_code, created_by_id, date_created, modified_by_id, date_modified, user_position_id, object_category_id, parent_id)
    values (p_contact_id, p_company_process_id, trim(p_project_name), v_company_project_status_type_id, v_city, v_company_state_id, v_company_country_id, trim(v_postal_code), p_current_user_id, now(), p_current_user_id, now(), v_owner_user_position_id, v_object_category_id, p_parent_id)
    returning id into v_new_project_id;

    --add the system activity
    perform flow.add_system_activity(v_project_created_activity_id, v_project_object_type_id, v_new_project_id, p_current_user_id, null, null, null, null);

    --get initial process steps
    select json_agg(json_build_object('psId', psp.process_step_id, 'cpsstId', psp.company_process_step_status_type_id))::jsonb
        into v_initial_process_steps
    from flow.process_step_process psp
             inner join flow.process_step ps on ps.id = psp.process_step_id
             inner join flow.company_process_step_status_type cpsst on cpsst.id = psp.company_process_step_status_type_id
    where psp.company_process_id = p_company_process_id
--     where psp.company_process_id = 6
      and psp.archived is not true
      and psp.initial_step is true;


   --add the initial process steps
    FOR json_object IN
        SELECT * FROM jsonb_array_elements(v_initial_process_steps)
    loop
            raise notice 'here is the json_object %', (json_object->>'psId')::bigint;

        select insert_project_process_step
        from flow.insert_project_process_step(v_new_project_id::bigint, (json_object->>'psId')::bigint,
              v_owner_user_position_id::bigint, p_current_user_id::bigint, v_company_id::bigint,
            null::bigint, (json_object->>'cpsstId')::bigint,
            null::bigint, null::bigint) into v_new_pps_id;

        v_new_pps_ids = array_append(v_new_pps_ids, v_new_pps_id);
    end loop;

    --todo: do i need to return the list of pps ids to run auto triggers with in the java?
END;
$$
