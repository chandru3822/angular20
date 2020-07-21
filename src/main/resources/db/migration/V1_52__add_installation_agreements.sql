CREATE TABLE if NOT EXISTS brs.installation_agreement_requests
(
    id                                            serial                not null
        constraint pk_installation_agreement_requests
            primary key,
    project_id                                    integer               not null
        constraint fk_installation_agreement_request_project_id
            references flow.project,
    proposal_nbr                                  integer               not null,
    request_successful                            boolean               not null,
    user_id                                       integer
        constraint fk_installation_agreement_request_user
            references flow.user,
    created_date                                  timestamp,
    send_installation_agreement                   boolean default false,
    is_spanish                                    boolean default false not null
);
