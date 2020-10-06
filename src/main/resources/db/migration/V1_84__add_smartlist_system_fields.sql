alter table if exists flow.smartlist_field add if not exists join_table varchar;
alter table if exists flow.smartlist_field add if not exists join_column varchar;

insert into flow.smartlist_field (company_object_type_id, name, reference_table, reference_column, join_table, join_column, created_by_id, company_data_type_id)
values

(1, 'Project ID', 'flow.project', 'id', null, null, 2350555, 5),
(1, 'Project Name', 'flow.project', 'project_name', null, null, 2350555, 1),
(1, 'Project Created', 'flow.project', 'date_created', null, null, 2350555, 3),
(1, 'Project Street1', 'flow.project', 'street1', null, null, 2350555, 1),
(1, 'Project Street2', 'flow.project', 'street2', null, null, 2350555, 1),
(1, 'Project City', 'flow.project', 'city', null, null, 2350555, 1),
(1, 'Project State', 'flow.state', 'abbreviation', 'flow.project', 'state_id', 2350555, 1),
(1, 'Project Postal Code', 'flow.project', 'postal_code', null, null, 2350555, 1),

(2, 'Contact ID', 'flow.contact', 'id', null, null, 2350555, 5),
(2, 'Contact First Name', 'flow.contact', 'first_name', null, null, 2350555, 1),
(2, 'Contact Last Name', 'flow.contact', 'last_name', null, null, 2350555, 1),
(2, 'Contact Street1', 'flow.contact', 'street1', null, null, 2350555, 1),
(2, 'Contact Street2', 'flow.contact', 'street2', null, null, 2350555, 1),
(2, 'Contact City', 'flow.contact', 'city', null, null, 2350555, 1),
(2, 'Contact State', 'flow.state', 'abbreviation', 'flow.contact', 'state_id', 2350555, 1),
(2, 'Contact Postal Code', 'flow.contact', 'postal_code', null, null, 2350555, 1),
(2, 'Contact Phone', 'flow.contact', 'phone', null, null, 2350555, 1),
(2, 'Contact Email', 'flow.contact', 'email', null, null, 2350555, 1),
(2, 'Contact Mobile', 'flow.contact', 'mobile', null, null, 2350555, 1),
(2, 'Contact Mailing Street1', 'flow.contact', 'mailing_street1', null, null, 2350555, 1),
(2, 'Contact Mailing Street2', 'flow.contact', 'mailing_street2', null, null, 2350555, 1),
(2, 'Contact Mailing City', 'flow.contact', 'mailing_city', null, null, 2350555, 1),
(2, 'Contact Mailing State', 'flow.contact', 'mailing_state', null, null, 2350555, 1),
(2, 'Contact Mailing Postal Code', 'flow.contact', 'mailing_postal_code', null, null, 2350555, 1),
(2, 'Contact Created', 'flow.contact', 'date_created', null, null, 2350555, 3),
(2, 'Contact Title', 'flow.contact', 'title', null, null, 2350555, 1),

(4, 'Process Step ID', 'flow.project_process_step', 'id', null, null, 2350555, 5),
(4, 'Process Step Name', 'flow.process_step', 'process_step_name', null, null, 2350555, 1),
(4, 'Process Step Created', 'flow.project_process_step', 'date_created', null, null, 2350555, 3),
(4, 'Process Step Status', 'flow.company_process_step_status_type', 'process_step_status_type', 'flow.project_process_step', 'company_process_step_status_type_id', 2350555, 1);
