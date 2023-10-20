drop function if exists brs.cron_update_project_metro_areas();
CREATE OR REPLACE FUNCTION brs.cron_update_project_metro_areas()
    RETURNS void AS
$BODY$
declare
    r              record;
BEGIN

    for r in select pd.id,
                    pd.project_id,
                    (select pcz.metro_area_id
                     from flow.postal_code pc
                      inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id
                     where pcz.archived is false
                       and pc.archived is false
                       and pc.postal_code = left(pd.project_postal_code, 5)) as metro_area_id
             from brs.project_details pd
             where pd.project_created_date > '2022-01-01'
               and pd.metro_area is null
               and left(pd.project_postal_code, 5) in (
                      select postal_code
                      from flow.postal_code
                      where archived is false)
    loop
      --1051 = cfga for metro area on project, this should also auto update project details
        perform flow.set_project_cfv(r.project_id, 99999999::bigint, 1051::bigint,
                                  r.metro_area_id::text, false);

    end loop;

END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

