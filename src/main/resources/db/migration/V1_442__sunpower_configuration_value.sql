insert into flow.company_configuration_value(company_id, name, code, value, created_by_id)
select 3, 'SunPower Dolphin Portal User IDs', 'DOLPHIN_USER_IDS','2419024,2413520,2424722,2393253,2356764', 2350555
where not exists(select id
                 from flow.company_configuration_value
                 where code = 'DOLPHIN_USER_IDS');
