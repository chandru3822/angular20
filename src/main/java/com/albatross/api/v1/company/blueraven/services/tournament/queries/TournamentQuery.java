package com.albatross.api.v1.company.blueraven.services.tournament.queries;

public class TournamentQuery {

  //language=PostgreSQL
  public final static String getTournaments = """
    select t.*
    from brs.tournament t
    where archived is not true
    order by t.active is not true, t.tournament_name
    """;

  //language=PostgreSQL
  public final static String getFormulaColumns = """
    select tf.columns
      from brs.tournament_formula tf
      inner join brs.tournament t on tf.id = t.tournament_formula_id
      where t.id = :tournamentId
    """;

  //language=PostgreSQL
  public final static String getUserScores = """
    select * from brs.get_tournament_user_score_drill_down(:tournamentId::bigint, :startDate::date, :endDate::date, :userId::bigint)
    """;

  //language=PostgreSQL
  public final static String getOwnerTypes = """
    select *
    from brs.tournament_owner_type
    where archived is not true
    """;

  //language=PostgreSQL
  public final static String getFormulas = """
    select id,
       formula_title,
       formula_description,
       tournament_owner_type_id,
       date_created,
       date_modified,
       created_by_id,
       modified_by_id,
       active,
       archived
    from brs.tournament_formula
    where archived is not true
    and tournament_owner_type_id = :ownerTypeId
    """;

  //language=PostgreSQL
  public final static String getFormulaFields = """
    select tff.id,
            tff.tournament_formula_id as "tournamentFormulaId",
            tff.field_name as "fieldName",
            tff.archived,
            tff.data_type_id as "dataTypeId"
     from brs.tournament_formula_field tff
     where tff.tournament_formula_id = :formulaId
      and tff.archived is false
      order by tff.display_order
    """;

  //language=PostgreSQL
  public final static String delete = """
    update brs.tournament
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String update = """
    update brs.tournament
    set tournament_name = :tournamentName,
        tournament_owner_type_id = :tournamentOwnerTypeId,
        start_date = :startDate,
        end_date = :endDate,
        active = :active,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insert = """
    with tourney as (insert into brs.tournament(tournament_name, tournament_owner_type_id, start_date, end_date, tournament_formula_id, created_by_id, date_created, modified_by_id, date_modified)
        values(:tournamentName, :tournamentOwnerTypeId, :startDate, :endDate, :tournamentFormulaId, :userId, now(), :userId, now())
        returning id),
         pools as (
             insert into brs.tournament_pool (tournament_id, tournament_pool_type_id, start_date, end_date, created_by_id)
                 values ((select id from tourney), 1, :startDate, :endDate, :userId),
                        ((select id from tourney), 2, :startDate, :endDate, :userId),
                        ((select id from tourney), 3, :startDate, :endDate, :userId)
         )
    select id from tourney
    """;

  //language=PostgreSQL
  public final static String getActiveTournaments = """
    select *
    from brs.tournament t
    where active is true
    and archived is not true
    """;

