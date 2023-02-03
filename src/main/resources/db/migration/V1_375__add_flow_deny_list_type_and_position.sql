CREATE TABLE IF NOT EXISTS flow.deny_list_type
(
	id                  serial NOT NULL,
	deny_list_type      varchar(100) NOT NULL,
	archived            boolean not null default false,
	constraint flow_deny_list_type_pk primary key (id)
	);

insert into flow.deny_list_type (deny_list_type)
select 'PROCESS_LIMIT_ADD_PROJECT' WHERE not exists( select id from flow.deny_list_type where deny_list_type.deny_list_type = 'PROCESS_LIMIT_ADD_PROJECT');

CREATE TABLE IF NOT EXISTS flow.deny_list_position
(
	id                               bigserial primary key   not null,
	position_id                      bigint                  not null
	references flow.position (id) on update restrict on delete restrict,
	company_process_id                      bigint
	references flow.company_process (id)                          not null,
	created_by_id                    bigint                  not null
	references flow."user" (id),
	date_created                     timestamp default now(),
	modified_by_id                   bigint
	references flow."user" (id),
	date_modified                    timestamp default now(),
	deny_list_type_id               bigint                  not null
	references flow.deny_list_type (id),
	archived                         boolean   default false not null
	);
