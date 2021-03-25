CREATE OR REPLACE FUNCTION brs.get_tournament_pool_users(p_tournament_id integer, p_tournament_pool_type_id integer)
    RETURNS SETOF json
AS
$BODY$
declare
BEGIN
    RETURN QUERY select coalesce((select array_to_json(array_agg(row_to_json(pools)))
                                  from (
                                           select u.first_name || ' ' || u.last_name                        as "fullName",
                                                  u.id                                                      as "userId",
                                                  tpu.qualified,
                                                  brs.get_tournament_user_score(t.tournament_formula_id, tp.start_date,
                                                                                tp.end_date, u.id::integer) as score
                                           from brs.tournament_pool tp
                                                    inner join brs.tournament t on tp.tournament_id = t.id
                                                    inner join brs.tournament_pool_user tpu on tp.id = tpu.tournament_pool_id
                                                    inner join flow.user u on u.id = tpu.user_id
                                           where tp.tournament_id = p_tournament_id
                                             and tp.tournament_pool_type_id = p_tournament_pool_type_id
                                           union
                                           select u.first_name || ' ' || u.last_name                        as "fullName",
                                                  u.id                                                      as "userId",
                                                  (select case when tm.id is null then false else true end
                                                   from brs.tournament_match tm
                                                            inner join brs.tournament_round tr on tm.tournament_round_id = tr.id
                                                            inner join brs.tournament_bracket tb on tr.tournament_bracket_id = tb.id
                                                   where tb.tournament_id = 3
                                                     and (tm.user_1_id = u.id or tm.user_2_id = u.id)
                                                   limit 1
                                                  )                                                         as "qualified",
                                                  brs.get_tournament_user_score(t.tournament_formula_id, tp.start_date,
                                                                                tp.end_date, u.id::integer) as score
                                           from brs.tournament_pool tp
                                                    inner join brs.tournament t on tp.tournament_id = t.id
                                                    inner join brs.tournament_pool_position tpu on tp.id = tpu.tournament_pool_id
                                                    inner join flow.position p on p.id = tpu.position_id
                                                    inner join flow.user_position up on up.position_id = p.id and
                                                                                        (up.start_date <= now() and
                                                                                         (up.end_date IS NULL OR up.end_date > now())) and
                                                                                        up.primary_flag is true and
                                                                                        up.archived is not true
                                                    inner join flow.user u on u.id = up.user_id
                                           where tp.tournament_id = p_tournament_id
                                             and tp.tournament_pool_type_id = p_tournament_pool_type_id
                                           group by 1, 2, 3, t.tournament_formula_id, tp.start_date, tp.end_date
                                           order by 4 desc nulls last, 1) as pools), '[]') as pools;
END
$BODY$
    LANGUAGE plpgsql VOLATILE;

