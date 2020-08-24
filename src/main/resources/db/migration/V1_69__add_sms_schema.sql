CREATE TABLE if not exists flow.record_type
(
  id SERIAL PRIMARY KEY NOT NULL,
  type CHARACTER VARYING(100)
);

INSERT INTO flow.record_type(id, type)
  VALUES (1, 'USER') ON CONFLICT ("id") DO NOTHING;

INSERT INTO flow.record_type(id, type)
  VALUES (2, 'DEAL') ON CONFLICT ("id") DO NOTHING;

INSERT INTO flow.record_type(id, type)
  VALUES (3, 'CUSTOMER') ON CONFLICT ("id") DO NOTHING;

CREATE TABLE if not exists flow.sms_queue
(
    id                serial  not null
        constraint sms_queue_pkey
            primary key,
    user_id           integer not null
        constraint sms_queue_user_id_fkey
            references flow.user,
    message           text    not null,
    media_urls        text[],
    message_group     varchar(60),
    message_sid       varchar(40),
    message_status    varchar(20),
    error_message     text,
    from_phone        varchar(20),
    to_phone          varchar(20),
    twilio_created    timestamp,
    twilio_sent       timestamp,
    twilio_delivered  timestamp,
    updated           timestamp,
    created           timestamp default now(),
    recipient_type_id integer   default 1
        constraint sms_queue_recipient_type_id_fkey
            references flow.record_type
);


CREATE index if not exists sms_queue_message_sid_index
    on flow.sms_queue (message_sid);

CREATE index if not exists sms_queue_to_phone_idx
    on flow.sms_queue (to_phone);


CREATE TABLE if not exists flow.sms_reply
(
    id                    serial not null
        constraint sms_reply_pkey
            primary key,
    message_sid           varchar(35),
    account_sid           varchar(35),
    messaging_service_sid varchar(35),
    from_phone            varchar(20),
    to_phone              varchar(20),
    body                  text,
    num_media             integer,
    date_received         timestamp default now()
);

CREATE index if not exists sms_reply_from_phone_idx
    on flow.sms_reply (from_phone);
