CREATE OR REPLACE FUNCTION brs.assign_users_to_matches(p_tournament_id integer, p_tournament_pool_id integer,
                                                       p_user_id integer, p_user_ids int[])
    RETURNS void AS
$BODY$
declare
    r                 record;
    v_number_of_users integer;
    round_number      integer;
    v_top_seed        integer;
    v_bottom_seed     integer;
BEGIN

    select sum(tb.number_of_users)
    into v_number_of_users
    from brs.tournament t
             inner join brs.tournament_bracket tb on tb.tournament_id = t.id
    where t.id = p_tournament_id
    and tb.archived is not true;
    -- set the pool as advanced so the frontend knows not to allow them to do it again
    update brs.tournament_pool
    set advanced       = true,
        date_modified  = now(),
        modified_by_id = p_user_id
    where id = p_tournament_pool_id;

    -- add the advanced users into the matches of the first round in the tournament
    -- todo: keller will be attempting to do this in a calculated way based on rank instead of just spamming them in
    create temp table user_ids as
    select user_id, ROW_NUMBER() OVER () as match_id
    from (
             select unnest(p_user_ids) as user_id) as foo;
    round_number = 0;
    for r in
        with first_round as (
            select tb.id as tournament_bracket_id, min(tr.start_date) as tournament_round_start_date
            from brs.tournament_round tr
                     inner join brs.tournament_bracket tb on tr.tournament_bracket_id = tb.id
            where tb.tournament_id = p_tournament_id
            group by tb.id
        ),
             tournament_round as (
                 select tr.id
                 from brs.tournament_round tr
                          inner join brs.tournament_bracket tb on tr.tournament_bracket_id = tb.id
                          inner join first_round fr on fr.tournament_bracket_id = tb.id
                 where tr.start_date = fr.tournament_round_start_date
             )
        select tm.id tournament_match_id
        from brs.tournament_match tm
                 inner join tournament_round tr on tr.id = tm.tournament_round_id
        order by tm.id
        LOOP
            round_number = round_number + 1;
            select top_seed,bottom_seed
            into v_top_seed,v_bottom_seed
            from brs.tournament_seed_position
            where number_of_users = v_number_of_users
              and match_number = round_number;

            update brs.tournament_match tm2
            set user_1_id = (select user_id
                             from user_ids ui
                             where ui.match_id = v_top_seed),
                user_2_id = (select user_id
                             from user_ids ui
                             where ui.match_id = v_bottom_seed)
            where tm2.id = r.tournament_match_id;
        END LOOP;
    drop table user_ids;

    -- set all users as "qualified" so we can show that in the future
    update brs.tournament_pool_user
    set qualified = true
    where user_id in (select unnest(array [ p_user_ids ]::int[]))
      and tournament_pool_id = p_tournament_pool_id;

    -- after advancing the qualifiers add all the non-qualified to the loser pool
    with all_pool_users as (
        select tpu.id,
               tpu.user_id,
               concat(u.first_name, ' ', u.last_name::text) as full_name,
               tpu.archived
        from brs.tournament_pool_user tpu
                 inner join brs.tournament_pool tp on tpu.tournament_pool_id = tp.id
                 inner join flow."user" u on tpu.user_id = u.id
        where tp.tournament_id = p_tournament_id
          and tp.id = p_tournament_pool_id
          and tpu.archived is not true
        union
        select distinct null::integer,
                        upv.user_id,
                        concat(upv.first_name, ' ', upv.last_name::text) as full_name,
                        tpp.archived
        from flow.user_positions_vw upv
                 inner join brs.tournament_pool_position tpp on tpp.position_id = upv.position_id
                 inner join brs.tournament_pool tp on tpp.tournament_pool_id = tp.id
        where upv.company_id = 3
          and upv.has_access is true
          and tp.tournament_id = p_tournament_id
          and tp.id = p_tournament_pool_id
          and tpp.archived is not true
          and upv.archived is not true
          and (upv.start_date <= now() and
               (upv.end_date IS NULL OR upv.end_date > now()))
        order by full_name
    )
    insert into brs.tournament_pool_user(user_id, tournament_pool_id, date_created, created_by_id)
        (select apu.user_id,
                (select id
                 from brs.tournament_pool
                 where tournament_id = p_tournament_id
                   and tournament_pool_type_id = 2),
                now(),
                p_user_id
         from all_pool_users apu
         where apu.user_id not in (select unnest(array [ p_user_ids ]::int[]))
           and apu.archived is not true);


END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

