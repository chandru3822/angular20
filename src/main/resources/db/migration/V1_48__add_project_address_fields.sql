alter table flow.project
    add column street1              character varying(100);
alter table flow.project
    add column street2              character varying(100);
alter table flow.project
    add column city                 character varying(100);
alter table flow.project
    add column state_id             integer references flow.state(id);
alter table flow.project
    add column postal_code          character varying(10);
alter table flow.project
    add column country_id           integer references flow.country(id);
;
