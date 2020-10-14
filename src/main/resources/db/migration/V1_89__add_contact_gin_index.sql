create index if not exists flow_contact_full_name_idx
    on flow.contact using gin ((lower(translate(coalesce(first_name, ''), '*,.& ', '')) || ' ' ||
                                lower(translate(coalesce(last_name, ''), '*,.& ', '')))
                               gin_trgm_ops);

create index if not exists flow_contact_email_idx
    on flow.contact using gin ((lower(trim(email))) gin_trgm_ops);

create index if not exists flow_contact_phone_idx
    on flow.contact using gin ((trim(translate(phone, '()-+. ', ''))) gin_trgm_ops);

create index if not exists flow_contact_address_idx
    on flow.contact using gin ((lower(trim(translate(coalesce(street1, ''), '.,', ''))) || ' ' ||
                                lower(trim(translate(coalesce(street2, ''), '.,', ''))))
                               gin_trgm_ops);
