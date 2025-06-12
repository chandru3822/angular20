-- schedule slot to particular user
CREATE TABLE flow.user_slot_schedules (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    slot_schedule_id BIGINT,
    date_created TIMESTAMP,
    date_modified TIMESTAMP,
    created_by_id BIGINT,
    modified_by_id BIGINT,
	  archived boolean default false
);
