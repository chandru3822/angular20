drop table if exists flow.push_notification_queue;
create table if not exists flow.push_notification_queue
(
    id                bigserial,
    title           text                                                                          not null,
    message           text                                                                          not null,
    web_hyperlink           text                                                                          not null,
    send_to_user_id     bigint                                                                        not null,
    phone_number     text                                                                        not null,
    created_by_id     bigint                                                                        not null,
    date_created           timestamp                default now(),
    processed         boolean                  default false                                        not null,
    date_processed    timestamp,
    date_modified     timestamp with time zone default now()                                        not null,
    CONSTRAINT flow_push_notification_queue_pk PRIMARY KEY (id),
    CONSTRAINT flow_ht_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_ht_send_to_user_id_fk FOREIGN KEY (send_to_user_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pnq_created_by_id_idx ON flow.push_notification_queue (created_by_id);
CREATE INDEX if not exists pnq_send_to_user_id_idx ON flow.push_notification_queue (send_to_user_id);

