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

    CONSTRAINT flow_user_slot_schedules_user_id_fk
        FOREIGN KEY (user_id)
        REFERENCES flow.user(id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT flow_user_slot_schedules_slot_schedule_id_fk
        FOREIGN KEY (slot_schedule_id)
        REFERENCES flow.resource_slot_schedule(id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
);
