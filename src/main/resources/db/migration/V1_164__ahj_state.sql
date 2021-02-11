alter table brs.ahj
    add column if not exists company_state_id int references flow.company_state(id);

update brs.ahj as a set
    company_state_id = c.column_b
from (
         select lov.id as lovId,
                cs.id as companyStateId
         from flow.list_of_value lov
                  inner join flow.state s on s.abbreviation = substring(lov.name from 1 for 2)
                  inner join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
         where lov.parent_id = 172
           and lov.archived is false
     ) as c(column_a, column_b)
where c.column_a = a.metro_area_id
;

alter table brs.ahj_utility
    add column if not exists company_state_id int references flow.company_state(id);

update brs.ahj_utility as a set
    company_state_id = c.column_b
from (
         select lov.id as lovId,
                cs.id as companyStateId
         from flow.list_of_value lov
                  inner join flow.state s on s.abbreviation = substring(lov.name from 1 for 2)
                  inner join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
         where lov.parent_id = 172
           and lov.archived is false
     ) as c(column_a, column_b)
where c.column_a = a.metro_area_id;
