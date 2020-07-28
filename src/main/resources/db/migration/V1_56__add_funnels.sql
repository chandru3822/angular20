CREATE TABLE IF NOT EXISTS brs.funnel (
    id                            integer        not null
        constraint pk_funnel
            primary key,
    name                          varchar(100)   not null,
    ratio                         numeric(10, 2) not null,
    display_order                 integer        not null
);

CREATE TABLE IF NOT EXISTS brs.setter_funnel
(
    id                            integer        not null
        constraint pk_setter_funnel_dim
            primary key,
    name                          varchar(100)   not null,
    ratio                         numeric(10, 2) not null,
    display_order                 integer        not null
);
