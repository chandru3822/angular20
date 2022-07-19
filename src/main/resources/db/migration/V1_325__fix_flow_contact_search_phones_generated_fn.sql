alter table flow.contact
  add column if not exists search_phones1 varchar generated always as ((right(translate(
                                                                                (COALESCE(nullif(mobile, ''),
                                                                                          nullif(phone, ''),
                                                                                          ''::character varying))::text,
                                                                                '+-() '::text, ''::text),
                                                                              10))) stored;

drop index if exists flow.flow_contact1_search_phones_ix;

alter table flow.contact
  drop column if exists search_phones;

alter table flow.contact
  rename column search_phones1 to search_phones;

--index for "like" queries
create index if not exists flow_contact_search_phones_ix
  on flow.contact using gin (search_phones gin_trgm_ops);

--index for equality queries
create index if not exists flow_contact1_search_phones_ix
  on flow.contact (search_phones);

