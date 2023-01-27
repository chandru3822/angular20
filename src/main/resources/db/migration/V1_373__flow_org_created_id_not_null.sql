update flow.org set created_by_id = 99999999 where created_by_id is null;
alter table flow.org alter column created_by_id set not null;
