alter table if exists flow.sms_queue add if not exists sms_team_id integer;

alter table flow.sms_queue drop constraint if exists flow_sq_sms_team_id_fk;
alter table if exists flow.sms_queue
    add CONSTRAINT flow_sq_sms_team_id_fk FOREIGN KEY (sms_team_id)
        REFERENCES flow.sms_team (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT;
