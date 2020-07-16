-- select all active closers
    with users as (
        select u.id
        from flow."user" u
                 inner join flow.user_position up on up.user_id = u.id
        where up.position_id = 1
          and up.archived is not true
          and up.start_date <= now()
          and (up.end_date is null or up.end_date > now())
          and up.primary_flag is true
    ),
-- previous month schedule
     previous_month as (
         insert into flow.resource_schedule(company_id, user_id, start_date, end_date, created_by_id)
             (select 3, u.id, date_trunc('month', now()::date) - '1 month'::interval, date_trunc('month', now()::date) - '1 day'::interval, 2350555 from users u)
             returning id),
     pm_monday as (
         insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select pm.id, '15:00:00', '23:00:00', 2, now(), 2350555 from previous_month pm)),
     pm_tuesday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select pm.id, '15:00:00', '23:00:00', 3, now(), 2350555 from previous_month pm)),
     pm_wednesday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select pm.id, '15:00:00', '23:00:00', 4, now(), 2350555 from previous_month pm)),
     pm_thursday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select pm.id, '15:00:00', '23:00:00', 5, now(), 2350555 from previous_month pm)),
     pm_friday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select pm.id, '15:00:00', '23:00:00', 6, now(), 2350555 from previous_month pm)),
-- current month schedule
     current_month as (
         insert into flow.resource_schedule(company_id, user_id, start_date, end_date, created_by_id)
             (select 3, u.id, date_trunc('month', now()::date), date_trunc('month', now()::date) + '1 month'::interval - '1 day'::interval, 2350555 from users u)
             returning id),
     cm_monday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select cm.id, '15:00:00', '23:00:00', 2, now(), 2350555 from current_month cm)),
     cm_tuesday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select cm.id, '15:00:00', '23:00:00', 3, now(), 2350555 from current_month cm)),
     cm_wednesday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select cm.id, '15:00:00', '23:00:00', 4, now(), 2350555 from current_month cm)),
     cm_thursday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select cm.id, '15:00:00', '23:00:00', 5, now(), 2350555 from current_month cm)),
     cm_friday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select cm.id, '15:00:00', '23:00:00', 6, now(), 2350555 from current_month cm)),
-- next month schedule
     next_month as (
         insert into flow.resource_schedule(company_id, user_id, start_date, end_date, created_by_id)
             (select 3, u.id, date_trunc('month', now()::date) + '1 month'::interval, date_trunc('month', now()::date) + '2 month'::interval - '1 day'::interval, 2350555 from users u)
             returning id),
     nm_monday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select nm.id, '15:00:00', '23:00:00', 2, now(), 2350555 from next_month nm)),
     nm_tuesday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select nm.id, '15:00:00', '23:00:00', 3, now(), 2350555 from next_month nm)),
     nm_wednesday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select nm.id, '15:00:00', '23:00:00', 4, now(), 2350555 from next_month nm)),
     nm_thursday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select nm.id, '15:00:00', '23:00:00', 5, now(), 2350555 from next_month nm)),
     nm_friday as (insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time, day_of_week_id, date_created, created_by_id)
         (select nm.id, '15:00:00', '23:00:00', 6, now(), 2350555 from next_month nm)),
-- appointments every thursday for even user_ids (these times are 12:30 - 2:30 pm MST), every wednesday for odd user_ids (these times are 12:30 - 2:30 pm MST)
 -- these add appointments + and - 8 weeks to get a full 3 month coverage without having to determine what week number we are on
     hourly_appointments_sub_8 as (
         insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                    (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' - '8 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' - '8 weeks'::interval), false, 'Test Data', 2350555 from users u)
     ),
     hourly_appointments_sub_7 as (
         insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
             (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' - '7 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' - '7 weeks'::interval), false, 'Test Data', 2350555 from users u)
     ),
         hourly_appointments_sub_6 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' - '6 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' - '6 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_sub_5 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' - '5 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' - '5 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_sub_4 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' - '4 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' - '4 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_sub_3 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' - '3 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' - '3 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_sub_2 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' - '2 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' - '2 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_sub_1 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' - '1 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' - '1 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30'), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '30:30'), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_add_1 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' + '1 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' + '1 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_add_2 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' + '2 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' + '2 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_add_3 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' + '3 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' + '3 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_add_4 as (
             -- this adds appointments + and - 8 weeks to get a full 3 month coverage without having to determine what week number we are on
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' + '4 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' + '4 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_add_5 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' + '5 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' + '5 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_add_6 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' + '6 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' + '6 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_add_7 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' + '7 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' + '7 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
         hourly_appointments_add_8 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end  + '18:30' + '8 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '3 days'::interval else '2 days'::interval end + '20:30' + '8 weeks'::interval), false, 'Test Data', 2350555 from users u)
         ),
 -- all day appointments every monday for even user_ids, every tuesday for odd user_ids
 -- this adds all day appointments + and - 8 weeks to get a full 3 month coverage without having to determine what week number we are on
    all_day_appointments_sub_8 as (
         insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                    (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '8 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '8 weeks'::interval), true, 'Test Data', 2350555 from users u)
             ),
         all_day_appointments_sub_7 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '7 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '7 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_sub_6 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '6 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '6 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_sub_5 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '5 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '5 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_sub_4 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '4 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '4 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_sub_3 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '3 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '3 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_sub_2 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '2 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '2 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_sub_1 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '1 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end - '1 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_add_1 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '1 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '1 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_add_2 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '2 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '2 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_add_3 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '3 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '3 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_add_4 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '4 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '4 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_add_5 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '5 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '5 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_add_6 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '6 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '6 weeks'::interval), true, 'Test Data', 2350555 from users u)
         ),
         all_day_appointments_add_7 as (
             insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
                 (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '7 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '7 weeks'::interval), true, 'Test Data', 2350555 from users u)
         )
         insert into flow.resource_appointment(company_id, user_id, start_time, end_time, all_day, description, created_by_id)
            (select 3, u.id, (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '8 weeks'::interval), (select date_trunc('week', now()::date) + case when u.id % 2 = 0 then '0 days'::interval else '1 days'::interval end + '8 weeks'::interval), true, 'Test Data', 2350555 from users u)
;
