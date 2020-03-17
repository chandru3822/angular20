alter table if exists flow.project rename column customer_id to contact_id;
alter table if exists flow.customer_note rename column customer_id to contact_id;
alter table if exists flow.customer_custom_field_value rename column customer_id to contact_id;
alter table if exists flow.customer rename column customer_type_id to contact_type_id;
alter table if exists flow.customer_custom_field_value_audit rename column customer_custom_field_value_id to contact_custom_field_value_id;
alter table if exists flow.customer_type rename column customer_type to contact_type;

ALTER TABLE if exists flow.customer RENAME TO contact;
ALTER TABLE if exists flow.customer_custom_field_value RENAME TO contact_custom_field_value;
ALTER TABLE if exists flow.customer_note RENAME TO contact_note;
ALTER TABLE if exists flow.customer_type RENAME TO contact_type;
ALTER TABLE if exists flow.customer_custom_field_value_audit RENAME TO contact_custom_field_value_audit;


