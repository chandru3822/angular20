--populate all the uuids
update flow.attachment
set uuid = uuid_generate_v4()
where uuid is null;

--make the uuid column required
ALTER TABLE flow.attachment ALTER COLUMN uuid SET NOT NULL;
