CREATE TABLE if not exists flow.announcement
(
    id             bigserial NOT NULL,
    title   text,
    alert_text   text,
    subtitle   text,
    description   text,
    hyperlink   text,
    attachment_id bigint,
    start_time timestamp without time zone not null,
    end_time timestamp without time zone,
    published boolean not null default false,
    expandable boolean not null default false,
    show_on_web boolean not null default false,
    show_on_mobile boolean not null default false,
    company_id     bigint    NOT NULL,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified  timestamp without time zone DEFAULT now(),
    created_by_id  integer   not null,
    modified_by_id integer,
    archived       boolean   not null          default false,
    CONSTRAINT flow_announcement_pk PRIMARY KEY (id),
    CONSTRAINT a_attachment_id_fk FOREIGN KEY (attachment_id)
        REFERENCES flow.attachment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_at_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_a_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_a_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ann_attachment_id_idx ON flow.announcement (attachment_id);
CREATE INDEX if not exists ann_start_time_idx ON flow.announcement (start_time);
CREATE INDEX if not exists ann_end_time_idx ON flow.announcement (end_time);

insert into flow.attachment_type(attachment_type, attachment_code, company_id, key_pattern_id, is_system, created_by_id, modified_by_id)
select 'Announcement', 'ANNOUNCEMENT', 3, 9, true, 2417170, 2417170
where not exists (select id from flow.attachment_type where attachment_code = 'ANNOUNCEMENT');

CREATE TABLE if not exists flow.user_announcement
(
    id             bigserial NOT NULL,
    user_id   bigint not null,
    announcement_id bigint not null,
    message_seen_tsz      timestamptz,
    message_read_tsz      timestamptz,
    CONSTRAINT flow_user_announcement_pk PRIMARY KEY (id),
    CONSTRAINT ua_announcement_id_fk FOREIGN KEY (announcement_id)
        REFERENCES flow.announcement (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_ua_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists uann_announcement_id_idx ON flow.user_announcement (announcement_id);
CREATE INDEX if not exists uann_user_id_idx ON flow.user_announcement (user_id);
create unique index if not exists uaan_announcment_user_ux on flow.user_announcement (user_id, announcement_id);
