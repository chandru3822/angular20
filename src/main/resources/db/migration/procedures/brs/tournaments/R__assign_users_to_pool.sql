drop function if exists brs.assign_users_to_pool(p_tournament_pool_id bigint, p_start_date date, p_count int);
-- CREATE OR REPLACE FUNCTION brs.assign_users_to_pool(p_tournament_pool_id bigint, p_start_date date, p_end_date date, p_count_min int, p_count_max int, p_inclusive boolean, p_current_user_id bigint)
CREATE OR REPLACE FUNCTION brs.assign_users_to_pool(p_tournament_pool_id bigint, p_start_date date, p_count int, p_is_rookie boolean, p_current_user_id bigint)
    RETURNS void AS
$BODY$
declare
    r                 record;

BEGIN

    --this only works for rookie and legacy in a hard-coded way. carlin and randa are still thinking thu dynamic solutions

    for r in
        with data as (select distinct u.id as user_id, min(upos2.start_date) as start_date, (select count(pd.final_design_complete_date) from brs.project_details pd where pd.closer_user_id = u.id) as fdc_count
                      from flow.user u
                               join flow.user_position upos2 on upos2.user_id = u.id
                          and upos2.position_id = 1 and upos2.archived is not true
                               join flow.company_user_status cus on u.id = cus.user_id
                               join flow.user_status_type ust on ust.id = cus.user_status_type_id
                          and ust.company_id = 3 and ust.has_access is true
                          and u.id in (
                              select upos.user_id
                              from flow.user_position upos
                              where upos.position_id = 1 and primary_flag is true and upos.archived is not true
                          )
                      group by 1)
        select user_id
        from data
        where case when p_is_rookie then start_date >= p_start_date and fdc_count < p_count  --rookie
                                    else (start_date < p_start_date or fdc_count >= p_count) --legacy
            end
        LOOP
            insert into brs.tournament_pool_user(user_id, tournament_pool_id, date_created, date_modified, created_by_id)
            values (r.user_id, p_tournament_pool_id, now(), now(), p_current_user_id);
        END LOOP;


END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

