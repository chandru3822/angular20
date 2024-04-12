alter table if exists brs.proposal_log_history
add if not exists il_srec_disclosure_form_id varchar(50) default null::character varying,
add if not exists system_size_ac varchar(100) default null::character varying;