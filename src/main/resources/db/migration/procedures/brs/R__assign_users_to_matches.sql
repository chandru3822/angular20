CREATE OR REPLACE FUNCTION brs.assign_users_to_matches(p_tournament_id integer, p_tournament_pool_id integer, p_user_id integer, p_user_ids int[])
    RETURNS void AS
$BODY$
declare
    r record;
BEGIN

    -- set the pool as advanced so the frontend knows not to allow them to do it again
    update brs.tournament_pool
        set advanced = true,
            date_modified = now(),
            modified_by_id = p_user_id
    where id = p_tournament_pool_id;

    -- add the advanced users into the matches of the first round in the tournament
    -- todo: keller will be attempting to do this in a calculated way based on rank instead of just spamming them in
    create temp table user_ids as
    select unnest( p_user_ids ) as user_id;
    for r in
        with first_round as (
            select tr.id
            from brs.tournament_round tr
                     inner join brs.tournament_bracket tb on tr.tournament_bracket_id = tb.id
            where tb.tournament_id = p_tournament_id
            order by tr.id
            limit 1
        )
        select tm.id
        from brs.tournament_match tm
                 inner join first_round fr on fr.id = tm.tournament_round_id
        LOOP
            with update_data as (
                update brs.tournament_match
                    set user_1_id = (select user_id
                                     from user_ids
                                     limit 1)
                    where id = r.id
                    returning  user_1_id as user_id)
            delete from user_ids ui2
                using update_data ud
            where ui2.user_id = ud.user_id;
            with update_data as (
                update brs.tournament_match
                    set user_2_id = (select user_id
                                     from user_ids
                                     limit 1)
                    where id = r.id
                    returning  user_2_id as user_id)
            delete from user_ids ui
                using update_data ud
            where ui.user_id = ud.user_id;
        END LOOP;
    drop table user_ids;

    -- set all users as "qualified" so we can show that in the future
    update brs.tournament_pool_user
    set qualified = true
    where user_id in ( select unnest(array[ p_user_ids ]::int[] ) )
      and tournament_pool_id = p_tournament_pool_id;

    -- after advancing the qualifiers add all the non-qualified to the loser pool
    with all_pool_users as (
        select tpu.id,
               tpu.user_id,
               concat(u.first_name,' ',u.last_name::text) as full_name,
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
                        concat(upv.first_name,' ',upv.last_name::text) as full_name,
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
                ( select id from brs.tournament_pool where tournament_id = p_tournament_id and tournament_pool_type_id = 2),
                now(), p_user_id
         from all_pool_users apu
         where apu.user_id not in ( select unnest(array[ p_user_ids ]::int[] ) )
           and apu.archived is not true);


END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

