alter table flow.custom_field_group_assignment
  add column if not exists show_on_user_profile boolean not null default false;

CREATE TABLE if not exists flow.default_field
(
  id                       serial  NOT NULL,
  field_name varchar(255) not null,
  column_name varchar(255), --i made this optional because of fields like default home page that come from a totally different table or password that i didn't want to fill in
  property_name varchar(255), --i made this optional because of fields like default home page that come from a totally different table or password that i didn't want to fill in
  data_type_id integer, -- i made this optional so that things like "user profile image" could be controlled even though it isn't truly a "field"
  object_type_id integer not null,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT flow_default_field_pk PRIMARY KEY (id),
  CONSTRAINT flow_df_data_type_id_fk FOREIGN KEY (data_type_id)
    REFERENCES flow.data_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_df_object_type_id_fk FOREIGN KEY (object_type_id)
    REFERENCES flow.object_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_df_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_df_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION

);

CREATE TABLE if not exists flow.company_default_field
(
  id                       serial  NOT NULL,
  company_id       integer NOT NULL,
  default_field_id       integer NOT NULL,
  show_on_user_profile boolean not null default false,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT flow_company_default_pk PRIMARY KEY (id),
  CONSTRAINT flow_cd_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_cd_default_field_id_fk FOREIGN KEY (default_field_id)
    REFERENCES flow.default_field (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_cd_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_cd_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- add all the user default fields
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('First Name', 'first_name', 'firstName', 5, 3, 2417170);
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('Last Name', 'last_name', 'lastName', 5, 3, 2417170);
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('Email', 'email', 'email', 5, 3, 2417170);
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('Username', 'username', 'username', 5, 3, 2417170);
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('Phone', 'phone', 'phoneNumber', 5, 3, 2417170);
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('Notification', 'notification_type_id', 'notificationTypeId', 6, 3, 2417170);
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('Password', null, null, 5, 3, 2417170);
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('Default Home Page', null, null, 5, 3, 2417170);
insert into flow.default_field(field_name, column_name, property_name, data_type_id, object_type_id, created_by_id)
values ('Profile Image', null, null, null, 3, 2417170);

--add the password field to the user profile screen
insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, true
from flow.default_field
where field_name = 'Password'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'Password'));

--add the default home page field to the user profile screen
insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, true
from flow.default_field
where field_name = 'Default Home Page'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'Default Home Page'));

--add the notification field to the user profile screen
insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, true
from flow.default_field
where field_name = 'Notification'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'Notification'));

--add the remaining fields to the company but not to the user profile screen
insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, false
from flow.default_field
where field_name = 'First Name'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'First Name'));

insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, false
from flow.default_field
where field_name = 'Last Name'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'Last Name'));

insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, false
from flow.default_field
where field_name = 'Email'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'Email'));

insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, false
from flow.default_field
where field_name = 'Username'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'Username'));

insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, false
from flow.default_field
where field_name = 'Phone'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'Phone'));

insert into flow.company_default_field(company_id, default_field_id, created_by_id, show_on_user_profile)
select 3, id, 2417170, false
from flow.default_field
where field_name = 'Profile Image'
  and not exists( select id from flow.company_default_field where company_id = 3 and default_field_id = (select id from flow.default_field where field_name = 'Profile Image'));

