drop function if exists brs.copy_residual_snapshot_to_ledger(
  IN p_residual_id bigint,
  IN p_updated_by_id bigint);
CREATE OR REPLACE FUNCTION brs.copy_residual_snapshot_to_ledger(
  IN p_residual_id bigint,
  IN p_updated_by_id bigint)
  RETURNS BOOLEAN
  LANGUAGE plpgsql AS
$BODY$
DECLARE
  d                RECORD;
  v_clawback_id bigint;
v_amount numeric;
BEGIN
  FOR d IN
    SELECT urs.user_id, urps.total, urps.project_id, urs.residual_id
    FROM brs.user_residual_snapshot urs
           inner join brs.user_residual_project_snapshot urps on urps.user_residual_snapshot_id = urs.id
           inner join brs.user_residual_project_snapshot_type urpst
                      on urpst.id = urps.user_residual_project_snapshot_type_id and
                         urpst.user_residual_project_snapshot_code = 'LIFETIME_QUALIFIED_FDS'
    WHERE urs.residual_id = p_residual_id
      and urs.paid_in_period is true
    LOOP
      insert into brs.residual_ledger(project_id,
                                      user_id,
                                      ledger_type_id,
                                      amount,
                                      note,
                                      residual_id,
                                      date_created,
                                      created_by_id,
                                      date_modified,
                                      modified_by_id)
      values (d.project_id,
              d.user_id,
              (select id from brs.ledger_type as lt where lt.ledger_type = 'RESIDUAL'),
              d.total,
              'Residuals',
              d.residual_id,
              now(),
              p_updated_by_id,
              now(),
              p_updated_by_id);

    END LOOP;

  for d in SELECT urs.*
           FROM brs.user_residual_snapshot urs
           where urs.current_clawbacks_in_period > 0
          and urs.residual_id = p_residual_id
    loop
      v_clawback_id = null;
      select rc.id
      into v_clawback_id
      from brs.residual_clawback rc
      where rc.user_id = d.user_id;


      if v_clawback_id is not null then
        update brs.residual_clawback c
        set clawback_due     = coalesce(c.clawback_due,0) + coalesce(d.current_clawbacks_in_period,0),
            modified_by_id =  p_updated_by_id ,
            date_modified = now()
        where user_id = d.user_id;
      else
        insert into brs.residual_clawback(user_id, clawback_due, applied_clawback, date_created, created_by_id,
                                          date_modified, modified_by_id)
        values (d.user_id, coalesce(d.current_clawbacks_in_period,0),0, now(),
                p_updated_by_id, now(), p_updated_by_id);
      end if;

    end loop;


  for d in SELECT urs.*
           FROM brs.user_residual_snapshot urs
           where  clawback > 0
             and urs.residual_id = p_residual_id
    loop

      select rc.id
      into v_clawback_id
      from brs.residual_clawback rc
      where rc.user_id = d.user_id;

      if d.paid_in_period is not true then
        v_amount = 0;
        --adjustments that have clawbacks but not no residuals were earned and adjustments are greater than the clawback
      elsif d.paid_in_period is true and coalesce(d.earned_residual,0) = 0 and
            coalesce(d.adjustment_override,0) > 0 and coalesce(d.clawback,0) > 0 and
            d.adjustment_override >= d.clawback then
        v_amount = d.clawback;
        --adjustments that have clawbacks but not no residuals were earned and adjustments are less than the clawback
      elsif d.paid_in_period is true and coalesce(d.earned_residual,0) = 0 and
            coalesce(d.adjustment_override,0) > 0 and coalesce(d.clawback,0) > 0 and
            d.adjustment_override < d.clawback then
        v_amount = d.adjustment_override;
        --have earned residuals and the clawbacks are greater than the earned residuals
      elsif d.paid_in_period is true and coalesce(d.clawback,0) > (coalesce(d.earned_residual,0) + coalesce(d.adjustment_override,0)) and
            coalesce(d.earned_residual,0) + coalesce(d.adjustment_override,0) > 0 then
        v_amount = d.earned_residual + coalesce(d.adjustment_override,0);
        --have earned residuals and the clawbacks are less than the earned residuals
      elsif d.paid_in_period is true and (coalesce(d.earned_residual,0)  + coalesce(d.adjustment_override,0)) >= coalesce(d.clawback,0) and
            coalesce(d.clawback,0) > 0 then
        v_amount = coalesce(d.clawback,0);
        --there aren't any earned residuals to payback the clawbacks
      elsif d.paid_in_period is true and coalesce(d.clawback,0) > 0 and coalesce(d.earned_residual,0) < 1 then
        v_amount = 0;
      end if;



      if v_clawback_id is not null then
        update brs.residual_clawback c
        set applied_clawback = coalesce(applied_clawback,0) + v_amount
        where user_id = d.user_id;
      end if;

    end loop;


  for d in SELECT urs.user_id, urps.project_id, urs.residual_id,urps.total
           FROM brs.user_residual_snapshot urs
                  inner join brs.user_residual_project_snapshot urps on urps.user_residual_snapshot_id = urs.id
                  inner join brs.user_residual_project_snapshot_type urpst
                             on urpst.id = urps.user_residual_project_snapshot_type_id and
                                urpst.user_residual_project_snapshot_code = 'CLAWBACKS'
           where urps.user_residual_snapshot_id = urs.id
             and urs.residual_id = p_residual_id
    loop

      with update_data as (
        select id from brs.residual_ledger l
        where l.user_id = d.user_id
          and l.project_id = d.project_id
          and amount = d.total
          and l.residual_clawback_paid is false
        limit 1
      )
      update brs.residual_ledger rl
      set residual_clawback_paid = true
     from update_data ud
     where ud.id = rl.id;
    end loop;

--This resets clawbacks when everything is paid back.
  with update_data as (
    select rc2.id
    from brs.residual_clawback rc2
    where rc2.applied_clawback = rc2.clawback_due
  )
  update brs.residual_clawback r
  set applied_clawback = 0.00,
      clawback_due = 0.00
  from update_data ud2
  where ud2.id = r.id;

  UPDATE brs.residual r
  SET modified_by_id = p_updated_by_id,
      date_modified  = now()
  WHERE id = p_residual_id;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS
    THEN
      RAISE NOTICE 'ERROR: %', SQLERRM;
      RETURN FALSE;
END;
$BODY$
