alter table flow.project
    add column if not exists street1              character varying(100);
alter table flow.project
    add column if not exists street2              character varying(100);
alter table flow.project
    add column if not exists city                 character varying(100);
alter table flow.project
    add column if not exists state_id             integer references flow.state(id);
alter table flow.project
    add column if not exists postal_code          character varying(10);
alter table flow.project
    add column if not exists country_id           integer references flow.country(id);
;
