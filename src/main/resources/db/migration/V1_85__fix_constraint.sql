ALTER TABLE if exists flow.process_step_action_company_function
    DROP CONSTRAINT if exists psacf_process_step_action_id_fk;

ALTER TABLE flow.process_step_action_company_function
    ADD CONSTRAINT psacf_process_step_action_id_fk FOREIGN KEY (process_step_action_id)
        REFERENCES flow.process_step_action (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT;
