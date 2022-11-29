update flow.access_control set access_level = 'view custom', access_code = 'VIEW_CUSTOM' where id = 7;

insert into flow.feature_access_control (feature_id, access_control_id, created_by_id)
select 34, 7, 2417170
  where not exists (
        select id from flow.feature_access_control where feature_id = 34 and access_control_id = 7 and archived is false
    );

ALTER TABLE flow.app_attachment ADD COLUMN IF NOT EXISTS beta BOOLEAN NOT NULL DEFAULT FALSE;
