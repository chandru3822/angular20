package com.albatross.api.v1.company.blueraven.services.commissionManagement.queries;

public class ResidualQuery {

  //todo: not sure what this date is for
  //language=PostgreSQL
  public final static String getAll = """
    select *
    from brs.get_residual_account_details()
    """;

  //language=PostgreSQL
  public final static String getProjects = """
      select p.project_id as id,
             p.project_name,
             concat(p.project_name, ' - ', p.project_id) as project_name_with_id
      from brs.project_details p
      where p.archived is false
        and p.cancelled_date is null
        and p.closer_user_position_id is not null
        and case when :search::text is not null then
                       lower(translate(p.project_name, '*,.&', '')) like '%' || lower(trim(translate(:search::text, '*,.&', ''))) || '%'
                     OR p.project_id::text like '%' || lower(trim(translate(:search::text, '*,.&', ''))) || '%' else 1=1 end
        and not exists (
          select project_id
          from brs.residual_project_override_qualified_date rpoqd
          where p.project_id = rpoqd.project_id
        )
      order by p.project_name
      limit 20
    """;


  //language=PostgreSQL
  public final static String addProjectOverride = """
    insert into brs.residual_project_override_qualified_date(project_id, override_qualified_date, date_created, created_by_id)
    values (:projectId, :overrideDate::date, now(), :userId)
    """;

  //language=PostgreSQL
  public final static String deleteProjectQualified = """
    delete from brs.residual_project_qualified_date
    where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String getCurrentClawbacks = """
    select gcrc.user_id,
           gcrc.project_id,
           pd.project_name,
           pd.cancelled_date,
           gcrc.clawback_date,
           gcrc.amount as clawback_amount
    from  brs.get_current_residual_clawbacks(:userId) gcrc
    inner join brs.project_details pd on pd.project_id = gcrc.project_id
    """;

  //language=PostgreSQL
  public final static String getResidualQualifiedLifetimeFds = """
    select *
    from brs.get_residual_qualified_lifetime_fds(:userId::bigint)
    """;

  //language=PostgreSQL
  public final static String getResidualQualifiedFdsThisPeriod = """
    select *
    from brs.get_residual_fds_qualified_this_period(:userId::bigint)
    """;

  //language=PostgreSQL
  public final static String getResidualNotQualifiedFdsThisPeriod = """
    select *
    from brs.get_residual_fds_not_qualified_this_period(:userId::bigint)
    """;

  //language=PostgreSQL
  public final static String getSnapshotFdc = """
    select *
    from brs.get_user_residual_project_snapshot_by_type(:residualId::bigint, :userId::bigint,
                                               :snapshotTypeId::bigint)
    """;

  //language=PostgreSQL
  public final static String getAllPlans = """
    select rp.id,
           rp.name,
           rp.residual_plan_status_id,
           rps.status_type,
           rp.approved_date,
           rp.description,
           rp.notes
    from brs.residual_plan rp
           inner join brs.residual_plan_status rps on rps.id = rp.residual_plan_status_id
    """;

  //language=PostgreSQL
  public final static String getResidualPlanDetails = """
    SELECT row_to_json(sub_rows) sub_rows
                                          FROM (SELECT rp.id,
                                                       rps.status_type as "statusType",
                                                       rp.name,
                                                       rp.total,
                                                       rp.residual_duration_months as "residualDurationMonths",
                                                       rp.is_system_size as "isSystemSize",
                                                       rp.description,
                                                       rp.residual_plan_status_id as "residualPlanStatusId",
                                                       concat(cu.first_name, ' ', cu.last_name) AS "createdName",
                                                       concat(au.first_name, ' ', au.last_name) AS "approvedName",
                                                       rp.created_by_id as "createdById",
                                                       rp.approved_date                                                 AS "approvedDate",
                                                       coalesce((SELECT array_to_json(array_agg(row_to_json(allocations)))
                                                                 FROM (
                                                                        select rpa.id,
                                                                               rpa.residual_plan_id as "residualPlanId",
                                                                               rpa.min,
                                                                               rpa.max,
                                                                               rpa.allocation,
                                                                               rppa.fdc_count as "fdcCount",
                                                                               rppa.partial_allocation as "partialAllocation",
                                                                               rppat.residual_plan_partial_allocation_type as "residualPlanPartialAllocationType"
                                                                        from brs.residual_plan_allocation rpa
                                                                          left join brs.residual_plan_partial_allocation rppa on rppa.residual_plan_allocation_id = rpa.id
                                                                          left join brs.residual_plan_partial_allocation_type rppat on rppa.residual_plan_partial_allocation_type_id = rppat.id
                                                                        where rpa.residual_plan_id = rp.id
                                                                        order by rpa.min, rppa.fdc_count
                                                                      ) AS allocations), '[]') AS "residualPlanAllocations",
                                                                      coalesce((SELECT array_to_json(array_agg(row_to_json(sources)))
                                                                      FROM (SELECT cpsa.id,
                                                                                   cpsa.amount,
                                                                                   lov.name as "sourceName",
                                                                                   cpsa.source_id as "sourceId"
                                                                            FROM brs.residual_plan_source_allocation cpsa
                                                                                INNER JOIN flow.list_of_value lov on lov.id = cpsa.source_id
                                                                            WHERE cpsa.residual_plan_id = rp.id
                                                                     ) AS sources), '[]')    AS sources,
                                                       coalesce((SELECT array_to_json(array_agg(row_to_json(users)))
                                                                 FROM (SELECT rpu.id,
                                                                              concat(u.first_name, ' ', u.last_name) AS name,
                                                                              u.id                               AS "userId",
                                                                              rpu.start_date                     AS "startDate",
                                                                              rpu.end_date                       AS "endDate",
                                                                              false                              as "archived",
                                                                              (select cfv.text_value
                                                                                  from flow.user_custom_field_value cfv
                                                                                         inner join flow.custom_field_group_assignment cfga on cfv.custom_field_group_assignment_id = cfga.id
                                                                                  where cfga.custom_field_id  = 454
                                                                                    and cfga.archived is false
                                                                                   and cfv.user_id = rpu.user_id ) as "employeeId"
                                                                       FROM brs.residual_plan_user rpu
                                                                              INNER JOIN flow.user u ON rpu.user_id = u.id
                                                                       WHERE rpu.residual_plan_id = rp.id
                                                                       GROUP BY rpu.id, u.id
                                                                       order by name ) AS users), '[]')                    AS users
                                                FROM brs.residual_plan rp
                                                       INNER JOIN brs.residual_plan_status rps ON rp.residual_plan_status_id = rps.id
                                                       LEFT JOIN flow.user cu ON rp.created_by_id = cu.id
                                                       LEFT JOIN flow.user au ON rp.approved_by_id = au.id
                                                WHERE rp.id = :planId) sub_rows;
    """;


  //language=PostgreSQL
  public final static String findUsers = """
    SELECT coalesce(array_to_json(array_agg(row_to_json(results))), '[]')
    FROM (SELECT DISTINCT u.id                               AS "userId",
                          concat(u.first_name, ' ', u.last_name) AS name,
                          u.email
          FROM flow."user" u
          WHERE u.id IN (SELECT up.user_id
                         FROM flow.user_position up
                                INNER JOIN flow.position p ON p.id = up.position_id
                         WHERE (
                                 p.id = any (select unnest(cf.system_list_option_ids)
                                                         from flow.custom_field cf
                                                         where cf.parent_custom_field_id = 9959 and cf.company_id = 3)
                              ))
            AND (
                concat(lower(first_name), ' ', lower(last_name)) LIKE lower(:search)
              OR lower(last_name) LIKE lower(:search)
              OR lower(u.email) LIKE lower(:search)
            )
            and ( case when :planId::bigint is not null
                         then u.id not in (
              select user_id
              from brs.residual_plan_user rpu
              where residual_plan_id = :planId
            ) else 1 = 1 end
            )
          ORDER BY name
          LIMIT 10) results

