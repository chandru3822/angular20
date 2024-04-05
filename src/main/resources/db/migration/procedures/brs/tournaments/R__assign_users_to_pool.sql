drop function if exists brs.assign_users_to_pool(p_tournament_pool_id bigint, p_start_date date, p_count int);
drop function if exists brs.assign_users_to_pool(p_tournament_pool_id bigint, p_min_date date, p_max_date date, p_min_fdc int, p_max_fdc int, p_inclusive boolean, p_current_user_id bigint);
-- CREATE OR REPLACE FUNCTION brs.assign_users_to_pool(p_tournament_pool_id bigint, p_start_date date, p_end_date date, p_count_min int, p_count_max int, p_inclusive boolean, p_current_user_id bigint)
CREATE OR REPLACE FUNCTION brs.assign_users_to_pool(p_tournament_pool_id bigint, p_min_date date, p_max_date date, p_min_fdc int, p_max_fdc int, p_inclusive boolean, p_current_user_id bigint)
    RETURNS void AS
$BODY$
declare
    r                 record;
BEGIN

--this is a little odd. they only want current closers, but...if a current closer was also a closer in the past
--they want to use the oldest start date for any of the active closer's old closer positions (active or not)...if that makes sense
    for r in
        with data as (select distinct u.id as user_id, min(upos2.start_date) as position_start_date, (select count(pd.final_design_complete_date) from brs.project_details pd where pd.closer_user_id = u.id) as lifetime_fdc_count
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
        where case
            when p_inclusive is true then
                (case when p_min_date is not null and p_max_date is not null then position_start_date between p_min_date and p_max_date
                      when p_min_date is not null then position_start_date >= p_min_date
                      when p_max_date is not null then position_start_date <= p_max_date end)
                AND --this is key to the "inclusive" condition stuff
                (case when p_min_fdc is not null and p_max_fdc is not null then lifetime_fdc_count between p_min_fdc and p_max_fdc
                      when p_min_fdc is not null then lifetime_fdc_count >= p_min_fdc
                      when p_max_fdc is not null then lifetime_fdc_count <= p_max_fdc end)
            else
                (case when p_min_date is not null and p_max_date is not null then position_start_date between p_min_date and p_max_date
                      when p_min_date is not null then position_start_date >= p_min_date
                      when p_max_date is not null then position_start_date <= p_max_date end)
                OR --this is key to the "inclusive" condition stuff
                (case when p_min_fdc is not null and p_max_fdc is not null then lifetime_fdc_count between p_min_fdc and p_max_fdc
                      when p_min_fdc is not null then lifetime_fdc_count >= p_min_fdc
                      when p_max_fdc is not null then lifetime_fdc_count <= p_max_fdc end)
        end

        LOOP
            insert into brs.tournament_pool_user(user_id, tournament_pool_id, date_created, date_modified, created_by_id)
            values (r.user_id, p_tournament_pool_id, now(), now(), p_current_user_id);
        END LOOP;


END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

