CREATE OR REPLACE FUNCTION flow.project_process_step_cancelled_date()
  RETURNS TRIGGER AS
$$
DECLARE
BEGIN
  update flow.project_process_step
  set cancelled_date = case when exists(select 1
                                        from flow.company_process_step_status_type cpsst
                                               inner join flow.process_step_status_type psst
                                                 on cpsst.process_step_status_type_id = psst.id
                                        where cpsst.id = new.company_process_step_status_type_id
                                          and psst.id = 3) then now() end
  where id = new.id;
  return new;
END
$$
  LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS project_process_step_cancelled_date_trg ON flow.project_process_step;
CREATE TRIGGER project_process_step_cancelled_date_trg
  AFTER UPDATE OF company_process_step_status_type_id
  ON flow.project_process_step
  FOR EACH ROW
EXECUTE PROCEDURE flow.project_process_step_cancelled_date();
