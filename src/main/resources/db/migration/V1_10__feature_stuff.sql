ALTER TABLE if exists flow.feature_access_control
    RENAME TO role_feature_access_control;

ALTER TABLE if exists flow.user_feature_access_control_override
    RENAME TO user_feature_access_control;

alter table flow.role_feature_access_control
    rename column archived to enabled;
