CREATE TABLE if not exists flow.emails_sent
(
    id                serial  not null
        constraint emails_sent_pkey
            primary key,
    user_id           integer not null
        constraint emails_sent_user_id_fkey
            references flow.user,
    subject           text    not null,
    message           text    not null,
    attachments           text,
    from_email        varchar(255),
    to_email          varchar(255),
    created           timestamp default now()
);
