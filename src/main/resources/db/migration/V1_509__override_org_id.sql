alter table brs.override_plan
    add column if not exists org_id bigint references flow.org(id);

CREATE INDEX if not exists op_org_id_idx ON brs.override_plan (org_id);

create unique index if not exists op_org_id_uniq_idx
    on brs.override_plan (org_id)
    where (status_id != 3);