  //language=PostgreSQL
  public final static String get = """
    select t.*,
        ( select a.id
            from flow.attachment a
           inner join flow.attachment_source src on a.id = src.attachment_id
           where a.archived is not true
           and a.attachment_type_id = 914
           and src.source_id = t.id ) as background_attachment_id,
       coalesce((
                SELECT array_to_json(array_agg(row_to_json(tp)))
                FROM (
                         SELECT tp.id,
                                tp.tournament_id as "tournamentId",
                                tp.tournament_pool_type_id as "tournamentPoolTypeId",
                                tp.archived,
                                tp.start_date as "startDate",
                                tp.end_date as "endDate",
                                tp.advanced,
                                tp.custom_name as "customName"
                         FROM brs.tournament_pool tp
                         WHERE tp.tournament_id = t.id
                           AND tp.archived is not true
                         order by tp.tournament_pool_type_id) tp), '[]') AS "pools",
       coalesce((
          SELECT array_to_json(array_agg(row_to_json(tb)))
          FROM (
               SELECT tb.id,
                      tb.tournament_id as "tournamentId",
                      tb.matches_generated as "matchesGenerated",
                      tb.number_of_users as "numberOfUsers",
                      tb.archived,
                      coalesce((
                         SELECT array_to_json(array_agg(row_to_json(tb)))
                         FROM (
                                  SELECT tr.id,
                                         tr.tournament_bracket_id as "tournamentBracketId",
                                         tr.advanced,
                                         tr.start_date as "startDate",
                                         tr.end_date as "endDate",
                                         tr.archived,
                                         row_number() over (order by tr.start_date) as "roundNumber",
                                         coalesce((
                                            SELECT array_to_json(array_agg(row_to_json(tb)))
                                            FROM (
                                                     SELECT tm.id,
                                                            tm.tournament_round_id as "tournamentRoundId",
                                                            tm.parent_match_id as "parentMatchId",
                                                            tm.match_advanced as "matchAdvanced",
                                                            tm.user_1_id as "user1Id",
                                                            tm.user_1_score as "user1Score",
                                                            concat(u1.first_name, ' ', u1.last_name) as "user1Name",
                                                            tm.user_2_id as "user2Id",
                                                            tm.user_2_score as "user2Score",
                                                            concat(u2.first_name, ' ', u2.last_name) as "user2Name",
                                                            tm.archived
                                                     FROM brs.tournament_match tm
                                                       left join flow."user" u1 on u1.id = tm.user_1_id
                                                       left join flow."user" u2 on u2.id = tm.user_2_id
                                                     WHERE tm.tournament_round_id = tr.id
                                                       AND tm.archived is not true
                                                     order by tm.id) tb), '[]') AS "matches"
                                  FROM brs.tournament_round tr
                                  WHERE tr.tournament_bracket_id = tb.id
                                    AND tr.archived is not true
                                    order by tr.start_date) tb), '[]') AS "rounds"
               FROM brs.tournament_bracket tb
               WHERE tb.tournament_id = t.id
                 AND tb.archived is not true
           ) tb), '[]') AS "brackets",
                      coalesce((
                      SELECT array_to_json(array_agg(row_to_json(fields)))
                      FROM (
                             select tff.id,
                                    tff.tournament_formula_id as "tournamentFormulaId",
                                    tff.field_name as "fieldName",
                                    tff.archived,
                                    tff.data_type_id as "dataTypeId",
                                    tffv.field_value as "fieldValue",
                                    tffv.tournament_id as "tournamentId",
                                    tffv.id as "fieldValueId"
                             from brs.tournament_formula_field tff
                                    left join brs.tournament_formula_field_value tffv
                                              on tff.id = tffv.tournament_formula_field_id
                                              and tffv.tournament_id = t.id
                             where tff.tournament_formula_id = t.tournament_formula_id
                              order by tff.display_order
                           ) fields), '[]') AS "tournamentFormulaFields"
      from brs.tournament t
      where id = :id
    """;

  //language=PostgreSQL
  public final static String getBrackets = """
    select *
        from brs.get_tournament_brackets(:tournamentId::bigint, :currentUserId::bigint)
    """;

  //language=PostgreSQL
  public final static String getBracket = """
    SELECT tb.id,
       tb.tournament_id as "tournamentId",
       tb.matches_generated,
       tb.number_of_users as "numberOfUsers",
       tb.archived,
       coalesce((
                    SELECT array_to_json(array_agg(row_to_json(tb)))
                    FROM (
                             SELECT tr.id,
                                    tr.advanced,
                                    tr.tournament_bracket_id as "tournamentBracketId",
                                    tr.start_date as "startDate",
                                    tr.end_date as "endDate",
                                    tr.archived,
                                    row_number() over (order by tr.start_date) as "roundNumber",
                                    coalesce((
                                                 SELECT array_to_json(array_agg(row_to_json(tb)))
                                                 FROM (
                                                          SELECT tm.id,
                                                                 tm.tournament_round_id as "tournamentRoundId",
                                                                 tm.parent_match_id as "parentMatchId",
                                                                 tm.match_advanced as "matchAdvanced",
                                                                 tm.user_1_id as "user1Id",
                                                                 tm.user_1_score as "user1Score",
                                                                 concat(u1.first_name, ' ', u1.last_name) as "user1Name",
                                                                 tm.user_2_id as "user2Id",
                                                                 tm.user_2_score as "user2Score",
                                                                 concat(u2.first_name, ' ', u2.last_name) as "user2Name",
                                                                 tm.archived
                                                          FROM brs.tournament_match tm
                                                                   left join flow."user" u1 on u1.id = tm.user_1_id
                                                                   left join flow."user" u2 on u2.id = tm.user_2_id
                                                          WHERE tm.tournament_round_id = tr.id
                                                            AND tm.archived is not true
                                                          order by tm.id) tb), '[]') AS "matches"
                             FROM brs.tournament_round tr
                             WHERE tr.tournament_bracket_id = tb.id
                               AND tr.archived is not true
                             order by tr.start_date) tb), '[]') AS "rounds"
      FROM brs.tournament_bracket tb
      WHERE tb.id = :id
    """;

