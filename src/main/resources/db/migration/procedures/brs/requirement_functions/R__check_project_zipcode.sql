CREATE OR REPLACE FUNCTION brs.check_project_zipcode(p_project_id bigint)
  returns boolean AS
$BODY$
declare
    v_pc_approved boolean default false;
    v_zip_pps_approved boolean default false;

    begin
    --if postal code is present, active and not disqualified then it is approved
    select case when pc.active is true and pc.disqualified is false and pc.archived is false then true
            else false end into v_pc_approved
        from flow.postal_code pc
    where trim(pc.postal_code) = (select left(p.postal_code, 5)
                                  from flow.project p
                                  where p.id = p_project_id);

    --if the postal code is approved return that, otherwise return the approved status of the
    --primary Zip Code Approval process step. If there isn't one, return false.
    if(v_pc_approved is true) then
        return v_pc_approved;
    else
        --1112 = Approved (company_process_step_status_type_id)
        select pps.company_process_step_status_type_id = 1112 into v_zip_pps_approved
        from flow.project_process_step pps
        where pps.project_id = p_project_id
          and pps.process_step_id = 3546 -- Zip Code Approval
          and pps.main is true;

        return coalesce(v_zip_pps_approved, false);
    end if;
    end
$BODY$
  LANGUAGE plpgsql VOLATILE
               COST 100;
