CREATE TABLE if not exists flow.db_function_type
(
    id                       serial  NOT NULL,
    function_type       varchar(100) NOT NULL,
    archived       boolean not null default false,
    CONSTRAINT db_function_type_pk PRIMARY KEY (id)
);

alter table if exists flow.db_function
add column if not exists db_function_type_id int references flow.db_function_type(id);

insert into flow.db_function_type (function_type)
    select 'Requirement' where not exists (select id from flow.db_function_type where function_type = 'Requirement');
insert into flow.db_function_type (function_type)
select 'Action' where not exists (select id from flow.db_function_type where function_type = 'Action');


update flow.db_function as t1 set
    db_function_type_id = c.column_b
from (values
       (1,2),
       (2,1),
       (3,1),
       (4,1),
       (5,1),
       (6,1),
       (7,1),
       (8,1),
       (9,1),
       (10,1),
       (11,2)
     ) as c(column_a, column_b)
where c.column_a = t1.id
