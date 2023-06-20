create table if not exists flow.interaction_timer(
    id serial  NOT NULL,
    user_id integer,
    project_id integer,
    start_timestamp timestamp without time zone NOT NULL,
    end_timestamp timestamp without time zone NOT NULL,
    timer_type varchar(100) NOT NULL,
    start_event varchar(100),
    end_event varchar(100)
);
