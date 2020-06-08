alter table brs.ahj drop
    CONSTRAINT if exists ahj_metro_area_id_fk;
alter table brs.ahj_utility drop
    CONSTRAINT if exists au_metro_area_id_fk;

alter table brs.ahj add CONSTRAINT ahj_metro_area_id_fk FOREIGN KEY (metro_area_id)
        REFERENCES flow.list_of_value (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table brs.ahj_utility add CONSTRAINT au_metro_area_id_fk FOREIGN KEY (metro_area_id)
    REFERENCES brs.list_of_value (id) MATCH SIMPLE
           ON UPDATE NO ACTION ON DELETE NO ACTION;

drop table if exists brs.org_metro_area;
drop table if exists brs.metro_area;
drop table if exists brs.sales_metro_area;
drop table if exists brs.sales_area;
drop table if exists brs.sales_area_type;

alter table flow.org drop column if exists email;

alter table brs.project_rebate_payment drop column if exists state_id;
alter table brs.project_rebate_payment add column if not exists project_rebate_payment_state_id integer;
alter table brs.project_rebate_payment drop constraint if exists prp_project_rebate_payment_state_id_fk;
alter table brs.project_rebate_payment add constraint
    prp_project_rebate_payment_state_id_fk FOREIGN KEY (project_rebate_payment_state_id)
        REFERENCES brs.project_rebate_payment_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
CREATE INDEX if not exists fki_project_rebate_payment_state_id
    on brs.project_rebate_payment (project_rebate_payment_state_id);
