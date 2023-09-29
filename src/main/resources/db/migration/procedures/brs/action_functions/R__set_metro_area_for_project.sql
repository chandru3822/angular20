CREATE OR REPLACE FUNCTION brs.set_metro_area_for_project(p_project_id bigint)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
v_metro_area_id int;
  BEGIN

  select
  from flow.postal_code pc
    inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code
  where trim(pc.postal_code) = (select left(p.postal_code, 5)
                                from flow.project p
                                where p.id = p_project_id);

  END;
$function$
