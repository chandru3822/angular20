package com.albatross.api.v1.company.blueraven.services.tournament.queries;

public class TournamentPoolQuery {

  //language=PostgreSQL
  public final static String getDetails = """
    select tp.*,
    ( select a.id
            from flow.attachment a
           inner join flow.attachment_source src on a.id = src.attachment_id
           where a.archived is not true
           and a.attachment_type_id = 915
           and src.source_id = tp.id ) as background_attachment_id,
           coalesce((
                    SELECT array_to_json(array_agg(row_to_json(tb)))
                    FROM (
                             SELECT tpp.id,
                                    tpp.position_id as "positionId",
                                    p.position as "position",
                                    tpp.tournament_pool_id as "tournamentPoolId",
                                    tpp.archived
                             FROM brs.tournament_pool_position tpp
                                      inner join flow.position p on tpp.position_id = p.id
                             WHERE tpp.tournament_pool_id = tp.id
                               AND tpp.archived is not true) tb), '[]') AS "positions",
           coalesce((
                        SELECT array_to_json(array_agg(row_to_json(tb)))
                        FROM (
                                 SELECT tpu.id,
                                        tpu.user_id as "userId",
                                        tpu.qualified,
                                        concat(u.first_name, ' ', u.last_name) as "fullName",
                                        tpu.tournament_pool_id as "tournamentPoolId",
                                        tpu.archived
                                 FROM brs.tournament_pool_user tpu
                                    inner join flow."user" u on tpu.user_id = u.id
                                 WHERE tpu.tournament_pool_id = tp.id
                                   AND tpu.archived is not true
                                   order by qualified is not true, "fullName") tb), '[]') AS "users",
           tpt.pool_type
    from brs.tournament_pool tp
      inner join brs.tournament_pool_type tpt on tp.tournament_pool_type_id = tpt.id
    where tp.tournament_id = :tournamentId
    and tp.tournament_pool_type_id = :tournamentPoolTypeId
    """;

  //language=PostgreSQL
  public final static String updatePool = """
    update brs.tournament_pool
    set start_date = :startDate::date,
        end_date = :endDate::date,
        custom_name = :customName,
        modified_by_id = :userId,
        date_modified = now()
    where id = :poolId
    """;

  //language=PostgreSQL
  public final static String getPoolUsers = """
    select *
    from brs.get_tournament_pool_users(:tournamentId::bigint, :tournamentPoolTypeId::bigint, :currentUserId::bigint)
    """;

  //language=PostgreSQL
  public final static String getPosition = """
    select tpp.*,
           p.position
    from brs.tournament_pool_position tpp
    inner join flow.position p on p.id = tpp.position_id
    where tpp.id = :id
    """;

  //language=PostgreSQL
  public final static String addPosition = """
    insert into brs.tournament_pool_position(position_id, tournament_pool_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:positionId, :poolId, :createdById,now(),:createdById, now())
    """;

  //language=PostgreSQL
  public final static String deletePosition = """
    update brs.tournament_pool_position
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
      where id = :tournamentPoolPositionId
    """;

  //language=PostgreSQL
  public final static String getUser = """
    select tpu.*,
           concat(u.first_name, ' ', u.last_name) as full_name
    from brs.tournament_pool_user tpu
    inner join flow.user u on u.id = tpu.user_id
    where tpu.id = :id
    """;

  //language=PostgreSQL
  public final static String addUser = """
    insert into brs.tournament_pool_user(user_id, tournament_pool_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:userId, :poolId, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String deleteUser = """
    update brs.tournament_pool_user
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
      where id = :tournamentPoolUserId
    """;

  //language=PostgreSQL
  public final static String assignUsersToMatches = """
    select from brs.assign_users_to_matches(:tournamentId::bigint, :tournamentPoolId::bigint, :userId::bigint, :seededMatches::jsonb)
    """;

  //language=PostgreSQL
  public final static String advanceUsersToWinnerPool = """
    update brs.tournament_pool_user
          set qualified = true,
              date_modified = now()
      where tournament_pool_id = :tournamentPoolId
      and user_id in ( :userIds );

      insert into brs.tournament_pool_user(user_id, tournament_pool_id, date_created, created_by_id, date_modified, modified_by_id)
        select tpu.user_id, (select id from brs.tournament_pool where tournament_id = :tournamentId and tournament_pool_type_id = 3 ), now(), :userId, now(), :userId
      from brs.tournament_pool_user tpu
      where tpu.tournament_pool_id = :tournamentPoolId
        and tpu.user_id  in ( :userIds );
    """;
}
