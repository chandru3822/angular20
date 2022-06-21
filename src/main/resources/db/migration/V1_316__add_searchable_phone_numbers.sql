alter table flow.contact
  drop column if exists search_ts;
alter table flow.project
  drop column if exists search_ts;

alter table flow.contact
  add column if not exists search_phones varchar generated always as ((right(translate(
                                                                               (COALESCE(mobile, phone, ''::character varying))::text,
                                                                               '+-() '::text, ''::text), 10))) stored;


create index if not exists flow_contact1_search_phones_ix
  on flow.contact (search_phones);



alter table flow.sms_reply
  add column if not exists search_from_phone varchar generated always as ((right(translate(
                                                                                   (COALESCE(from_phone, ''::character varying))::text,
                                                                                   '+-() '::text, ''::text),
                                                                                 10))) stored;

create index if not exists flow_sms_reply_search_from_phone_ix
  on flow.sms_reply (search_from_phone);

alter table flow.sms_queue
  add column if not exists search_to_phone varchar generated always as ((right(translate(
                                                                                 (COALESCE(to_phone, ''::character varying))::text,
                                                                                 '+-() '::text, ''::text), 10))) stored;

create index if not exists flow_sms_queue_search_to_phone_ix
  on flow.sms_queue (search_to_phone);


