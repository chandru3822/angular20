package com.albatross.api.v1.company.blueraven.services.commissionManagement.queries;

public class ResidualPayrollQuery {

  //language=PostgreSQL
  public final static String snapshotByResidualId = """
    SELECT array_to_json(array_agg(row_to_json(sub_rows)))
    FROM
         (
           SELECT *
           FROM brs.user_residual_snapshot
           WHERE residual_id = :residualId ) AS sub_rows
    """;

  //language=PostgreSQL
  public final static String search = """
    SELECT array_to_json(array_agg(row_to_json(sub_rows)))
    FROM (SELECT r.id,
                 r.description,
                 r.period_end as "periodEnd",
                 (SELECT sum(dcs1.residual_total)
                  FROM brs.user_residual_snapshot dcs1
                  WHERE dcs1.residual_id = r.id) AS "currentPay"
          FROM brs.residual r
                 INNER JOIN brs.user_residual_snapshot dcs ON r.id = dcs.residual_id
                 INNER JOIN flow.user u ON dcs.user_id = u.id
            AND CASE WHEN :userId:: INTEGER IS NOT NULL
                       THEN u.id = :userId:: INTEGER ELSE true END
            AND CASE WHEN :userFirstName::text is not null
                THEN lower(u.first_name) like '%' || lower(:userFirstName::text) || '%' else true end
            AND CASE WHEN :userLastName::text is not null
                       THEN lower(u.last_name) like '%' || lower(:userLastName::text) || '%' else true end
          GROUP BY r.id
          ORDER BY r.paid_date desc

         ) AS sub_rows
    """;

  //language=PostgreSQL
  public final static String getCurrentResidualId = """
    SELECT id
    FROM brs.residual
    WHERE current IS TRUE
    """;

  //language=PostgreSQL
  public final static String getById = """
    SELECT row_to_json(residual) AS residual
    FROM (SELECT p.id,
                 p.paid_date                                               AS "paidDate",
                 p.period_start as "periodStart",
                 p.period_end as "periodEnd",
                 p.grace_period_end as "gracePeriodEnd",
                 p.description,
                 p.selected_user_ids                                       AS "selectedUserIds",
                 ps.payroll_status                                         AS "status",
                 p.current
          FROM brs.residual p
                   INNER JOIN brs.payroll_status ps ON p.payroll_status_id = ps.id
          WHERE p.id = :residualId) residual
    """;


  //language=PostgreSQL
  public final static String getApprovedResiduals = """
    SELECT DISTINCT p.id
    FROM brs.residual p
    WHERE  p.payroll_status_id = 3 -- 3 means APPROVED
    ORDER BY p.id DESC;
    """;

  //language=PostgreSQL
  public final static String getResidualSearchDetail = """
    SELECT array_to_json(array_agg(row_to_json(sub_rows)))
    FROM (
          SELECT
            s.id,
            s.residual_id as "residualId",
            s.user_id as "userId",
            s.user_first_name as "userFirstName",
            s.user_last_name as "userLastName",
            s.employee_id as "employeeId",
            s.region_name as "regionName",
            s.office_name as "officeName",
            s.office_state as "officeState",
            s.user_position_name as "userPositionName",
            s.user_status as "userStatus",
            s.hire_date as "hireDate",
            coalesce(s.current_clawbacks_in_period,0) as "currentClawback",
            coalesce(s.existing_clawbacks, 0) as "existingClawback",
            s.user_full_name as "userFullName",
            s.residual_plan_name as "residualPlanName",
            s.residual_start_date as "residualStartDate",
            s.residual_plan_name as "residualPlanName",
            s.lifetime_qualified_fds as "lifetimeQualifiedFds",
            s.qualified_fdc_in_period as "qualifiedFdcInPeriod",
            s.fdc_not_qualified_in_period as "fdcNotQualifiedInPeriod",
            s.required_fdc_per_month as "requiredFdcPerMonth",
            s.residual_earned as "residualEarned",
            s.percent_of_residual_earned as "percentOfResidualEarned",
            s.potential_residual as "potentialResidual",
            s.earned_residual as "earnedResidual",
            s.adjustment_override as "adjustmentOverride",
            s.residual_total as "residualTotal",
            s.paid_in_period as "paidInPeriod",
            s.date_created as "dateCreated",
            s.created_by_id as "createdById",
            s.date_modified as "dateModified",
            s.modified_by_id as "modifiedById",
            coalesce(s.clawback, 0) as "totalClawback"
          FROM brs.user_residual_snapshot s
                 INNER JOIN flow.user u on u.id = s.user_id
          WHERE residual_id = :residualId
       ) AS sub_rows
    """;

  //language=PostgreSQL
  public final static String addResidualAdjustment = """
    INSERT INTO brs.residual_adjustment (residual_id,
                                        user_id,
                                        amount,
                                        note,
                                        payroll_adjustment_type_id,
                                        created_by_id,
                                        modified_by_id,
                                        date_created)
    VALUES (:residualId, :userId, :amount, :note, :adjustmentTypeId, :createdById, :createdById, now());
    """;

  //language=PostgreSQL
  public final static String getResidualAdjustments = """
    SELECT array_to_json(array_agg(row_to_json(history)))
    FROM (SELECT
           pa.user_id as "userId",
           pa.amount,
           pa.note,
           pat.adjustment_type as "adjustmentType",
           pa.date_created as "created",
           concat(u.first_name, ' ', u.last_name) AS "createdBy"
    FROM brs.residual_adjustment pa
           INNER JOIN brs.payroll_adjustment_type pat ON pa.payroll_adjustment_type_id = pat.id
           INNER JOIN flow."user" u ON pa.created_by_id = u.id
    WHERE residual_id = :residualId
      AND user_id = :userId) history
    """;

  //language=PostgreSQL
  public final static String setStatus = """
    UPDATE brs.residual SET
    payroll_status_id = :payrollStatusId,
    date_modified = now()
    WHERE id = :residualId
    """;

  //language=PostgreSQL
  public final static String status = """
    SELECT p.payroll_status_id
    FROM brs.residual p
    WHERE p.id = :residualId
    """;

  //language=PostgreSQL
  public final static String updateResidual = """
    UPDATE brs.residual
    SET
      description       = :description,
      modified_by_id        = :currentUserId,
      selected_user_ids = coalesce(:userIds::BIGINT[], '{}'::bigint[]),
      date_modified           = now()
    WHERE id = :residualId
    """;


}
