CREATE OR REPLACE FUNCTION brs.check_project_zipcode(p_project_id bigint)
  returns boolean AS
$BODY$
declare
    v_approved boolean default false;

    begin
    --if postal code is present, active and not disqualified then it is approved
    select case when pc.active is true and pc.disqualified is false and pc.archived is false then true
            else false end into v_approved
        from flow.postal_code pc
    where trim(pc.postal_code) = (select left(p.postal_code, 5)
                                  from flow.project p
                                  where p.id = p_project_id);

        return coalesce(v_approved, false);
    end
$BODY$
  LANGUAGE plpgsql VOLATILE
               COST 100;
