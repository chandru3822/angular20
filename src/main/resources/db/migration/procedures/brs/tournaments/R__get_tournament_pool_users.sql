-- drop function if exists brs.get_tournament_pool_users(p_tournament_id bigint, p_tournament_pool_type_id bigint, p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.get_tournament_pool_users(p_tournament_id bigint, p_tournament_pool_type_id bigint, p_run_by_id bigint)
  RETURNS SETOF json
AS
$BODY$
declare
BEGIN
  RETURN QUERY
    select coalesce((
                      select array_to_json(array_agg(row_to_json(pools)))
                      from (
                             select u.first_name || ' ' || u.last_name                       as "fullName",
                                    u.id                                                     as "userId",
                                    tpu.qualified,
                                    brs.get_tournament_user_score(p_tournament_id, t.tournament_formula_id,
                                                                  tp.start_date,
                                                                  tp.end_date, u.id::bigint) as score
                             from brs.tournament_pool tp
                                    inner join brs.tournament t on tp.tournament_id = t.id
                                    inner join brs.tournament_pool_user tpu on tp.id = tpu.tournament_pool_id
                                    inner join flow.user u on u.id = tpu.user_id
                             where tp.tournament_id = p_tournament_id
                               and tpu.archived is not true
                               and tp.tournament_pool_type_id = p_tournament_pool_type_id
                             union
                             select u.first_name || ' ' || u.last_name                       as "fullName",
                                    u.id                                                     as "userId",
                                    (select case when tm.id is null then false else true end
                                     from brs.tournament_match tm
                                            inner join brs.tournament_round tr on tm.tournament_round_id = tr.id
                                            inner join brs.tournament_bracket tb on tr.tournament_bracket_id = tb.id
                                     where tb.tournament_id = p_tournament_id
                                       and (tm.user_1_id = u.id or tm.user_2_id = u.id)
                                     limit 1
                                    )                                                        as "qualified",
                                    brs.get_tournament_user_score(p_tournament_id, t.tournament_formula_id,
                                                                  tp.start_date,
                                                                  tp.end_date, u.id::bigint) as score
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
                                    inner join flow.company_user_status cus on cus.user_id = u.id
                                    inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.has_access is true and p.company_id = ust.company_id
                             where tp.tournament_id = p_tournament_id
                               and tpu.archived is not true
                               and tp.tournament_pool_type_id = p_tournament_pool_type_id
                               --group by 1, 2, 3, t.tournament_formula_id, tp.start_date, tp.end_date
                             order by 4 desc nulls last, 1) as pools), '[]') as pools;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Get Tournament Pool Users', 'p_tournament_id: ' || p_tournament_id ||
                                         ' p_tournament_pool_type_id: '|| p_tournament_pool_type_id ||
                                         ' p_run_by_id: '|| p_run_by_id,
            p_run_by_id);

END
$BODY$
  LANGUAGE plpgsql VOLATILE;

