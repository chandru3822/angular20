drop function if exists flow.populate_data_from_data_maintenance(p_data_view_id bigint,p_company_process_ids bigint[] );
drop function if exists flow.populate_data_from_data_maintenance(p_data_view_maintenance_id bigint,p_data_view_id bigint,p_company_process_ids bigint[] );
drop function if exists flow.run_view_maintenance();

CREATE TABLE if NOT EXISTS flow.data_view_update
(
  id        bigserial                NOT NULL,
  generated_update     text,
  CONSTRAINT data_view_update_pk PRIMARY KEY (id)
);

alter table brs.proposal_log_history add column if not exists financial_option text;