    """;

  //language=PostgreSQL
  public final static String createPlan = """
    insert into brs.residual_plan(name, residual_plan_status_id, position_id, created, created_by_id, description)
    values(:name, 1, 1, now(), :createdById, :description)
    """;

  //language=PostgreSQL
  public final static String updatePlan = """
    update brs.residual_plan
        set name = :name,
            description = :description
    where id = :id
    returning id
    """;

  //language=PostgreSQL
  public final static String getResidualPlanUserHistory = """
    SELECT coalesce(array_to_json(array_agg(row_to_json(aup))), '[]')
    FROM (SELECT rpu.id as "userPlanId",
                 rpu.start_date  AS "startDate",
                 rpu.end_date    AS "endDate",
                 rp.name         ,
                 rps.status_type AS status,
                 rp.residual_plan_status_id    AS residualPlanStatusId,
                 rp.id
          FROM brs.residual_plan_user rpu
                   INNER JOIN brs.residual_plan rp ON rpu.residual_plan_id = rp.id
                   INNER JOIN brs.residual_plan_status rps ON rp.residual_plan_status_id = rps.id
          WHERE rpu.user_id = :userId
          ORDER BY rpu.end_date DESC) aup;
    """;

  //language=PostgreSQL
  public final static String updatePlanUser = """
    UPDATE brs.residual_plan_user
    SET start_date = :startDate,
      end_date     = :endDate
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String insertPlanEndDate = """
    WITH active_residual_plans AS (SELECT rpu.id,
                                            rp.id   AS plan_id,
                                            rp.name AS plan_name,
                                            rpu.user_id,
                                            rpu.start_date,
                                            rpu.end_date
                                     FROM brs.residual_plan rp
                                            INNER JOIN brs.residual_plan_user rpu ON rp.id = rpu.residual_plan_id
                                     WHERE rp.residual_plan_status_id <> 3
                                       AND rpu.end_date IS NULL
                                       AND rpu.start_date <= :startDate
                                       AND rpu.user_id = :userId)
    UPDATE brs.residual_plan_user rpu
    SET end_date = :startDate :: DATE - INTERVAL  '1 day'
    FROM active_residual_plans p
    WHERE rpu.id = p.id
    """;

