-- remove times from all-day appointments
update flow.resource_appointment
set start_time = date_trunc('day', start_time),
    end_time = case
                 when date_part('hour', end_time) <= 8 then date_trunc('day', end_time)
                 else date_trunc('day', end_time) + interval '1 day'
               end
where all_day is true;
