drop index if exists flow_contact_mobile_idx;

create index if not exists flow_contact_mobile_idx
    on flow.contact using gin ((trim(translate(mobile, '()-+. ', ''))) gin_trgm_ops);

drop index if exists flow_contact_full_name_idx;

create index if not exists flow_contact_full_name_idx
    on flow.contact using gin ((lower(translate(coalesce(first_name, ''), '*,.&', '')) || ' ' ||
                                lower(translate(coalesce(last_name, ''), '*,.&', '')))
                               gin_trgm_ops);
