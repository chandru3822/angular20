insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
    (select (select id from flow.feature where feature_code = 'ELECTRONIC_DOCUMENTS'), ac.id, 2350555
     from flow.access_control ac
     where not exists (
             select fac.id
             from flow.feature_access_control fac
             where feature_id = (select id from flow.feature where feature_code = 'ELECTRONIC_DOCUMENTS')
               and access_control_id = ac.id
         )
       and ac.id in (8)
    );