  //language=PostgreSQL
  public final static String deleteBracket = """
    update brs.tournament_bracket
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String addBracket = """
    insert into brs.tournament_bracket(tournament_id, number_of_users, created_by_id, date_created, modified_by_id, date_modified)
    values (:tournamentId, :numberOfUsers, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String deleteRound = """
    update brs.tournament_round
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String addRound = """
    insert into brs.tournament_round(start_date, end_date, tournament_bracket_id, created_by_id, date_created, modified_by_id, date_modified)
    values(:startDate, :endDate, :bracketId, :userId, now(), :userId, now())
    """;

  //language=PostgreSQL
  public final static String updateRound = """
    update brs.tournament_round
    set start_date = :startDate,
        end_date = :endDate,
        date_modified = now(),
        modified_by_id = :userId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String generateMatches = """
    select from brs.generate_matches(:bracketId::bigint, :userId::bigint)
    """;

  //language=PostgreSQL
  public final static String advanceWinners = """
    update brs.tournament_match
        set date_modified = now(),
          user_1_score = :user1Score,
          user_2_score = :user2Score,
          modified_by_id = :userId,
          match_advanced = true
    where id = :matchId;
    update brs.tournament_round
        set date_modified = now(),
          modified_by_id = :userId,
          advanced = true
    where id = :roundId;
    insert into brs.tournament_pool_user(user_id, tournament_pool_id, date_created, created_by_id, date_modified, modified_by_id)
    select user_1_id, (select id from brs.tournament_pool where tournament_id = :tournamentId and tournament_pool_type_id = 3 ), now(), :userId, now(), :userId
    from brs.tournament_match tm where id = :matchId;
    insert into brs.tournament_pool_user(user_id, tournament_pool_id, date_created, created_by_id, date_modified, modified_by_id)
    select user_2_id, (select id from brs.tournament_pool where tournament_id = :tournamentId and tournament_pool_type_id = 3 ), now(), :userId, now(), :userId
    from brs.tournament_match tm where id = :matchId;
    """;

  //language=PostgreSQL
  public final static String advanceMatch = """
    update brs.tournament_match
      set user_1_id = :winnerUserId,
          date_modified = now(),
          modified_by_id = :userId
    where id = :parentMatchId
      and (select id from brs.tournament_match where parent_match_id = :parentMatchId and id != :matchId) > :matchId;
    update brs.tournament_match
        set user_2_id = :winnerUserId,
          date_modified = now(),
          modified_by_id = :userId
    where id = :parentMatchId
      and (select id from brs.tournament_match where parent_match_id = :parentMatchId and id != :matchId) < :matchId;
    update brs.tournament_round
        set date_modified = now(),
          modified_by_id = :userId,
          advanced = true
    where id = (select tournament_round_id from brs.tournament_match where id = :matchId);
    update brs.tournament_match
        set date_modified = now(),
          user_1_score = :user1Score,
          user_2_score = :user2Score,
          modified_by_id = :userId,
          match_advanced = true
    where id = :matchId;
    """;

  //language=PostgreSQL
  public final static String insertLoserToLastChance = """
    insert into brs.tournament_pool_user(user_id, tournament_pool_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:loserUserId, (select id from brs.tournament_pool where tournament_id = :tournamentId and tournament_pool_type_id = 2), :userId, now(), :userId, now())
    """;

  //language=PostgreSQL
  public final static String overrideMatchUser1 = """
    update brs.tournament_match
    set user_1_id = :userId,
        date_modified = now(),
        modified_by_id = :currentUserId
    where id = :matchId
    """;

  //language=PostgreSQL
  public final static String overrideMatchUser2 = """
    update brs.tournament_match
    set user_2_id = :userId,
        date_modified = now(),
        modified_by_id = :currentUserId
    where id = :matchId
    """;

  //language=PostgreSQL
  public final static String saveFieldValue = """
    insert into brs.tournament_formula_field_value(field_value, tournament_formula_field_id, tournament_id, created_by_id)
    values (:fieldValue::text, :fieldId, :tournamentId, :userId)
    on conflict (tournament_formula_field_id, tournament_id)
    do update set field_value = :fieldValue::text,
                  date_modified = now(),
                  modified_by_id = :userId
    """;
}
