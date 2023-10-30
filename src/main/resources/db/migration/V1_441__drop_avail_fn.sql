drop function if exists flow.get_availability(p_start_time timestamp, p_end_time timestamp, p_org_ids bigint[],
                                              p_user_ids bigint[]);

DROP FUNCTION IF EXISTS brs.get_closer_availability(p_start_time timestamp, p_end_time timestamp,
                                                    p_round_robin_user_ids bigint[], p_run_by_id bigint);
