insert into flow.feature_access_control (feature_id, access_control_id, created_by_id, modified_by_id)
VALUES ((select id from flow.feature where feature_code = 'AHJ'), (select id from flow.access_control where access_code = 'ADMIN'), 99999999,99999999),
       ((select id from flow.feature where feature_code = 'HOA'), (select id from flow.access_control where access_code = 'ADMIN'), 99999999,99999999),
       ((select id from flow.feature where feature_code = 'INCENTIVE'), (select id from flow.access_control where access_code = 'ADMIN'), 99999999,99999999),
       ((select id from flow.feature where feature_code = 'SUPPLIERS'), (select id from flow.access_control where access_code = 'ADMIN'), 99999999,99999999),
       ((select id from flow.feature where feature_code = 'UTILITY'), (select id from flow.access_control where access_code = 'ADMIN'), 99999999,99999999)
on conflict do nothing;
