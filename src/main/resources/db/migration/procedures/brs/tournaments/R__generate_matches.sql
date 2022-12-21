drop function if exists brs.generate_matches(p_tournament_bracket_id bigint, p_user_id bigint);
CREATE OR REPLACE FUNCTION brs.generate_matches(p_tournament_bracket_id bigint, p_user_id bigint)
    RETURNS void AS
$BODY$
declare
    v_num_of_users bigint;
    v_round        bigint;
    v_current_id   bigint;
    r              record;
    v_loop_count   bigint;
    v_round_id     bigint;
v_parent_id        bigint;
v_count bigint;
BEGIN

    perform setval('brs.tournament_match_id_seq',
                  COALESCE((SELECT MAX(id) + 1
                            FROM brs.tournament_match), 1), false);

    select coalesce(max(id) + 1, 1)
    into v_current_id
    from brs.tournament_match;

    create temp table matches
    (
        round       bigint,
        starting_id bigint,
        ending_id   bigint
    );

    select number_of_users / 2
    into v_num_of_users
    from brs.tournament_bracket
    where id = p_tournament_bracket_id;
    v_round = 0;
    for r in select *
             from brs.tournament_round tr
             where tr.archived is false
             and tr.tournament_bracket_id = p_tournament_bracket_id
             order by tr.start_date
        loop
            v_round = v_round + 1;
            insert into matches(round, starting_id, ending_id)
            values (v_round, v_current_id, v_current_id + v_num_of_users -1);
            for counter in 1..v_num_of_users
                loop
                    insert into brs.tournament_match(tournament_round_id, date_created, created_by_id)
                    values (r.id, now(), p_user_id);
                end loop;
            v_current_id = v_current_id + v_num_of_users;
            v_num_of_users = v_num_of_users / 2;

        end loop;
    v_loop_count = 0;
    v_round = 2;
    v_round_id = 0;
    for r in select tm.id as tournament_match_id,tm.tournament_round_id
             from brs.tournament_match tm
             inner join brs.tournament_round tr on tm.tournament_round_id = tr.id and
                                                   tr.tournament_bracket_id = p_tournament_bracket_id and
                                                   tr.archived is false
             where tm.archived is false
             order by tm.id
    loop
        v_round_id = r.tournament_round_id;
        if v_round_id != r.tournament_round_id then
            v_round = v_round +1;
        end if;
        v_loop_count = v_loop_count + 1;
        delete from matches where round = 1;

        select starting_id
        into v_parent_id
        from matches
        where round = v_round
        order by round
        limit 1;

        select count(1)
        into v_count
        from brs.tournament_match
        where id = v_parent_id;

        if v_count > 0 then
            update brs.tournament_match tm2
            set parent_match_id = v_parent_id
            where tm2.id = r.tournament_match_id;
        end if;

        if v_loop_count = 2 then
            update matches set starting_id = starting_id + 1
            where round = v_round;
            v_loop_count = 0;
        end if;
    end loop;
    drop table matches;
    update brs.tournament_bracket
        set matches_generated = true
    where id = p_tournament_bracket_id;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Generate Matches', 'p_tournament_bracket_id: ' || p_tournament_bracket_id ||
                                ' p_user_id: '|| p_user_id,
            p_user_id);

END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

