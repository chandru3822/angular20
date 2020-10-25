drop table if exists flow.smartlist_system_list;

create table if not exists flow.smartlist_system_list
(
  id serial not null,
  smartlist_system_list varchar,
  archived boolean not null default false,
  constraint smartlist_system_list_pk primary key (id)
);

insert into flow.smartlist_system_list (smartlist_system_list)
values ('States'), ('Process Step Status');

alter table if exists flow.smartlist_field
  add smartlist_system_list_id int,
  add constraint sf_smartlist_system_list_id_fk foreign key (smartlist_system_list_id) references flow.smartlist_system_list (id);

update flow.smartlist_field
set smartlist_system_list_id = 1
where name = 'Contact State' or name = 'Project State';

update flow.smartlist_field
set smartlist_system_list_id = 2
where name = 'Process Step Status';

create or replace function flow.get_smartlist_system_list_options(p_smartlist_system_list_id int, p_company_id int)

returns table(id int, name varchar) as

$$
begin
  case when p_smartlist_system_list_id = 1 then
    return query
      select s.id, s.abbreviation as name
      from flow.state s
      order by s.abbreviation;
    when p_smartlist_system_list_id = 2 then
      return query
        select cpssst.id, cpssst.process_step_status_type as name
        from flow.company_process_step_status_type cpssst
        where
            cpssst.company_id = p_company_id and
          cpssst.archived is not true
        order by cpssst.process_step_status_type;
    end case;
end;
$$
language plpgsql
volatile;