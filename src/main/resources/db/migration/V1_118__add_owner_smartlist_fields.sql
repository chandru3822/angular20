insert into flow.smartlist_field (company_object_type_id, name, reference_table, reference_column, created_by_id, company_data_type_id, join_table, join_column)
values

-- Atlas Solar Advisors, company_id = 12
(52, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 101, 'flow.contact', 'owner_user_position_id'),
(54, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 101, 'flow.project_process_step', 'user_position_id'),

-- B+C Electric, company_id = 4
(7, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 11, 'flow.contact', 'owner_user_position_id'),
(9, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 11, 'flow.project_process_step', 'user_position_id'),

-- Blue Raven Solar, company_id = 3
(2, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 1, 'flow.contact', 'owner_user_position_id'),
(4, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 1, 'flow.project_process_step', 'user_position_id'),

-- Direct Solar of America, company_id = 13
(57, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 111, 'flow.contact', 'owner_user_position_id'),
(59, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 111, 'flow.project_process_step', 'user_position_id'),

-- Eco Lux Solar, company_id = 25
(12, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 21, 'flow.contact', 'owner_user_position_id'),
(14, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 21, 'flow.project_process_step', 'user_position_id'),

-- Energy Pal, company_id = 17
(77, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 151, 'flow.contact', 'owner_user_position_id'),
(79, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 151, 'flow.project_process_step', 'user_position_id'),

-- New Markets, company_id = 9
(37, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 61, 'flow.contact', 'owner_user_position_id'),
(39, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 61, 'flow.project_process_step', 'user_position_id'),

-- Revolution Solar, company_id = 14
(62, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 121, 'flow.contact', 'owner_user_position_id'),
(64, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 121, 'flow.project_process_step', 'user_position_id'),

-- Salient Solar, company_id = 6
(17, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 31, 'flow.contact', 'owner_user_position_id'),
(19, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 31, 'flow.project_process_step', 'user_position_id'),

-- Smart Money Solar, company_id = 15
(67, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 131, 'flow.contact', 'owner_user_position_id'),
(69, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 131, 'flow.project_process_step', 'user_position_id'),

-- Solar 101, company_id = 10
(42, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 81, 'flow.contact', 'owner_user_position_id'),
(44, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 81, 'flow.project_process_step', 'user_position_id'),

-- Solenrgi, company_id = 7
(22, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 41, 'flow.contact', 'owner_user_position_id'),
(24, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 41, 'flow.project_process_step', 'user_position_id'),

-- Sun Run, company_id = 8
(27, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 51, 'flow.contact', 'owner_user_position_id'),
(29, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 51, 'flow.project_process_step', 'user_position_id'),

-- Supernova Energy, company_id = 16
(72, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 141, 'flow.contact', 'owner_user_position_id'),
(74, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 141, 'flow.project_process_step', 'user_position_id'),

-- TGE Solar, company_id = 11
(47, 'Contact Owner', 'flow.user', 'concat(flow.user.first_name, '' '', flow.user.last_name)', 2350555, 91, 'flow.contact', 'owner_user_position_id'),
(49, 'Process Step Owner', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 2350555, 91, 'flow.project_process_step', 'user_position_id');


drop function if exists flow.get_contact_available_owners(int, boolean);

create or replace function flow.get_contact_available_owners(p_company_id int, p_in_parent_company boolean)

  returns table (
                  user_id bigint,
                  first_name varchar,
                  last_name varchar,
                  full_name text,
                  user_position_id int,
                  "position" varchar
                ) as

$$
BEGIN
  return query
    select u.id as user_id,
           u.first_name,
           u.last_name,
           concat(u.first_name, ' ', u.last_name) as full_name,
           up.id as user_position_id,
           p.position
    from flow.position p
           inner join flow.user_position up on up.position_id = p.id
           inner join flow."user" u on u.id = up.user_id
           inner join flow.company_user_status cus on cus.user_id = u.id
           inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = p.company_id
    where
      case when p_in_parent_company
             then p.company_id = any(select id from flow.company c where (c.id = p_company_id or c.parent_company_id = p_company_id) and c.archived is not true)
           else p.company_id = p_company_id
        end
      and p.contact_owner is true
      and ust.has_access is true
      and up.start_date <= now()
      and (up.end_date is null or up.end_date >= now())
    order by u.last_name, u.first_name;
END
$$
  language plpgsql;


drop function if exists flow.get_process_step_available_owners(int, int, boolean);

create or replace function flow.get_process_step_available_owners(p_process_step_id int, p_company_id int, p_in_parent_company boolean)

  returns table (
                  user_id bigint,
                  first_name varchar,
                  last_name varchar,
                  full_name text,
                  user_position_id int,
                  "position" varchar
                ) as

$$

BEGIN
  return query
    with positions as (
      select array(
               select pspop.position_id
               from flow.process_step_process_owning_position pspop
                      inner join flow.position p1 on p1.id = pspop.position_id
                      inner join flow.process_step_process psp on psp.id = pspop.process_step_process_id
               where psp.process_step_id = p_process_step_id and
                 pspop.archived is not true and
                 case when p_in_parent_company
                        then p1.company_id = any(select id from flow.company c where (c.id = p_company_id or c.parent_company_id = p_company_id) and c.archived is not true)
                      else p1.company_id = p_company_id
                   end
               ) as position_ids
    )
    select u.id as user_id,
           u.first_name,
           u.last_name,
           concat(u.first_name, ' ', u.last_name) as full_name,
           up.id as user_position_id,
           p.position
    from positions
           inner join flow.user_position up on array[up.position_id] <@ positions.position_ids
           inner join flow.user u on u.id = up.user_id
           inner join flow.position p on p.id = up.position_id
           inner join flow.user_status_type ust on ust.company_id = p.company_id
           inner join flow.company_user_status cus on cus.user_id = u.id and cus.user_status_type_id = ust.id
    where ust.has_access is true and
        up.start_date <= now() and
      (up.end_date is null or up.end_date >= now()) and
      p.archived is not true
    order by u.last_name, u.first_name;
END
$$
  language plpgsql;