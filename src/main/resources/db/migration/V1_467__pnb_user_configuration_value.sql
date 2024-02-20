insert into flow.company_configuration_value(company_id, name, code, value, created_by_id)
select 3, 'Pitched Not Booked Excluded User IDs', 'PNB_EXCLUDED_USER_IDS','2466134,2446556,2403308', 2350555
where not exists(select id
                 from flow.company_configuration_value
                 where code = 'PNB_EXCLUDED_USER_IDS');
