alter table flow.resource_appointment
  add column if not exists origin_timezone varchar(255);
alter table flow.resource_appointment
  add column if not exists origin_timezone_offset int;

--write script to update ^^ using user's org


-- write script to adjust recurring appts between nov 7th and march 13 2022 (2:am mtn)

