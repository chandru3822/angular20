CREATE OR REPLACE FUNCTION brs.get_tournament_brackets(p_tournament_id integer)
    RETURNS SETOF json
AS
$BODY$
declare
BEGIN
    RETURN QUERY select array_to_json(array_agg(row_to_json(brackets)))
                 from (
                          select tb.id                         as tournament_bracket_id,
                                 tb.number_of_users,
                                 (select array_to_json(array_agg(row_to_json(tournament_rounds)))
                                  from (
                                           select tr.id as                       tournament_round_id,
                                                  tr.start_date,
                                                  tr.end_date,
                                                  (select array_to_json(array_agg(row_to_json(tournament_matches)))
                                                   from (
                                                            select tm.parent_match_id,
                                                                   tm.user_1_id,
                                                                   u1.first_name || ' ' || u1.last_name as user_1_name,
                                                                   (coalesce(tm.user_1_score,brs.get_tournament_user_score(tm.id,tr.start_date,tr.end_date,tm.user_1_id))) as user_1_score,
                                                                   tm.user_2_id,
                                                                   u2.first_name || ' ' || u2.last_name as user_2_name,
                                                                   (coalesce(tm.user_2_score,brs.get_tournament_user_score(tm.id,tr.start_date,tr.end_date,tm.user_2_id))) as user_2_score
                                                            from brs.tournament_match tm
                                                                     left join flow.user u1 on u1.id = tm.user_1_id
                                                                     left join flow.user u2 on u2.id = tm.user_2_id
                                                            where tm.tournament_round_id = tr.id
                                                              and tm.archived is false
                                                        ) as tournament_matches) tournament_matches
                                           from brs.tournament_round tr
                                           where tr.tournament_bracket_id = tb.id
                                             and tr.archived is false
                                       ) as tournament_rounds) as tournament_rounds
                          from brs.tournament t
                                   inner join brs.tournament_formula tf
                                              on tf.id = t.tournament_formula_id and tf.archived is false
                                   inner join brs.tournament_bracket tb
                                              on t.id = tb.tournament_id and tb.archived is false
                          where t.id = p_tournament_id
                            and t.archived is false) as brackets;
END
$BODY$
    LANGUAGE plpgsql VOLATILE;



