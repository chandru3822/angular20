alter table flow.org add column if not exists company_state_id integer;

alter table flow.org drop constraint if exists org_company_state_id_fk;
alter table flow.org add CONSTRAINT  org_company_state_id_fk FOREIGN KEY (company_state_id)
        REFERENCES flow.company_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;


alter table flow.project add column if not exists company_state_id integer;

alter table flow.project drop constraint if exists project_company_state_id_fk;
alter table flow.project add CONSTRAINT project_company_state_id_fk FOREIGN KEY (company_state_id)
    REFERENCES flow.company_state (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;


alter table flow.contact add column if not exists  company_state_id integer;

alter table flow.contact drop constraint if exists contact_company_state_id_fk;
alter table flow.contact add CONSTRAINT contact_company_state_id_fk FOREIGN KEY (company_state_id)
    REFERENCES flow.company_state (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table flow.contact add column if not exists mailing_company_state_id integer;

alter table flow.contact drop constraint if exists contact_mailing_company_state_id_fk;
alter table flow.contact add CONSTRAINT contact_mailing_company_state_id_fk FOREIGN KEY (mailing_company_state_id)
    REFERENCES flow.company_state (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;


alter table flow.contact drop column if exists location_unavailable;


alter table flow.project add column if not exists company_country_id integer;

alter table flow.project drop constraint if exists project_company_country_id_fk;
alter table flow.project add CONSTRAINT project_company_country_id_fk FOREIGN KEY (company_country_id)
    REFERENCES flow.company_country (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table flow.contact add column if not exists company_country_id integer;

alter table flow.contact drop constraint if exists contact_company_country_id_fk;
alter table flow.contact add CONSTRAINT contact_company_country_id_fk FOREIGN KEY (company_country_id)
    REFERENCES flow.company_country (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table flow.project drop column if exists country_id;
alter table flow.contact drop column if exists country_id;