  //language=PostgreSQL
  public final static String insertPlanUser = """
    INSERT INTO brs.residual_plan_user (residual_plan_id, user_id, start_date, end_date, date_created, created_by_id, modified_by_id)
    VALUES (:planId, :userId, :startDate, :endDate, now(), :currentUserId, :currentUserId)
    """;

  //language=PostgreSQL
  public final static String updateUserResidualPlans = """
    update brs.user_residual ur
    set residual_plan_id = :planId,
        date_modified = now(),
        modified_by_id = :currentUserId
    where user_id = :userId
    """;

  //language=PostgreSQL
  public final static String getResidualPlanUsers = """
    SELECT coalesce(array_to_json(array_agg(row_to_json(users))), '[]')
    FROM (SELECT rpu.id,
                 concat(u.first_name, ' ', u.last_name) AS name,
                 u.id                               AS "userId",
                 rpu.start_date                     AS "startDate",
                 rpu.end_date                       AS "endDate"
          FROM brs.residual_plan_user rpu
                   INNER JOIN brs.residual_plan rp ON rpu.residual_plan_id = rp.id
                   INNER JOIN flow.user u ON rpu.user_id = u.id
          WHERE rp.id = :planId
          GROUP BY rpu.id, u.id) AS users
    """;

  //language=PostgreSQL
  public final static String deletePlan = """
    DELETE
      FROM brs.residual_plan_user
      WHERE residual_plan_id = :planId;

    DELETE
      FROM brs.residual_plan_allocation
      WHERE residual_plan_id = :planId;

     DELETE
      FROM brs.residual_plan
     WHERE id = :planId;
    """;

  //language=PostgreSQL
  public final static String approvePlan = """
    UPDATE brs.residual_plan
    SET approved_date  = now(),
      approved_by_id = :approvedById,
      residual_plan_status_id   = :statusId
    WHERE id = :planId
    """;

  //language=PostgreSQL
  public final static String getResidualPlanAllocation = """
    SELECT row_to_json(allocation) AS allocation
    FROM (select rpa.id,
       rpa.residual_plan_id as "residualPlanId",
       rpa.name,
       rpa.level,
       rpa.total,
       rpa.nbr_fdc_lower as "nbrFdcLower",
       rpa.nbr_fdc_upper as "nbrFdcUpper"
    from brs.residual_plan_allocation rpa
    where rpa.id = :id
  ) allocation
  """;

  //language=PostgreSQL
  public final static String insertAllocation = """
    INSERT INTO brs.residual_plan_allocation (name, level, total, residual_plan_id, nbr_fdc_lower, nbr_fdc_upper, created, created_by_id)
    VALUES (:name, :level, :total, :planId, :nbrFdcLower, :nbrFdcUpper, now(), :createdById)
    """;

  //language=PostgreSQL
  public final static String updateAllocation = """
    UPDATE brs.residual_plan_allocation
    SET  name = :name,
         level = :level,
         total = :total,
         nbr_fdc_lower = :nbrFdcLower,
         nbr_fdc_upper = :nbrFdcUpper
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String removeAllocation = """
    DELETE
      FROM brs.residual_plan_allocation
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String clonePlan = """
    SELECT clone_residual_plan AS id
    FROM brs.clone_residual_plan(:planId::bigint, :startDate::DATE, :users::bigint[], :createdBy::bigint)
    """;

    //language=PostgreSQL
    public final static String getSource = """
    SELECT cpsa.id,
           lov.name as "sourceName",
           cpsa.amount,
           cpsa.source_id as "sourceId"
    FROM brs.residual_plan_source_allocation cpsa
         INNER JOIN flow.list_of_value lov on lov.id = cpsa.source_id
    WHERE cpsa.id = :id
    """;

    //language=PostgreSQL
    public final static String saveSource = """
    INSERT INTO brs.residual_plan_source_allocation (residual_plan_id, amount, source_id)
    VALUES (:planId, :amount, :sourceId)
    """;

    //language=PostgreSQL
    public final static String updateSource = """
    UPDATE brs.residual_plan_source_allocation
     SET
        amount = :amount
     WHERE id = :id
    """;

    //language=PostgreSQL
    public final static String removeSource = """
    DELETE
      FROM brs.residual_plan_source_allocation
       WHERE id = :id
    """;

    //language=PostgreSQL
    public final static String getAvailableSources = """
    with t1 as (select lov.id
            from flow.list_of_value lov
            where lov.parent_id = 5
              and lov.archived is not true
                except select source_id
            from brs.residual_plan_source_allocation
            where residual_plan_id = :planId)
        select lov.id,
               lov.name as source_name
        from flow.list_of_value lov
            inner join t1 on t1.id = lov.id
        where lov.parent_id = 5
          and lov.archived is not true
        order by lov.name
    """;
}
