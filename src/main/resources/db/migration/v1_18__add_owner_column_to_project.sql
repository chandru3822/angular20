alter table if exists flow.project add user_position_id int;

alter table if exists flow.project
  add constraint p_user_position_id_fk foreign key (user_position_id) references flow.user_position;
9
