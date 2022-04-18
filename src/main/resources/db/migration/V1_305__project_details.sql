--TODO create function for data_view insert to add the new table and  add project_id and contact_id and date_modified as the first columns in the table.

alter table flow.company
  add column if not exists schema_name varchar;

update flow.company
set schema_name = 'brs'
where id = 3;

CREATE TABLE if not exists flow.data_view
(
  id             serial  not null,
  company_id     integer not null,
  view_name      character varying(63),
  display_name   character varying(63),
  date_created   timestamp without time zone DEFAULT now() not null,
  date_modified  timestamp without time zone,
  created_by_id  integer not null,
  modified_by_id integer,
  archived       boolean not null            default false,
  CONSTRAINT data_view_pk primary key (id),
  CONSTRAINT dv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dv_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create index if not exists dv_company_id_idx
  on flow.data_view (company_id);

create index if not exists dv_view_name_idx
  on flow.data_view (view_name);

create table flow.field_config
(
  id                               serial,
  default_field_id                 integer,
  custom_field_group_assignment_id integer,
  process_step_event_id            integer,
  field_to_update                  varchar(100)                              not null,
  display_name                     varchar(100),
  update_first_value_only          boolean                     default false not null,
  update_first_value_only_id       varchar,
  secondary_field                  varchar(100),
  secondary_data_type_id           integer,
  date_created                     timestamp without time zone DEFAULT now() not null,
  date_modified                    timestamp without time zone,
  created_by_id                    integer                                   not null,
  modified_by_id                   integer,
  archived                         boolean                                   not null default false,
  CONSTRAINT field_config_pk primary key (id),
  CONSTRAINT fc_default_field_id_fk FOREIGN KEY (default_field_id)
    REFERENCES flow.default_field (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fc_secondary_data_type_id_fk FOREIGN KEY (secondary_data_type_id)
    REFERENCES flow.data_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dvc_custom_field_group_assignment_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dvc_process_step_event_id_fk FOREIGN KEY (process_step_event_id)
    REFERENCES flow.process_step_event (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dvc_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dvc_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);


create index if not exists fc_parent_id_idx
  on flow.field_config (default_field_id);


create index if not exists dvc_custom_field_group_assignment_id_idx
  on flow.field_config (custom_field_group_assignment_id);

create index if not exists dvc_process_step_event_id_idx
  on flow.field_config (process_step_event_id);


insert into flow.data_view(company_id, view_name, date_created, created_by_id,display_name)
  (select 3, 'project_details', now(), 2350555,'Project Details'
   where not exists(select id from flow.data_view where view_name = 'project_details'));

create table flow.data_view_field_config
(
  id              serial  not null,
  data_view_id    integer not null,
  field_config_id integer not null,
  date_created    timestamp without time zone DEFAULT now() not null,
  date_modified   timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  archived        boolean not null            default false,
  CONSTRAINT data_view_field_config_pk primary key (id),
  CONSTRAINT dvfc_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dvfc_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dvfc_data_view_id_fk FOREIGN KEY (data_view_id)
    REFERENCES flow.data_view (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dvfc_field_config_id_fk FOREIGN KEY (field_config_id)
    REFERENCES flow.field_config (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create index if not exists dvfc_data_view_id_idx
  on flow.data_view_field_config (data_view_id);

create index if not exists dvfc_field_config_id_idx
  on flow.data_view_field_config (field_config_id);

alter table flow.custom_field
  add column if not exists custom_field_sql_column varchar;

update flow.custom_field set custom_field_sql_column = 'proposal_nbr' where id in (622);

alter table flow.object_type
  add column if not exists reference_table varchar;


alter table flow.default_field
  add column if not exists watched_by_trigger boolean not null default false;

alter table flow.default_field
  add column if not exists unique_behavior_type_id integer;

alter table flow.default_field drop constraint  if exists df_unique_behavior_id_fk;
alter table flow.default_field
  add CONSTRAINT  df_unique_behavior_id_fk FOREIGN KEY (unique_behavior_type_id)
    REFERENCES flow.unique_behavior_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
(select 'EVENT_RESOURCE_TRIGGER',now(),2350555
  where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'EVENT_RESOURCE_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
  (select 'STATE_FIELD_TRIGGER',now(),2350555
   where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'STATE_FIELD_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
  (select 'COUNTRY_FIELD_TRIGGER',now(),2350555
   where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'COUNTRY_FIELD_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
  (select 'STATE_ABBREV_FIELD_TRIGGER',now(),2350555
   where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'STATE_ABBREV_FIELD_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
  (select 'USER_POSITION_ID_TRIGGER',now(),2350555
   where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'USER_POSITION_ID_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
  (select 'CONTACT_TYPE_TRIGGER',now(),2350555
   where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'CONTACT_TYPE_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
  (select 'PROJECT_STATUS_TRIGGER',now(),2350555
   where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'PROJECT_STATUS_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
  (select 'PROCESS_FIELD_TRIGGER',now(),2350555
   where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'PROCESS_FIELD_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
  (select 'USER_ID_TRIGGER',now(),2350555
   where not exists (select id from flow.unique_behavior_type where unique_behavior_type = 'USER_ID_TRIGGER'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                              watched_by_trigger, unique_behavior_type_id)
(select 'Start Time','start_time','startTime',2,(select id from flow.object_type where object_code = 'EVENT'),now(),2350555,
        true,null
  where not exists (select id from flow.default_field where column_name = 'start_time'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
  (select 'End Time','end_time','endTime',2,(select id from flow.object_type where object_code = 'EVENT'),now(),2350555,
          true,null
   where not exists (select id from flow.default_field where column_name = 'end_time'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
  (select 'Resource ID','resource_id','resourceID',6,(select id from flow.object_type where object_code = 'EVENT'),now(),2350555,
          true,(select id from flow.unique_behavior_type where unique_behavior_type = 'EVENT_RESOURCE_TRIGGER')
   where not exists (select id from flow.default_field where column_name = 'resource_id'));


insert into flow.field_config(default_field_id,
                              process_step_event_id, field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
(select (select id from flow.default_field where column_name = 'start_time'),pdec.process_step_event_id,
        pdec.field_to_update,pdec.display_name,pdec.update_first_value_only,pdec.update_first_value_only_id,
        pdec.second_field_to_update,now(),2350555
        from brs.project_detail_events_config pdec
 where field_to_use = 'start_time');

insert into flow.field_config(default_field_id,
                              process_step_event_id, field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field where column_name = 'end_time'),pdec.process_step_event_id,
          pdec.field_to_update,pdec.display_name,pdec.update_first_value_only,pdec.update_first_value_only_id,
          pdec.second_field_to_update,now(),2350555
   from brs.project_detail_events_config pdec
   where field_to_use = 'end_time');

insert into flow.field_config(default_field_id,
                              process_step_event_id, field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field where column_name = 'resource_id'),pdec.process_step_event_id,
          pdec.field_to_update,pdec.display_name,pdec.update_first_value_only,pdec.update_first_value_only_id,
          pdec.second_field_to_update,now(),2350555
   from brs.project_detail_events_config pdec
   where field_to_use = 'resource_id');


insert into flow.field_config(custom_field_group_assignment_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id,secondary_data_type_id)
  (select pdc.custom_field_group_assignment_id,
          pdc.field_to_update,pdc.display_name,pdc.update_first_value_only,pdc.update_first_value_only_id,
          pdc.second_field_to_update,now(),2350555,pdc.second_data_type_id
   from brs.project_details_config pdc
   where custom_field_group_assignment_id >0
     and company_id = 3 and pdc.field_to_update not in ( 'closer_user_position_id','cancelled_date'));



insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Email','email','contact_email',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Phone','phone','contact_phone',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Mobile Phone','mobile','contact_mobile_phone',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

-- insert into flow.default_field(field_name, column_name, property_name, data_type_id,
--                                object_type_id, date_created, created_by_id,
--                                watched_by_trigger, unique_behavior_type_id)
-- values('Contact Name','contact_name','contactName',5,(select id from flow.object_type where object_code = 'CONTACT'),
--        now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Street1','street1','project_street1',5,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project City','city','project_city',5,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Time Zone','time_zone','project_time_zone',5,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project State Abbreviation','company_state_id','project_company_state_id',6,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'STATE_ABBREV_FIELD_TRIGGER'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Postal Code','postal_code','project_postal_code',5,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

-- insert into flow.default_field(field_name, column_name, property_name, data_type_id,
--                                object_type_id, date_created, created_by_id,
--                                watched_by_trigger, unique_behavior_type_id)
-- values('Project ID','id','project_id',6,(select id from flow.object_type where object_code = 'PROJECT'),
--        now(),2350555,true,null);




insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
(select (select id from flow.default_field df where df.property_name = pdc.field_to_update),
        pdc.field_to_update,pdc.display_name,pdc.update_first_value_only,pdc.update_first_value_only_id,pdc.second_field_to_update,
        now(),2350555
  from brs.project_details_config pdc
  where pdc.company_id = 3 and pdc.custom_field_group_assignment_id < 1 and pdc.field_to_update not in ( 'contact_name','project_state_abbreviation','project_id'));


alter table brs.project_details add column if not exists project_company_state_id integer;
create index if not exists pd_company_state_id_idx on brs.project_details(project_company_state_id);

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.property_name = 'project_company_state_id'),
          'project_company_state_id','Project State',false,null,'project_state_abbreviation',
          now(),2350555);

--TODO update the property_name column on flow.default_field for all the fields above.  Make them camel case;

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Type','contact_type_id','contactTypeId',6,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'CONTACT_TYPE_TRIGGER'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact First Name','first_name','contactFirstName',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.column_name = 'first_name' and df.property_name = 'contactFirstName'),
          'contact_first_name','Contact First Name',false,null,null,
          now(),2350555);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Last Name','last_name','contactLastName',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.column_name = 'last_name' and df.property_name = 'contactLastName'),
          'contact_last_name','Contact Last Name',false,null,null,
          now(),2350555);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Street 1','street1','contactStreet1',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Street 2','street2','contactStreet2',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact City','city','contactCity',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Postal Code','postal_code','contactPostalCode',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Prospect Status','prospect_status','contactProspectStatus',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Mailing Street1','mailing_street1','contactMailingStreet1',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Mailing Street2','mailing_street2','contactMailingStreet2',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Mailing city','mailing_city','contactMailingCity',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Mailing Postal Code','mailing_postal_code','contactMailingPostalCode',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Title','title','contactTitle',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Owner User Position ID','owner_user_position_id','ownerUserPositionID',6,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'USER_POSITION_ID_TRIGGER'));

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.column_name = 'owner_user_position_id'),
          'setter_user_position_id','Setter',false,null,'setter_name',
          now(),2350555);

alter table brs.project_details add column  if not exists setter_name text;
alter table brs.project_details add column  if not exists contact_first_name text;
alter table brs.project_details add column  if not exists contact_last_name text;
create index if not exists pd_setter_name_idx
  on brs.project_details (setter_name);
create index if not exists pd_contact_first_name_idx
  on brs.project_details (contact_first_name);
create index if not exists pd_contact_last_name_idx
  on brs.project_details (contact_last_name);
alter table brs.project_details drop column if exists setter_user_id;
alter table brs.project_details drop column if exists closer_user_id;
alter table brs.project_details drop column if exists contact_name;--TODO why didn't this drop?

--TODO migrate the contact first name and last name and setter name to project details.



insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Company State ID','company_state_id','contactCompanyStateId',6,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'STATE_ABBREV_FIELD_TRIGGER'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Mailing Company State ID','mailing_company_state_id','contactMailingCompanyStateId',6,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'STATE_ABBREV_FIELD_TRIGGER'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Company Country','company_country_id','contactCompanyCountryId',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'COUNTRY_FIELD_TRIGGER'));



insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Longitude','longitude','contactLongitude',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact Latitude','latitude','contactLatitude',5,(select id from flow.object_type where object_code = 'CONTACT'),
       now(),2350555,true,null);


insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Contact ID','contact_id','contactId',6,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.property_name = 'contactId'),
          'contact_id','Contact ID',false,null,null,
          now(),2350555);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Creator','created_by_id','projectCreatedById',6,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'USER_ID_TRIGGER'));

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.property_name = 'projectCreatedById'),
          'project_created_by_id','Project Creator',false,null,'project_creator',
          now(),2350555);


insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Company Process ID','company_process_id','companyProcessId',6,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'PROCESS_FIELD_TRIGGER'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Name','project_name','projectName',5,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);


insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Company Project Status Type','company_project_status_type_id','companyProjectStatusTypeId',6,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'PROJECT_STATUS_TRIGGER'));

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.column_name = 'company_project_status_type_id'),
          'company_project_status_type_id','Company Project Status Type',false,null,'company_project_status_type',
          now(),2350555);



insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('User Position ID','user_position_id','userPositionId',6,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'USER_POSITION_ID_TRIGGER'));

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.column_name = 'user_position_id'),
          'closer_user_position_id','Closer Name',false,null,'closer_name',
          now(),2350555);


insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Street 2','street2','projectStreet2',5,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

-- insert into flow.default_field(field_name, column_name, property_name, data_type_id,
--                                object_type_id, date_created, created_by_id,
--                                watched_by_trigger, unique_behavior_type_id)
-- values('Project Company State ID','project_company_state_id','projectCompanyStateID',6,(select id from flow.object_type where object_code = 'PROJECT'),
--        now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'STATE_ABBREV_FIELD_TRIGGER'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Company Country','company_country_id','projectCompanyCountryId',6,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,(select id from flow.unique_behavior_type where unique_behavior_type = 'COUNTRY_FIELD_TRIGGER'));

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Longitude','longitude','projectLongitude',5,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Project Latitude','latitude','projectLatitude',5,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

insert into flow.default_field(field_name, column_name, property_name, data_type_id,
                               object_type_id, date_created, created_by_id,
                               watched_by_trigger, unique_behavior_type_id)
values('Cancelled Date','cancelled_date','cancelledDate',1,(select id from flow.object_type where object_code = 'PROJECT'),
       now(),2350555,true,null);

insert into flow.field_config(default_field_id,
                              field_to_update, display_name,
                              update_first_value_only, update_first_value_only_id, secondary_field,
                              date_created, created_by_id)
  (select (select id from flow.default_field df where df.column_name = 'cancelled_date'),
          'cancelled_date','Cancelled',false,null,null,
          now(),2350555);


insert into flow.data_view_field_config(data_view_id, field_config_id, date_created, created_by_id)
  (select (select id from flow.data_view where view_name = 'project_details'),fc.id,now(),2350555
   from flow.field_config fc);

--drop table if exists brs.project_details_config;



CREATE OR REPLACE function flow.add_column_to_data_view(p_data_view_field_config_id integer)
  returns void
AS $BODY$
declare
  v_field_to_update varchar;
  v_secondary_field varchar;
  v_data_type       varchar;
  v_update_first_value_only boolean;
  v_data_type_id integer;
  v_schema_name varchar;
  v_view_name varchar;
  v_update_first_value_only_id varchar;
  v_sql varchar;
BEGIN
  select fc.field_to_update,fc.secondary_field,
         coalesce(dt.data_type,dt2.data_type) as data_type,fc.update_first_value_only,
         coalesce(dt.id,dt2.id) as data_type_id,
         c.schema_name,dv.view_name,fc.update_first_value_only_id
  into v_field_to_update,v_secondary_field,v_data_type,v_update_first_value_only,v_data_type_id,
    v_schema_name,v_view_name,v_update_first_value_only_id
  from flow.data_view_field_config dvfc
         inner join flow.field_config fc on fc.id = dvfc.field_config_id
         inner join flow.data_view dv on dvfc.data_view_id = dv.id
         inner join flow.company c on dv.company_id = c.id
         left join flow.custom_field_group_assignment cfga on fc.custom_field_group_assignment_id = cfga.id
         left join flow.custom_field cf on cfga.custom_field_id = cf.id
         left join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
         left join flow.data_type dt2  on cdt.data_type_id = dt2.id
         left join flow.default_field df on fc.default_field_id = df.id
         left join flow.data_type dt on df.data_type_id = dt.id
  where dvfc.id = p_data_view_field_config_id;

  if v_data_type_id = 7 then
    v_data_type = 'integer[]';
  elsif v_data_type_id in (8,9) then
    v_data_type = 'integer';
  end if;
  --     v_sql = $$ALTER TABLE $$||v_schema_name||$$.$$||v_view_name||$$ ADD COLUMN if not exists $$ || v_field_to_update || $$ $$ ||v_data_type||$$;$$;
--     raise notice 'what is this %',v_sql;
  EXECUTE $$ALTER TABLE $$||v_schema_name||$$.$$||v_view_name||$$ ADD COLUMN if not exists $$ || v_field_to_update || $$ $$ ||v_data_type||$$;$$;
  EXECUTE $$CREATE INDEX  ON $$ ||v_schema_name||$$.$$||v_view_name|| $$($$||v_field_to_update||$$);$$;

  if v_secondary_field is not null then
    v_data_type = 'text';
    EXECUTE $$ALTER TABLE $$||v_schema_name||$$.$$||v_view_name||$$ ADD COLUMN if not exists $$ || v_secondary_field || $$ $$ ||v_data_type||$$;$$;
    EXECUTE $$CREATE INDEX  ON $$ ||v_schema_name||$$.$$||v_view_name|| $$($$||v_secondary_field||$$);$$;
  end if;

  if v_update_first_value_only is true then
    v_data_type = 'integer';
    EXECUTE $$ALTER TABLE $$||v_schema_name||$$.$$||v_view_name||$$ ADD COLUMN if not exists $$ || v_update_first_value_only_id ||$$_cfv_id $$ ||v_data_type||$$;$$;
    EXECUTE $$CREATE INDEX  ON $$ ||v_schema_name||$$.$$||v_view_name|| $$($$||v_update_first_value_only_id||$$_cfv_id);$$;

  end if;
END
$BODY$
  LANGUAGE plpgsql;

alter table brs.project_details add column if not exists project_created_by_id integer;
create index if not exists pd_project_created_by_id_idx
  on brs.project_details (project_created_by_id);
alter table brs.project_details add column if not exists date_modified timestamp;
update brs.project_details set date_modified = now();
alter table brs.project_details alter column date_modified set not null;
create index if not exists pd_date_modified_idx
  on brs.project_details (date_modified);

drop trigger if exists project_project_details_for_contact_trg on flow.contact;
drop function  if exists  flow.project_details_from_contact();


CREATE OR REPLACE function flow.initialize_data_view_table(p_company_id integer,p_table_name character varying)
  returns void
AS $BODY$
declare
  v_schema_name character varying;
BEGIN

  select schema_name
    into v_schema_name
  from flow.company
    where id = p_company_id;

  execute $$Create table if NOT EXISTS $$||v_schema_name||$$.$$||p_table_name||$$ (id serial not null primary key,
                                                                      project_id integer not null,
                                                                      contact_id integer,
                                                                      date_modified timestamp );$$;

  execute $$insert into $$||v_schema_name||$$.$$||p_table_name||$$(project_id, contact_id, date_modified)
(select p.id,p.contact_id,now()
 from flow.project p); $$;

END
$BODY$
  LANGUAGE plpgsql;


drop trigger if exists update_project_details_trg on flow.project_process_step_custom_field_value;
drop FUNCTION if exists flow.update_project_details_process_steps();

drop trigger if exists update_project_details_from_events_trg on flow.project_process_step_event_custom_field_value;
drop FUNCTION if exists flow.update_project_details_process_steps_from_events();

drop trigger if exists update_events_trg on flow.project_process_step_event;
drop FUNCTION if exists flow.update_events();


update flow.field_config set secondary_data_type_id = 6
where id in (
  select id from flow.field_config where field_to_update in ('closer_user_position_id',
                                                             'proposal_number_id',
                                                             'proposal_number_id',
                                                             'proposal_number_id',
                                                             'proposal_number_id',
                                                             'proposal_number_id',
                                                             'proposal_number_id_booking',
                                                             'proposal_number_id_booking',
                                                             'proposal_number_id_closer_appointment',
                                                             'proposal_number_id_final_design',
                                                             'proposal_number_id_final_design'));

update flow.field_config set secondary_data_type_id = 1
where id in (
  select id from flow.field_config where field_to_update in ('site_survey_start_time'));


update flow.field_config set secondary_data_type_id = 5
where id in (
  select id from flow.field_config where secondary_field is not null and secondary_data_type_id is null);

delete from brs.project_details_config where company_id != 3;

with my_data as (
  select distinct pdec.field_to_update
  from brs.project_detail_events_config pdec)
delete from brs.project_details_config
where id in (
  select pdc.id
  from brs.project_details_config pdc
         inner join my_data md on md.field_to_update = pdc.field_to_update
    and company_id = 3);


with my_data as (
  select pdc.custom_field_group_assignment_id
  from brs.project_details_config pdc
  where company_id = 3
  except
  select pdc.custom_field_group_assignment_id
  from brs.project_details_config pdc
         inner join flow.custom_field_group_assignment cfga on pdc.custom_field_group_assignment_id = cfga.id and cfga.archived is false
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.archived is false
         inner join flow.process_step ps on cfg.process_step_id = ps.id and ps.archived is false
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id and cf.archived is false
  where pdc.company_id = 3)
delete from brs.project_details_config where id in (
  select pdc2.id--,pdc2.field_to_update,cfg.group_name,ps.process_step_name,cf.field_name,cfga.id
  from brs.project_details_config pdc2
         inner join flow.custom_field_group_assignment cfga on pdc2.custom_field_group_assignment_id = cfga.id
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.process_step ps on cfg.process_step_id = ps.id
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join my_data md on md.custom_field_group_assignment_id = pdc2.custom_field_group_assignment_id);


