CREATE OR REPLACE FUNCTION flow.project_process_step_cancelled_date()
  RETURNS TRIGGER AS
$$
DECLARE
BEGIN
  update flow.project_process_step
  set process_step_cancelled_date = case
                                      when exists(select 1
                                                  from flow.company_project_status_type cpst
                                                         inner join flow.project_status_type pst
                                                           on cpst.project_status_type_id = pst.id
                                                  where cpst.id = new.company_process_step_status_type_id
                                                    and pst.id = 2) then now() end
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
