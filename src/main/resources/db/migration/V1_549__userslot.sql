-- schedule slot to particular user
CREATE TABLE IF NOT EXISTS flow.user_slot_schedules (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    slot_schedule_id BIGINT,
    date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    date_modified TIMESTAMP WITHOUT TIME ZONE,
    created_by_id INTEGER NOT NULL,
    modified_by_id INTEGER,
    archived BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES flow.user(id),
    CONSTRAINT fk_slot_schedule FOREIGN KEY (slot_schedule_id) REFERENCES flow.resource_slot_schedule(id)
);
