CREATE OR REPLACE FUNCTION brs.get_tournament_brackets(p_tournament_id integer)
    RETURNS SETOF json
AS
$BODY$
declare
BEGIN
    RETURN QUERY select array_to_json(array_agg(row_to_json(brackets)))
                 from (
                          select tb.id                         as "tournamentBracketId",
                                 tb.tournament_id              as "tournamentId",
                                 tb.matches_generated          as "matchesGenerated",
                                 tb.archived,
                                 tb.number_of_users            as "numberOfUsers",
                                 (select array_to_json(array_agg(row_to_json(tournament_rounds)))
                                  from (
                                           select tr.id,
                                                  tr.tournament_bracket_id                   as "tournamentBracketId",
                                                  tr.start_date                              as "startDate",
                                                  tr.end_date                                as "endDate",
                                                  tr.advanced,
                                                  tr.archived,
                                                  row_number() over (order by tr.start_date) as "roundNumber",
                                                  (select array_to_json(array_agg(row_to_json(tournament_matches)))
                                                   from (
                                                            select tm.id,
                                                                   tm.parent_match_id                                             as "parentMatchId",
                                                                   tm.user_1_id                                                   as "user1Id",
                                                                   u1.first_name || ' ' || u1.last_name                           as "user1Name",
                                                                   case
                                                                       when tm.user_1_id is not null then
                                                                           (coalesce(tm.user_1_score,
                                                                                     brs.get_tournament_user_score(
                                                                                             t.tournament_formula_id,
                                                                                             tr.start_date, tr.end_date,
                                                                                             array [ tm.user_1_id ]::int[]))) end as "user1Score",
                                                                   tm.user_2_id                                                   as "user2Id",
                                                                   u2.first_name || ' ' || u2.last_name                           as "user2Name",
                                                                   case
                                                                       when tm.user_1_id is not null then
                                                                           (coalesce(tm.user_2_score,
                                                                                     brs.get_tournament_user_score(
                                                                                             t.tournament_formula_id,
                                                                                             tr.start_date, tr.end_date,
                                                                                             array [ tm.user_2_id ]::int[]))) end as "user2Score"
                                                            from brs.tournament_match tm
                                                                     left join flow.user u1 on u1.id = tm.user_1_id
                                                                     left join flow.user u2 on u2.id = tm.user_2_id
                                                            where tm.tournament_round_id = tr.id
                                                              and tm.archived is false
                                                            order by tm.id
                                                        ) as tournament_matches)                matches
                                           from brs.tournament_round tr
                                           where tr.tournament_bracket_id = tb.id
                                             and tr.archived is false
                                           order by tr.start_date
                                       ) as tournament_rounds) as rounds
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



