-- delete all duplicate rows before adding unique indexes
delete from flow.user_feature_access_control ufac
    using (select max(id) maxId, user_id, company_feature_id, access_control_id, count(*)
           from flow.user_feature_access_control
           group by user_id, company_feature_id, access_control_id
           having count(*) > 1) as foo
where ufac.user_id = foo.user_id
  and ufac.company_feature_id = foo.company_feature_id
  and ufac.access_control_id = foo.access_control_id
  and ufac.id != foo.maxId;

CREATE UNIQUE INDEX IF NOT EXISTS user_feature_access_uniq_idx
    ON flow.user_feature_access_control (user_id, company_feature_id, access_control_id);

-- currently there are no dupes in the position access control table so i didn't delete them
CREATE UNIQUE INDEX IF NOT EXISTS position_feature_access_uniq_idx
    ON flow.position_feature_access_control (position_id, company_feature_id, access_control_id);

