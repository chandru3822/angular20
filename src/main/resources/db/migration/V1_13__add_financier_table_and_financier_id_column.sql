CREATE TABLE IF NOT EXISTS brs.financier
(
    id                serial        not null,
    name              varchar(100)  not null,
    submission_method varchar(255),
    archived          boolean       default false,
    date_created      timestamp without time zone DEFAULT now(),
    created_by_id     integer,
    date_modified     timestamp without time zone,
    modified_by_id    integer,
    CONSTRAINT financier_pkey PRIMARY KEY (id),
    CONSTRAINT financier_name_key UNIQUE (name),
    CONSTRAINT financier_created_by_id_fkey FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT financier_modified_by_id_fkey FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE brs.ahj_utility
    ADD COLUMN IF NOT EXISTS financier_id INTEGER REFERENCES brs.financier(id);
