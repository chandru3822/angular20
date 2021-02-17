create table if not exists flow.user_notification_token
(
  id serial not null,
  user_id int not null
    constraint unt_user_id__fk
      references flow."user",
  token varchar(255) not null,
  created_by_id integer not null
    constraint unt_created_by_id__fk
      references flow."user",
  date_created timestamp default now() not null,
  modified_by_id integer default null
    constraint unt_modified_by_id__fk
      references flow."user",
  date_modified timestamp default null,
  archived boolean default false not null
);

create unique index if not exists user_notification_token_id_uindex
  on flow.user_notification_token (id);

create unique index if not exists user_notification_token_user_id_token_uindex
  on flow.user_notification_token (user_id, token);

alter table if exists flow.user_notification_token
  drop constraint if exists user_notification_token_pk;

alter table if exists flow.user_notification_token
  add constraint user_notification_token_pk
    primary key (id);