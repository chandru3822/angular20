create index if not exists notification_metadata_projectId_ix on flow.notification using btree (((metadata -> 'projectId')::integer));
create index if not exists notification_metadata_smsTeamId_ix on flow.notification using btree (((metadata -> 'smsTeamId')::integer));
