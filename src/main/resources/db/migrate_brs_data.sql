--------------------------------------------------------------------------------
-- start fresh: wipe out any data previously migrated
--------------------------------------------------------------------------------
-- ha, kidding! i can't think of a clean way to reverse just the
-- changes made in this file


--------------------------------------------------------------------------------
-- copy over brs data
--------------------------------------------------------------------------------

insert into flow.state
select *
from blueraven.state;

SELECT setval('flow.state_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.state), 1), false);


INSERT INTO flow.org_level (company_id, level,level_name)
VALUES (1, 1,'Parent'),
       (1, 2,'Organization'),
       (1, 3,'Department'),
       (1, 4,'Region'),
       (1, 5,'Office');

INSERT INTO flow.org_filter (org_level_id, rank, show_type)
VALUES (2, 1, false),
       (3, 2, false),
       (4, 3, false),
       (5, 4, true);


insert into flow.org_type(org_type, org_parent_type_id, org_level_id, company_id)
(select org_type, org_parent_type_id, case when level is null then 1 else level end, 1
from blueraven.org_type);

SELECT setval('flow.org_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.org_type), 1), false);


INSERT INTO flow.org(company_id, id, org_name, parent_org_id, sales_area_id, org_type_id,
                    display_order, active_flag, color, email, calendar_oid, sales_metro_area_id,
                    originator_id)
    (select 1,
            id,
            org_name,
            parent_org_id,
            sales_area_id,
            org_type_id,
            display_order,
            active_flag,
            color,
            email,
            calendar_oid,
            sales_metro_area_id,
            originator_id
     from blueraven.org);

SELECT setval('flow.org_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.org), 1), false);


update flow.org set owning_org = true where org_type_id = 10;

INSERT INTO flow."position"(id, company_id, "position", org_type_id, secondary_org_type_id,
                           active)
    (select id,
            1,
            "position",
            org_type_id,
            secondary_org_type_id,
            active
     from blueraven.position);

SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);



--------------------------------------------------------------------------------
-- import user data from blueraven schema
--------------------------------------------------------------------------------
INSERT INTO flow."user" (company_id,
                         onboarded_by_user_id,
                         end_date,
                         employment_type_id,
                         phone_number,
                         hire_date,
                         id,
                         email,
                         created_by_id,
                         compensation_type_id,
                         image_id,
                         personal_email,
                         last_name,
                         employee_id,
                         recruited_by,
                         referred_by_user_id,
                         first_name,
                         date_created,
                         password,
                         start_date,
                         date_modified,
                         notes,
                         recruited_by_user_id,
                         modified_by_id,
                         user_status_type_id,
                         username)
    (SELECT 1,
            onboarded_by_user_id,
            end_date,
            employment_type_id,
            phone_number,
            hire_date,
            id,
            email,
            created_by,
            compensation_type_id,
            image_id,
            personal_email,
            last_name,
            employee_id,
            recruited_by,
            referred_by_user_id,
            first_name,
            created_dt,
            password,
            start_date,
            modified_dt,
            notes,
            recruited_by_user_id,
            modified_by,
            user_status_type_id,
            email
     FROM blueraven."user");


-- Update the sequence
SELECT setval('flow.user_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.user where id != 99999999), 1), false);


insert into flow.user_position
select *
from blueraven.user_position;

SELECT setval('flow.user_position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.user_position), 1), false);


insert into brs.sales_area_type(id, sales_area_type)
    (select id, sales_area_type
     from blueraven.sales_area_type);

SELECT setval('brs.sales_area_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.sales_area_type), 1), false);


insert into brs.sales_area(id, area, sales_area_type_id, state_id)
    (select id, area, sales_area_type_id, state_id
     from blueraven.sales_area);

SELECT setval('brs.sales_area_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.sales_area), 1), false);


insert into brs.sales_metro_area(id, sales_metro_area, sales_area_id, archived, final_design_minimum, fixed_grace_days)
    (select id,
            sales_metro_area,
            sales_area_id,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            final_design_minimum,
            fixed_grace_days
     from blueraven.sales_metro_area);

SELECT setval('brs.sales_metro_area_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.sales_metro_area), 1), false);


insert into brs.podium_location(id, podium_id, name, date_created, date_modified)
    (select id, podium_id, name, date_created, date_updated
     from blueraven.podium_location);

SELECT setval('brs.podium_location_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.podium_location), 1), false);


insert into brs.birdeye_location(business_id, alias)
    (select business_id, alias
     from blueraven.birdeye_locations);


INSERT INTO flow.permission(id, company_id, permission_name, permission_code, archived)
    (select id, 1, permission_name, permission_code, archived
     from blueraven.permission);

SELECT setval('flow.permission_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.permission), 1), false);


INSERT INTO flow.role(id, company_id, role_name, archived)
    (select id, 1, role_name, archived
     from blueraven.role);

SELECT setval('flow.role_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.role), 1), false);


insert into flow.role_permission
select *
from blueraven.role_permission;

SELECT setval('flow.role_permission_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.role_permission), 1), false);


insert into flow.user_role
select *
from blueraven.user_role;

SELECT setval('flow.user_role_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.user_role), 1), false);


insert into flow.user_permission(user_id,
                                permission_id,
                                deny)
    (select user_id, permission_id, true from blueraven.user_deny_permission);

SELECT setval('flow.user_permission_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.user_permission), 1), false);


insert into flow.asset_type
select *
from blueraven.asset_type;

SELECT setval('flow.asset_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.asset_type), 1), false);


INSERT INTO flow.asset(id, company_id, tag, model, asset_type_id, active, archived)
    (select id, 1, tag, model, asset_type_id, active, archived
     from blueraven.asset);

SELECT setval('flow.asset_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.asset), 1), false);


insert into flow.user_asset
select *
from blueraven.user_asset;

SELECT setval('flow.user_asset_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.user_asset), 1), false);


insert into brs.budget_type(id, name, archived, date_created, date_modified)/
    (select id,
            name,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            date_created,
            date_updated
     from blueraven.budget_type);

SELECT setval('brs.budget_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.budget_type), 1), false);


insert into brs.budget_template(id, user_id, budget_type_id, amount, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select id,
            user_id,
            budget_type_id,
            amount,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            date_created,
            created_by_id,
            date_updated,
            updated_by_id
     from blueraven.budget_template);

SELECT setval('brs.budget_template_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.budget_template), 1), false);


insert into brs.expense_budget(id, user_id, budget_type_id, amount, archived, date_created, created_by_id, date_modified, modified_by_id, start_date, end_date, original_expense_budget_id, notes)
    (select id, user_id, budget_type_id, amount, archived, date_created, created_by_id, date_updated, updated_by_id, start_date, end_date, original_expense_budget_id, notes
     from blueraven.expense_budget);

SELECT setval('brs.expense_budget_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.expense_budget), 1), false);


insert into brs.reimbursement_request_status(id, reimbursement_request_status)
    (select id, reimbursement_request_status
     from blueraven.reimbursement_request_status);

SELECT setval('brs.reimbursement_request_status_id_seq',
              COALESCE((SELECT MAX(id) + 1 FROM brs.reimbursement_request_status), 1), false);

insert into flow.key_pattern
    (select * from blueraven.key_pattern);


insert into flow.attachment_type(id, attachment_type,attachment_code,company_id,key_pattern_id,is_system)
    (select id, type,type,1,key_pattern_id,true
     from blueraven.attachment_source_type);

SELECT setval('flow.attachment_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.attachment_type), 1), false);


INSERT INTO flow.attachment(id, filename, content_type, s3_key, size, archived, date_created, date_modified,attachment_type_id)
                                    (select a.id, filename, content_type, s3_key, size, deleted, created, updated,as1.attachment_source_type_id
                                     from blueraven.attachment a
                                              inner join blueraven.attachment_source as1 on as1.attachment_id = a.id);

SELECT setval('flow.attachment_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.attachment), 1), false);


insert into brs.reimbursement_request(id, details, notes, amount, expense_budget_id, attachment_id, expense_date, archived, date_created, created_by_id, date_modified, reimbursement_request_status_id)
    (select id, details, notes, amount, expense_budget_id, attachment_id, expense_date, archived, date_created, created_by_user_id, date_updated, reimbursement_request_status_id
     from blueraven.reimbursement_request);

SELECT setval('brs.reimbursement_request_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.reimbursement_request), 1),
              false);


insert into brs.gl_code(id, code, description, archived, date_created, date_modified)
    (select id,
            code,
            description,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            date_created,
            date_updated
     from blueraven.gl_code);

SELECT setval('brs.gl_code_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.gl_code), 1), false);


insert into brs.expense(id, user_id, expense_budget_id, gl_code_id, notes, expense_date, expense_amount, archived, date_created, date_modified, modified_by_id, date_submitted, submitted_by_id, reimbursement_request_id, approval_date, approved_by_id, paid_date, paid_by_id, skip_approval, rejected_date, rejected_by_id)
    (select id, user_id, expense_budget_id, gl_code_id, notes, expense_date, expense_amount, archived, date_created, date_updated, updated_by_id, date_submitted, submitted_by_id, reimbursement_request_id, approval_date, approved_by_id, paid_date, paid_by_id, skip_approval, rejected_date, rejected_by_id
     from blueraven.expense);

SELECT setval('brs.expense_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.expense), 1), false);


INSERT INTO brs.expense_gl_code(expense_id, gl_code_id, amount, date_created, date_modified)
    (select expense_id, gl_code_id, amount, date_created, date_updated
     from blueraven.expense_gl_code);

SELECT setval('brs.expense_gl_code_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.expense_gl_code), 1), false);


insert into brs.metro_area(id, metro_area, sales_area_id, archived)
    (select id,
            metro_area,
            sales_area_id,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END
     from blueraven.metro_area);

SELECT setval('brs.metro_area_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.metro_area), 1), false);


insert into brs.org_metro_area
select *
from blueraven.org_metro_area;

SELECT setval('brs.org_metro_area_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.org_metro_area), 1), false);


insert into flow.associated_org_type
select *
from blueraven.associated_org_type;

SELECT setval('flow.org_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.associated_org_type), 1), false);


insert into flow.associated_org
select *
from blueraven.associated_org;

SELECT setval('flow.associated_org_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.associated_org), 1), false);

insert into flow.attachment_source(id,attachment_id,source_id)
select id,attachment_id,source_id
from blueraven.attachment_source;

SELECT setval('flow.attachment_source_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.attachment_source), 1), false);


insert into brs.ahj(id, name, archived, date_created, created_by_id, date_modified, modified_by_id, metro_area_id)
    (select id, name, archived, created, created_by_id, updated, updated_by_id, metro_area_id
     from blueraven.ahj);

SELECT setval('brs.ahj_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj), 1), false);


insert into brs.custom_dropdown_screen
select *
from blueraven.custom_dropdown_screen;

SELECT setval('brs.custom_dropdown_screen_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.custom_dropdown_screen), 1),
              false);

insert into brs.custom_dropdown_field(id, field, code, custom_dropdown_screen_id, archived)
    (select id, field, code, custom_dropdown_screen_id, archived
     from blueraven.custom_dropdown_field);

SELECT setval('brs.custom_dropdown_field_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.custom_dropdown_field), 1),
              false);

insert into brs.custom_dropdown_value(id, title, custom_dropdown_field_id, archived, date_created, created_by_id, date_modified, modified_by_id, display_order)
    (select id, title, custom_dropdown_field_id, archived, created, created_by, updated, updated_by, display_order
     from blueraven.custom_dropdown_value);

SELECT setval('brs.custom_dropdown_value_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.custom_dropdown_field), 1),
              false);

insert into brs.ahj_utility(id, name, archived, date_created, date_modified, timelines_and_stages, regulated_by, monthly_facility_charge, population_of_service, net_metering_rate, rebate_rates, utility_rate_notes, customer_signature_instructions, expected_approval_timeline, rejection_instructions, notes, submission_instructions, final_completion_instructions, overview_of_submission_process, timelines, pto_followup_instructions, metro_area_id, ac_disconnect_required)
    (select id, name, CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END, date_created, date_updated, timelines_and_stages, regulated_by, monthly_facility_charge, population_of_service, net_metering_rate, rebate_rates, utility_rate_notes, customer_signature_instructions, expected_approval_timeline, rejection_instructions, notes, submission_instructions, final_completion_instructions, overview_of_submission_process, timelines, pto_followup_instructions, metro_area_id
     from blueraven.ahj_utility);

SELECT setval('brs.ahj_utility_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_utility), 1), false);

--1 General
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Phone Directory Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Greenlight Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Dividend Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Request Sunops App',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Ignition Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Application Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Dropbox Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Oneroof Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Dividend Spoof',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('i9 Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Confidentiality Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('W4 Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Quickbase Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Dividend Spoof Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Removed From Directory Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Cancelled Greenlight Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Cancelled Dividend Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Removed Sunops Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Removed Sales Rabbit Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Cancelled Ignition Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Reason for Termination',1,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Termination Notes',1,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Department',1,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Crew',1,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Employee Handbook Signed Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Enter in Timeforce Date ',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Expiry Date',3,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Dropbox Cancel Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Timeforce Cancel Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('E-Mail Opt Out Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Request T-Sheets Flag',4,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Phone Extension',1,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Drivers License Number',1,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Humanity Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('IT Onboarding Complete Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('IT Termination Complete Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Exit Interview Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Deactivate Badge Request Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Values Meeting Invite Sent Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Cooperate Meeting Invite Sent Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Values Meeting Attended Date',2,now(), 2350555,1);
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('New Hire Orientation Meeting Date',2,now(), 2350555,1);

--group 2
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Uniform/Badge Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Shirt Size',1,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Hat',1,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Accuity Appointment ID',5,now(), 2350555,1);

---systems group 5
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Namely Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Email Setup Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Request Base Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Base Contact Created Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Mosiac Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Litmos Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('T-Sheets Date',2,now(), 2350555,1);

---onboarding group 3
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Offer Letter Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Contract Request Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Contract Received Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Contract Saved Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Background Check Submitted Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id, company_id)
VALUES ('Background Check Received Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Welcome E-Mail Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Photo Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Voided Check Date',2,now(), 2350555,1);


--HR 4
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Re-Hire Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Pending Termination Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Termination Reason',1,now(), 2350555,1);


--6 termination
INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Cancelled Namely Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('E-Mail Removed Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Cancelled Base Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Base Contact Deleted Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Cancelled Mosiac Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Cancelled Litmos Date',2,now(), 2350555,1);

INSERT INTO flow.custom_field(
    field_name, company_data_type_id, date_created,
    created_by_id ,company_id)
VALUES ('Cancelled T-Sheets Date',2,now(), 2350555,1);


insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Phone Directory Date'
    );

insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Greenlight Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Dividend Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Request Sunops App'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Ignition Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Application Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Dropbox Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Oneroof Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Dividend Spoof'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'i9 Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Confidentiality Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'W4 Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Quickbase Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Dividend Spoof Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Removed From Directory Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cancelled Greenlight Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cancelled Dividend Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Removed Sunops Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Removed Sales Rabbit Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cancelled Ignition Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Reason for Termination'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Termination Notes'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Department'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Crew'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Employee Handbook Signed Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Enter in Timeforce Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Expiry Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Dropbox Cancel Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Timeforce Cancel Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'E-Mail Opt Out Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Request T-Sheets Flag'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Phone Extension'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Drivers License Number'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Humanity Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'IT Onboarding Complete Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'IT Termination Complete Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Exit Interview Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Deactivate Badge Request Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Values Meeting Invite Sent Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cooperate Meeting Invite Sent Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Values Meeting Attended Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'New Hire Orientation Meeting Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Uniform/Badge Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Shirt Size'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Hat'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Accuity Appointment ID'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Namely Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Email Setup Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Request Base Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Base Contact Created Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Mosiac Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Litmos Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'T-Sheets Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Offer Letter Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Contract Request Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Contract Received Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Contract Saved Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Background Check Submitted Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Background Check Received Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Welcome E-Mail Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Photo Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Voided Check Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Re-Hire Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Pending Termination Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Termination Reason'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cancelled Namely Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'E-Mail Removed Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cancelled Base Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Base Contact Deleted Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cancelled Mosiac Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cancelled Litmos Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,3
     from flow.custom_field cf
     where cf.field_name = 'Cancelled T-Sheets Date'
    );



INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order, archived)
VALUES ('General',3, 6, true);

INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order)
VALUES ('Personal',3, 1);

INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order)
VALUES ('Onboarding',3, 2);

INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order)
VALUES ('HR',3, 3);

INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order)
VALUES ('Systems',3, 4);

INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order)
VALUES ('Termination',3, 5);

INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order)
VALUES ('Project PlaceHolder',1, 1);

INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order)
VALUES ('Customer PlaceHolder',2, 1);

INSERT INTO flow.custom_field_group(
    group_name,company_object_type_id, group_order)
VALUES ('Process Step PlaceHolder',4, 1);


INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
 (select (select id from flow.custom_field_group where group_name = 'Personal'),
  (select id from flow.custom_field where field_name = 'Uniform/Badge Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Personal'),
            (select id from flow.custom_field where field_name = 'Shirt Size'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Personal'),
            (select id from flow.custom_field where field_name = 'Hat'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Personal'),
            (select id from flow.custom_field where field_name = 'Accuity Appointment ID'),1,false, 2350555);


INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Systems'),
            (select id from flow.custom_field where field_name = 'Namely Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Systems'),
            (select id from flow.custom_field where field_name = 'Email Setup Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Systems'),
            (select id from flow.custom_field where field_name = 'Request Base Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Systems'),
            (select id from flow.custom_field where field_name = 'Base Contact Created Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Systems'),
            (select id from flow.custom_field where field_name = 'Mosiac Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Systems'),
            (select id from flow.custom_field where field_name = 'Litmos Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Systems'),
            (select id from flow.custom_field where field_name = 'T-Sheets Date'),1,false, 2350555);


INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Offer Letter Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Contract Request Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Contract Received Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Contract Saved Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Background Check Submitted Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Background Check Received Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Welcome E-Mail Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Photo Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Onboarding'),
            (select id from flow.custom_field where field_name = 'Voided Check Date'),1,false, 2350555);


INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'HR'),
            (select id from flow.custom_field where field_name = 'Re-Hire Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'HR'),
            (select id from flow.custom_field where field_name = 'Pending Termination Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'HR'),
            (select id from flow.custom_field where field_name = 'Termination Reason'),1,false, 2350555);



INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Termination'),
            (select id from flow.custom_field where field_name = 'Cancelled Namely Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Termination'),
            (select id from flow.custom_field where field_name = 'E-Mail Removed Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Termination'),
            (select id from flow.custom_field where field_name = 'Cancelled Base Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Termination'),
            (select id from flow.custom_field where field_name = 'Base Contact Deleted Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Termination'),
            (select id from flow.custom_field where field_name = 'Cancelled Mosiac Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Termination'),
            (select id from flow.custom_field where field_name = 'Cancelled Litmos Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Termination'),
            (select id from flow.custom_field where field_name = 'Cancelled T-Sheets Date'),1,false, 2350555);


INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Phone Directory Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Greenlight Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Dividend Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Request Sunops App'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Ignition Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Application Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Dropbox Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Oneroof Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Dividend Spoof'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'i9 Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Confidentiality Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'W4 Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Quickbase Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Dividend Spoof Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Removed From Directory Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Cancelled Greenlight Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Cancelled Dividend Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Removed Sunops Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Removed Sales Rabbit Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Cancelled Ignition Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Reason for Termination'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Termination Notes'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Department'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Crew'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Employee Handbook Signed Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Enter in Timeforce Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Expiry Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Dropbox Cancel Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Timeforce Cancel Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'E-Mail Opt Out Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Request T-Sheets Flag'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Phone Extension'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Drivers License Number'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Humanity Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'IT Onboarding Complete Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'IT Termination Complete Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Exit Interview Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Deactivate Badge Request Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Values Meeting Invite Sent Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Cooperate Meeting Invite Sent Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'Values Meeting Attended Date'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'General'),
            (select id from flow.custom_field where field_name = 'New Hire Orientation Meeting Date'),1,false, 2350555);



INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Phone Directory Date') as custom_field_id,
            phone_directory_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE phone_directory_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Greenlight Date') as custom_field_id,
            greenlight_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE greenlight_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Date') as custom_field_id,
            dividend_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE dividend_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request Sunops App') as custom_field_id,
            request_sunops_app,
            2350555 as created_by_id
     FROM blueraven.user WHERE request_sunops_app IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ignition Date') as custom_field_id,
            ignition_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE ignition_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Application Date') as custom_field_id,
            application_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE application_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dropbox Date') as custom_field_id,
            dropbox_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE dropbox_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Oneroof Date') as custom_field_id,
            oneroof_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE oneroof_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Spoof') as custom_field_id,
            dividend_spoof,
            2350555 as created_by_id
     FROM blueraven.user WHERE dividend_spoof IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'i9 Date') as custom_field_id,
            i9_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE i9_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'W4 Date') as custom_field_id,
            w4_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE w4_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Quickbase Date') as custom_field_id,
            quickbase_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE quickbase_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Spoof Date') as custom_field_id,
            dividend_spoof_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE dividend_spoof_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed From Directory Date') as custom_field_id,
            removed_from_directory_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE removed_from_directory_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Greenlight Date') as custom_field_id,
            cancelled_greenlight_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE cancelled_greenlight_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Dividend Date') as custom_field_id,
            cancelled_dividend_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE cancelled_dividend_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed Sunops Date') as custom_field_id,
            removed_sunops_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE removed_sunops_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed Sales Rabbit Date') as custom_field_id,
            removed_sales_rabbit_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE removed_sales_rabbit_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Ignition Date') as custom_field_id,
            cancelled_ignition_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE cancelled_ignition_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Reason for Termination') as custom_field_id,
            reason_for_termination,
            2350555 as created_by_id
     FROM blueraven.user WHERE reason_for_termination IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Termination Notes') as custom_field_id,
            termination_notes,
            2350555 as created_by_id
     FROM blueraven.user WHERE termination_notes IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Department') as custom_field_id,
            department,
            2350555 as created_by_id
     FROM blueraven.user WHERE department IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Crew') as custom_field_id,
            crew,
            2350555 as created_by_id
     FROM blueraven.user WHERE crew IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Employee Handbook Signed Date') as custom_field_id,
            employee_handbook_signed_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE employee_handbook_signed_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Enter in Timeforce Date ') as custom_field_id,
            enter_in_timeforce_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE enter_in_timeforce_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, timestamp_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Expiry Date') as custom_field_id,
            expiry_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE expiry_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dropbox Cancel Date') as custom_field_id,
            dropbox_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE dropbox_cancel_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Timeforce Cancel Date') as custom_field_id,
            timeforce_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE timeforce_cancel_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'E-Mail Opt Out Date') as custom_field_id,
            email_opt_out_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE email_opt_out_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, boolean_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request T-Sheets Flag') as custom_field_id,
            request_tsheets_flag,
            2350555 as created_by_id
     FROM blueraven.user WHERE request_tsheets_flag IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Phone Extension') as custom_field_id,
            phone_extension,
            2350555 as created_by_id
     FROM blueraven.user WHERE phone_extension IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Drivers License Number') as custom_field_id,
            drivers_license_number,
            2350555 as created_by_id
     FROM blueraven.user WHERE drivers_license_number IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Humanity Date') as custom_field_id,
            humanity_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE humanity_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'IT Onboarding Complete Date') as custom_field_id,
            it_onboarding_complete_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE it_onboarding_complete_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'IT Termination Complete Date') as custom_field_id,
            it_termination_complete_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE it_termination_complete_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Exit Interview Date') as custom_field_id,
            exit_interview_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE exit_interview_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Deactivate Badge Request Date') as custom_field_id,
            deactivate_badge_request_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE deactivate_badge_request_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Values Meeting Invite Sent Date') as custom_field_id,
            values_meeting_invite_sent_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE values_meeting_invite_sent_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cooperate Meeting Invite Sent Date') as custom_field_id,
            corporate_meeting_invite_sent_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE corporate_meeting_invite_sent_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Values Meeting Attended Date') as custom_field_id,
            values_meeting_attended_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE values_meeting_attended_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'New Hire Orientation Meeting Date') as custom_field_id,
            new_hire_orientation_meeting_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE new_hire_orientation_meeting_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Uniform/Badge Date') as custom_field_id,
            tshirt_hat_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE tshirt_hat_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Shirt Size') as custom_field_id,
            shirt_size,
            2350555 as created_by_id
     FROM blueraven.user WHERE shirt_size IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Hat') as custom_field_id,
            hat,
            2350555 as created_by_id
     FROM blueraven.user WHERE hat IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, numeric_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Accuity Appointment ID') as custom_field_id,
            accuity_appointment_id,
            2350555 as created_by_id
     FROM blueraven.user WHERE accuity_appointment_id IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Namely Date') as custom_field_id,
            enter_in_solved_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE enter_in_solved_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Email Setup Date') as custom_field_id,
            email_setup_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE email_setup_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request Base Date') as custom_field_id,
            request_base_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE request_base_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Base Contact Created Date') as custom_field_id,
            base_contact_created_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE base_contact_created_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Mosiac Date') as custom_field_id,
            mosaic_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE mosaic_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Litmos Date') as custom_field_id,
            trumpia_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE trumpia_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'T-Sheets Date') as custom_field_id,
            timesheets_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE timesheets_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Offer Letter Date') as custom_field_id,
            offer_letter_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE offer_letter_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Request Date') as custom_field_id,
            docusign_requested_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE docusign_requested_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Received Date') as custom_field_id,
            docusign_received_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE docusign_received_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Background Check Submitted Date') as custom_field_id,
            background_check_submitted_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE background_check_submitted_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Background Check Received Date') as custom_field_id,
            background_check_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE background_check_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Welcome E-Mail Date') as custom_field_id,
            welcome_email_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE welcome_email_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Photo Date') as custom_field_id,
            photo_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE photo_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Voided Check Date') as custom_field_id,
            voided_check_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE voided_check_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Re-Hire Date') as custom_field_id,
            re_hire_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE re_hire_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Pending Termination Date') as custom_field_id,
            pending_termination_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE pending_termination_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Termination Reason') as custom_field_id,
            termination_reason,
            2350555 as created_by_id
     FROM blueraven.user WHERE termination_reason IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Namely Date') as custom_field_id,
            cancelled_isolved_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE cancelled_isolved_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'E-Mail Removed Date') as custom_field_id,
            email_removed_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE email_removed_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Base Date') as custom_field_id,
            removed_base_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE removed_base_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Base Contact Deleted Date') as custom_field_id,
            cancelled_base_contact_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE cancelled_base_contact_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Mosiac Date') as custom_field_id,
            cancelled_mosaic_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE cancelled_mosaic_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Litmos Date') as custom_field_id,
            cancelled_trumpia_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE cancelled_trumpia_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Confidentiality Date') as custom_field_id,
            confidentiality_agreement_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE confidentiality_agreement_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Saved Date') as custom_field_id,
            docusign_saved_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE docusign_saved_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled T-Sheets Date') as custom_field_id,
            timesheet_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user WHERE timesheet_cancel_date IS NOT NULL);


--------------------------------------------------------------------------------
-- Migrate Customer Data
--------------------------------------------------------------------------------
-- create dummy customer type
INSERT INTO flow.customer_type (customer_type)
VALUES ('Customer');

INSERT INTO flow.customer_type (customer_type)
VALUES ('Lead');

-- migrate common customer data
INSERT INTO flow.customer (city,
                           country_id,
                           email,
                           first_name,
                           id,
                           last_name,
                           latitude,
                           location_unavailable,
                           longitude,
                           mailing_city,
                           mailing_postal_code,
                           mailing_state,
                           mailing_street1,
                           mailing_street2,
                           mobile,
                           phone,
                           postal_code,
                           prospect_status,
                           state,
                           street1,
                           street2,
                           time_zone,
                           customer_type_id,
                           created_by_id,
                           date_created,
                           company_id)
    (SELECT city,
            1,
            email,
            first_name,
            id,
            last_name,
            latitude,
            location_unavailable,
            longitude,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            time_zone,
            (select id from flow.customer_type where customer_type='Customer'),
            2350555 as created_by_id,
            created_date,
            1
     FROM blueraven.customer);


-- change the flow.customer id sequence so the imported ids don't cause problems
SELECT setval('flow.customer_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM flow.customer), 1), false);



-- change the flow.customer id sequence so the imported ids don't cause problems
SELECT setval('flow.customer_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM flow.customer), 1), false);

--TODO as Judson if we should mover over description from LEAD

INSERT INTO flow.customer (city,
                           country_id,
                           email,
                           first_name,
                           last_name,
                           mobile,
                           phone,
                           postal_code,
                           state,
                           street1,
                           street2,
                           customer_type_id,
                           created_by_id,
                           date_created,
                           company_id,
                           title,
                           owner_user_position_id,
                           migrate_lead_id)
    (SELECT city,
            1,
            email,
            substr(first_name,1,100),
            substr(last_name,1,100),
            mobile,
            phone,
            postal_code,
            state,
            street1,
            street2,
            (select id from flow.customer_type where customer_type='Lead'),
            2350555 as created_by_id,
            created_date,
            1,
            title,
            (select up.id
             from flow.user_position up
             where up.user_id = l.setter_user_id and primary_flag is true),
            id
     FROM blueraven.lead l);


update flow.customer c2
set state_id = (select s.id
                from flow.customer c
                         inner join flow.state s on s.state = c.state
                where c.id = c2.id);


with parent as (
    insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                    created_by_id, archived)
        values('Lead Source',null,1,now(),2350555,false)
        returning id ),
     t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                           created_by_id, archived)
         (select s.source_name,(select p.id from parent p),1,now(),2350555,s.archived
          from blueraven.source s
          where source_type = 'lead'))
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
    (select 'Source',
            7,
            now(),
            2350555,
            1,
            p.id
     from parent p
    );



with parent as (
    insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                    created_by_id, archived)
        values('Lead Source Detail',null,1,now(),2350555,false)
        returning id ),
     t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                           created_by_id, archived)
         (select s.lead_source_detail,(select p.id from parent p),1,now(),2350555,false
          from blueraven.lead s
          where s.lead_source_detail is not null
          group by s.lead_source_detail))
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
    (select 'Lead Source Detail',
            7,
            now(),
            2350555,
            1,
            p.id
     from parent p
    );

INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id)
VALUES ('Hubspot ID',
        5,
        now(),
        2350555,
        1);
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id)
VALUES ('Ricochet Lead ID',
        5,
        now(),
        2350555,
        1);



with parent as (
    insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                    created_by_id, archived)
        values('Lead Status',null,1,now(),2350555,false)
        returning id ),
     t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                           created_by_id, archived)
         (select s.status,(select p.id from parent p),1,now(),2350555,false
          from blueraven.lead s
          where s.lead_source_detail is not null
          group by s.status))
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
    (select 'Lead Status',
            7,
            now(),
            2350555,
            1,
            p.id
     from parent p
    );



insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,2
     from flow.custom_field cf
     where cf.field_name = 'Source'
    );

insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,2
     from flow.custom_field cf
     where cf.field_name = 'Lead Source Detail'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,2
     from flow.custom_field cf
     where cf.field_name = 'Hubspot ID'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,2
     from flow.custom_field cf
     where cf.field_name = 'Ricochet Lead ID'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,2
     from flow.custom_field cf
     where cf.field_name = 'Lead Status'
    );

INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Customer PlaceHolder'),
            (select id from flow.custom_field where field_name = 'Source'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Customer PlaceHolder'),
            (select id from flow.custom_field where field_name = 'Lead Source Detail'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Customer PlaceHolder'),
            (select id from flow.custom_field where field_name = 'Hubspot ID'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Customer PlaceHolder'),
            (select id from flow.custom_field where field_name = 'Ricochet Lead ID'),1,false, 2350555);
INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Customer PlaceHolder'),
            (select id from flow.custom_field where field_name = 'Lead Status'),1,false, 2350555);




-- migrate custom field values


INSERT INTO flow.customer_custom_field_value (customer_id, custom_field_group_assignment_id,int_value , created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Lead Source Detail') as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.lead l
              inner join flow.customer c on c.migrate_lead_id = l.id
              inner join flow.list_of_value lov on lov.name = l.lead_source_detail
     WHERE lead_source_detail IS NOT NULL
       and parent_id in (select id from flow.list_of_value lov2 where parent_id is null and lov2.name = 'Lead Source Detail'));


INSERT INTO flow.customer_custom_field_value (customer_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Source') as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.lead l
              inner join flow.customer c on c.migrate_lead_id = l.id
              inner join blueraven.source s on s.id = l.source_id
              inner join flow.list_of_value lov on lov.name = s.source_name
     WHERE l.source_id IS NOT NULL
       and parent_id in (select id from flow.list_of_value lov2 where parent_id is null and lov2.name = 'Lead Source'));

INSERT INTO flow.customer_custom_field_value (customer_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Hubspot ID') as custom_field_id,
            hub_spot_id,
            2350555 as created_by_id
     FROM blueraven.lead l
              inner join flow.customer c on c.migrate_lead_id = l.id
     WHERE hub_spot_id IS NOT NULL);
INSERT INTO flow.customer_custom_field_value (customer_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ricochet Lead ID') as custom_field_id,
            ricochet_lead_id,
            2350555 as created_by_id
     FROM blueraven.lead l  inner join flow.customer c on c.migrate_lead_id = l.id
     WHERE ricochet_lead_id IS NOT NULL);

INSERT INTO flow.customer_custom_field_value (customer_id, custom_field_group_assignment_id,int_value , created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Lead Status') as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.lead l
              inner join flow.customer c on c.migrate_lead_id = l.id
              inner join flow.list_of_value lov on lov.name = l.status
     WHERE status IS NOT NULL and
             parent_id in (select id from flow.list_of_value lov2 where parent_id is null and lov2.name = 'Lead Status'));

--------------------------------------------------------------------------------
-- migrate deals to flow.project
--------------------------------------------------------------------------------
-- create a generic Blueraven process
INSERT INTO flow.process (process_name, date_created, created_by_id, parent_company_id)
VALUES ('Generic Blueraven Process', now(), 2350555, 1);

-- tie together the process, status type, and BRS company together in flow.company_process
INSERT INTO flow.company_process (company_id, process_id, status_type_id)
VALUES (1,
        (select id from flow.process where process_name = 'Generic Blueraven Process'),
        (select id from flow.status_type where status_type.status_type = 'Active'));

-- copy over the common deal/project fields
INSERT INTO flow.project (id,
                          customer_id,
                          project_name,
                          created_by_id,
                          company_process_id,
                          date_created)
    (SELECT id,
            customer_id,
            customer_name,
            2350555,
            (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id = 1),
            now()
     FROM blueraven.deal where deal.customer_id IS NOT NULL);  -- TODO remove where clause; we want all deals migrated
-- ask Judson how to resolve these deals
-- select * from blueraven.deal where customer_id is null;


-- change the flow.project id sequence so the imported ids don't cause problems
SELECT setval('flow.project_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM flow.project), 1), false);

-- migrate closer and setter to flow.uesr_project
INSERT INTO flow.user_project (project_id, user_position_id, created_by_id, date_created)
    (SELECT *
     FROM
         (SELECT d.id AS project_id,
                 (select up.id
                  from blueraven.user_position up
                  where user_id = d.closer_user_id
                    and position_id = 1
                    and up.start_date <= up.end_date
                    and tsrange(up.start_date, up.end_date) @> d.pre_design_complete_date
                  limit 1) AS user_position_id,
                 2350555 AS created_by_id,
                 now() AS date_created
          FROM blueraven.deal d
                   INNER JOIN flow.project p ON p.id = d.id -- TODO remove this when WHERE clause is removed from flow.project migration
          WHERE d.closer_user_id IS NOT NULL) AS foo
     WHERE foo.user_position_id IS NOT NULL);

INSERT INTO flow.user_project (project_id, user_position_id, created_by_id, date_created)
    (SELECT *
     FROM
         (SELECT d.id AS project_id,
                 (select up.id
                  from blueraven.user_position up
                  where user_id = d.setter_user_id
                    and position_id = 4
                    and tsrange(least(up.start_date, up.end_date),
                                greatest(up.start_date, up.end_date)) @> d.pre_design_complete_date
                  limit 1) AS user_position_id,
                 2350555 AS created_by_id,
                 now() AS date_created
          FROM blueraven.deal d
                   INNER JOIN flow.project p
                              ON p.id = d.id -- TODO remove this when WHERE clause is removed from flow.project migration
          WHERE d.setter_user_id IS NOT NULL) AS foo
     WHERE foo.user_position_id IS NOT NULL);

--------------------------------------------------------------------------------
-- create Complete Final Design process step
--------------------------------------------------------------------------------
-- create the step
/*INSERT INTO flow.process_step (process_step_name, company_id, created_by_id)
VALUES ('Complete Final Design', 1, 2350555);

update flow.custom_field_group
set process_step_id = (select id from flow.process_step where process_step_name = 'Complete Final Design')
where group_name =  'Process Step PlaceHolder';

-- associate it with Generic Blueraven Process
INSERT INTO flow.process_step_process (process_id, process_step_id, org_id, created_by_id, display_order, initial_step)
VALUES ((select id from flow.process where process_name = 'Generic Blueraven Process'),
        (select id from flow.process_step where process_step_name = 'Complete Final Design'),
        (select id from flow.org where org_name = 'Corporate - Blue Raven Solar'),
        2350555,
        0,
        true);
*/
-- create and migrate the necessary project custom fields
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id)
VALUES ('Cancelled Date',
        1,
        now(),
        2350555,
        1);

INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id)
VALUES ('On Hold',
        3,
        now(),
        2350555,
        1);

INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Project PlaceHolder'),
            (select id from flow.custom_field where field_name = 'Cancelled Date'),1,false, 2350555);

INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
    (select (select id from flow.custom_field_group where group_name = 'Project PlaceHolder'),
            (select id from flow.custom_field where field_name = 'On Hold'),1,false, 2350555);

insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,1
     from flow.custom_field cf
     where cf.field_name = 'Cancelled Date'
    );
insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,1
     from flow.custom_field cf
     where cf.field_name = 'On Hold'
    );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Date') as custom_field_id,
            cancelled_date,
            2350555 as created_by_id
     FROM blueraven.deal WHERE cancelled_date IS NOT NULL);

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, boolean_value, created_by_id)
    (SELECT id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'On Hold') as custom_field_id,
            on_hold,
            2350555 as created_by_id
     FROM blueraven.deal WHERE on_hold IS NOT NULL);
/*
-- create dummy process step status
INSERT INTO flow.process_step_status_type (process_step_status_type,company_id)
VALUES ('In Progress',1);  -- TODO make this company-specific, so companies can define their own statuses?

-- create project process step entries
INSERT INTO flow.project_process_step (project_id, process_step_id, user_position_id, process_step_status_type_id, created_by_id)
    (SELECT project.id,
            (SELECT id FROM flow.process_step WHERE process_step_name = 'Complete Final Design') AS process_step_id,
            7514 AS user_position_id, -- arbitrary user position id; I have no idea what to use here
            -- TODO how will these projects be assigned to individuals? Should this be optional?
            (SELECT id FROM flow.process_step_status_type WHERE process_step_status_type = 'In Progress') AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id -- filter down to deals that were previously migrated to flow.project
         -- TODO this will be deleted once I remove the WHERE clause on the project migration statement
              INNER JOIN blueraven.deal_work_queue dwq
                         ON project.id = dwq.deal_id -- filter down to deals that are currently in Complete Final Design
                             AND dwq.work_queue_deal_ids && '{5}');

-- create and migrate the necessary step custom fields
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id)
VALUES ('Site Survey Verified Date',
        3,
        now(),
        2350555,
        1);

INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id)
VALUES ('Final Design QA Date',
        3,
        now(),
        2350555,
        1);

INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
VALUES (9,80,1,false, 2350555);

INSERT INTO flow.custom_field_group_assignment(
    custom_field_group_id,
    custom_field_id,field_order,archived,created_by_id)
VALUES (9,81,2,false, 2350555);

insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
    (select id,1
     from flow.custom_field
     where id > 79
    );

INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id, custom_field_group_assignment_id, timestamp_value, created_by_id)
    (SELECT pps.id AS project_process_step_id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Site Survey Verified Date') AS custom_field_id,
            d.site_survey_verified_date AS timestamp_value,
            2350555 as created_by_id
     FROM flow.project p
              INNER JOIN blueraven.deal d
                         ON p.id = d.id                       -- filter down to deals that were previously migrated to flow.project
         -- TODO delete this once I remove the WHERE clause on the project migration
              LEFT JOIN flow.project_process_step pps
                        ON pps.project_id = d.id             -- traverse relationship to access project_process_step.id
              INNER JOIN blueraven.deal_work_queue dwq
                         ON p.id = dwq.deal_id                -- filter down to deals that are currently in Complete Final Design
                             AND dwq.work_queue_deal_ids && '{5}'
     WHERE d.site_survey_verified_date IS NOT NULL);

INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id, custom_field_group_assignment_id, timestamp_value, created_by_id)
    (SELECT pps.id AS project_process_step_id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Final Design QA Date') AS custom_field_id,
            d.final_design_qa_date AS timestamp_value,
            2350555 as created_by_id
     FROM flow.project p
              INNER JOIN blueraven.deal d
                         ON p.id = d.id                       -- filter down to deals that were previously migrated to flow.project
         -- TODO delete this once I remove the WHERE clause on the project migration
              LEFT JOIN flow.project_process_step pps
                        ON pps.project_id = d.id             -- traverse relationship to access project_process_step.id
              INNER JOIN blueraven.deal_work_queue dwq
                         ON p.id = dwq.deal_id                -- filter down to deals that are currently in Complete Final Design
                             AND dwq.work_queue_deal_ids && '{5}'
     WHERE d.final_design_qa_date IS NOT NULL);

*/
insert into brs.ahj_checklist_type(id, name, archived)
    (select id,
            name,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END
     from blueraven.ahj_checklist_type);

SELECT setval('brs.ahj_checklist_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_checklist_type), 1), false);


insert into brs.ahj_checklist(id, description, display_order, archived, date_created, created_by_id, date_modified, modified_by_id, checklist_type_id, failed_inspection_resource_id, failed_inspection_date, failed_inspection_project)
    (select id, description, display_order, archived, created, created_by_id, updated, updated_by_id, checklist_type_id, failed_inspection_resource_id, failed_inspection_date, failed_inspection_project
     from blueraven.ahj_checklist);

SELECT setval('brs.ahj_checklist_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_checklist), 1), false);


insert into brs.ahj_contact_type(id, type)
    (select id, type
     from blueraven.ahj_contact_type);

SELECT setval('brs.ahj_contact_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_contact_type), 1), false);


insert into brs.ahj_contact(id, name, title, email, phone_number, address, notes, hours, archived, date_created, created_by_id, date_modified, modified_by_id, contact_type_id)
    (select id, name, title, email, phone_number, address, notes, hours, archived, created, created_by_id, updated, updated_by_id, contact_type_id
     from blueraven.ahj_contact);

SELECT setval('brs.ahj_contact_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_contact), 1), false);


insert into brs.ahj_link_type(id, name, archived)
    (select id,
            name,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END
     from blueraven.ahj_link_type);

SELECT setval('brs.ahj_link_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_link_type), 1), false);



insert into brs.ahj_inspection(id, ahj_id, inspection_fee, re_inspection_fee, payment_method, inspection_time_window, brs_inspection_rep, portal_url, portal_username, portal_password, obtaining_results_method, approval_document_method, obtaining_results_portal_url, obtaining_results_portal_username, obtaining_results_portal_password, business_license, contractor_license, archived, date_created, created_by_id, date_modified, modified_by_id, call_for_time_window, ladder_required, time_window, time_window_call_time, time_window_phone, scheduling_note, technician_instruction_note, scheduling_with_customer_note, obtaining_results_note, reinspection_note, documentation_note, required_inspection_types, fall_protection_required, mpu_inspection_note)
    (select id, ahj_id, inspection_fee, re_inspection_fee, payment_method, inspection_time_window, brs_inspection_rep, portal_url, portal_username, portal_password, obtaining_results_method, approval_document_method, obtaining_results_portal_url, obtaining_results_portal_username, obtaining_results_portal_password, business_license, contractor_license, archived, created, created_by_id, updated, updated_by_id, call_for_time_window, ladder_required, time_window, time_window_call_time, time_window_phone, scheduling_note, technician_instruction_note, scheduling_with_customer_note, obtaining_results_note, reinspection_note, documentation_note, required_inspection_types, fall_protection_required, mpu_inspection_note
     from blueraven.ahj_inspection);

SELECT setval('brs.ahj_inspection_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_inspection), 1), false);


insert into brs.ahj_inspection_link(id, ahj_inspection_id, name, link, username, password, notes, archived, date_created, created_by_id, date_modified, modified_by_id, link_type_id)
    (select id, ahj_inspection_id, name, link, username, password, notes, archived, created, created_by_id, updated, updated_by_id, link_type_id
     from blueraven.ahj_inspection_link);

SELECT setval('brs.ahj_inspection_link_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_inspection_link), 1), false);


insert into brs.ahj_permit(id, ahj_id, deposit_amount, average_permit_fee, engineering_letter_required, print_location, stamped_plan, archived, date_created, created_by_id, date_modified, modified_by_id, business_license_expiration_date, contractor_license_expiration_date, business_license, contractor_license, submission_note, revision_note, as_built_note, delivery_note, revision_fee_amount, as_built_fee_amount, follow_up_fee_amount, delivery_fee_amount, approval_timeline, documents_available, other_license, other_license_expiration_date)
    (select id, ahj_id, deposit_amount, average_permit_fee, engineering_letter_required, print_location, stamped_plan, archived, created, created_by_id, updated, updated_by_id, business_license_expiration_date, contractor_license_expiration_date, business_license, contractor_license, submission_note, revision_note, as_built_note, delivery_note, revision_fee_amount, as_built_fee_amount, follow_up_fee_amount, delivery_fee_amount, approval_timeline, documents_available, other_license, other_license_expiration_date
     from blueraven.ahj_permit);

SELECT setval('brs.ahj_permit_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_permit), 1), false);


insert into brs.ahj_permit_link(id, ahj_permit_id, name, link, username, password, notes, archived, date_created, created_by_id, date_modified, modified_by_id, link_type_id)
    (select id, ahj_permit_id, name, link, username, password, notes, archived, created, created_by_id, updated, updated_by_id, link_type_id
     from blueraven.ahj_permit_link);

SELECT setval('brs.ahj_permit_link_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_permit_link), 1), false);


insert into brs.ahj_utility_link(id, ahj_utility_id, name, link, username, password, notes, link_type_id, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select id, ahj_utility_id, name, link, username, password, notes, link_type_id, archived, created, created_by_id, updated, updated_by_id
     from blueraven.ahj_utility_link);

SELECT setval('brs.ahj_utility_link_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_utility_link), 1), false);


insert into brs.ahj_note_type(id, type)
    (select id, type
     from blueraven.ahj_note_type);

SELECT setval('brs.ahj_note_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_note_type), 1), false);


insert into brs.ahj_note(id, note, archived, date_created, created_by_id, date_modified, modified_by_id, note_type_id)
    (select id, note, archived, created, created_by_id, updated, updated_by_id, note_type_id
     from blueraven.ahj_note);

SELECT setval('brs.ahj_note_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_note), 1), false);


insert into brs.ahj_utility_contact          SELECT * FROM blueraven.ahj_utility_contact;


insert into brs.ahj_utility_checklist        SELECT * FROM blueraven.ahj_utility_checklist;


insert into brs.ahj_requirement_type(id, name, archived, date_created, date_modified)
    (select id,
            name,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            date_created,
            date_updated
     from blueraven.ahj_requirement_type);

SELECT setval('brs.ahj_requirement_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_requirement_type), 1), false);


insert into brs.ahj_requirement(id, requirement_type_id, description, date_created, created_by_id, date_modified, modified_by_id)
    (select id, requirement_type_id, description, date_created, created_by_id, date_updated, updated_by_id
     from blueraven.ahj_requirement);

SELECT setval('brs.ahj_requirement_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_requirement), 1), false);


insert into brs.ahj_requirement_status(id, name, display_order)
    (select id, name, display_order
     from blueraven.ahj_requirement_status);

SELECT setval('brs.ahj_requirement_status_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_requirement_status), 1), false);


insert into brs.ahj_utility_requirements(utility_id, requirement_id, position, original_requirement_id, status_id, complete, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select utility_id, requirement_id, position, original_requirement_id, status_id, complete, CASE WHEN archived IS NULL THEN FALSE ELSE 1=1 END, date_created, created_by_id, date_updated, updated_by_id
     from blueraven.ahj_utility_requirements);


insert into brs.ahj_permit_contact           SELECT * FROM blueraven.ahj_permit_contact;


insert into brs.ahj_permit_note              SELECT * FROM blueraven.ahj_permit_note;


insert into brs.ahj_permit_checklist         SELECT * FROM blueraven.ahj_permit_checklist;


insert into brs.ahj_design(id, ahj_id, codes, archived, date_created, created_by_id, date_modified, modified_by_id, utility_id, note, reference_standards, ground_snow_load, wind_speed, roof_snow_load)
    (select id, ahj_id, codes, archived, created, created_by_id, updated, updated_by_id, utility_id, note, reference_standards, ground_snow_load, wind_speed, roof_snow_load
     from blueraven.ahj_design);

SELECT setval('brs.ahj_design_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_design), 1), false);


insert into brs.ahj_design_contact           SELECT * FROM blueraven.ahj_design_contact;


insert into brs.ahj_design_note              SELECT * FROM blueraven.ahj_design_note;


insert into brs.ahj_base_note_template(id, title, note, archived)
    (select id, title, note, archived
     from blueraven.ahj_base_note_template);

SELECT setval('brs.ahj_base_note_template_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_base_note_template), 1), false);


insert into brs.ahj_inspection_base_note     SELECT * FROM blueraven.ahj_inspection_base_note;


insert into brs.ahj_inspection_checklist     SELECT * FROM blueraven.ahj_inspection_checklist;


insert into brs.ahj_inspection_contact       SELECT * FROM blueraven.ahj_inspection_contact;


insert into brs.ahj_inspection_note          SELECT * FROM blueraven.ahj_inspection_note;


insert into brs.ahj_requirements(ahj_id, requirement_id, original_requirement_id, status_id, position, complete, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select ahj_id, requirement_id, original_requirement_id, status_id, position, complete, CASE WHEN archived IS NULL THEN FALSE ELSE 1=1 END, date_created, created_by_id, date_updated, updated_by_id
     from blueraven.ahj_requirements);


insert into flow.system_value(system_value)values('Current User ID');
insert into flow.system_value(system_value)values('Current Project ID');


insert into flow.db_function(function_name,return_data_type_id)
values('flow.set_error_version_control',3);

insert into flow.db_function_param(db_function_id,parameter_name,display_order,data_type_id,parameter_type_id)
values(1,'Default Version Control',1,6,3);
insert into flow.db_function_param(db_function_id,parameter_name,display_order,data_type_id,parameter_type_id)
values(1,'Log Type',2,6,3);
insert into flow.db_function_param(db_function_id,parameter_name,display_order,data_type_id,parameter_type_id)
values(1,'Project ID',3,6,1);
insert into flow.db_function_param(db_function_id,parameter_name,display_order,data_type_id,parameter_type_id)
values(1,'Document Package Type',4,6,2);


insert into flow.company_function(company_function_name,db_function_id,company_id)values('Get Version Control',1,1);

insert into flow.custom_field(company_id, field_name, company_data_type_id, created_by_id, custom_field_sql_key_id)
values(1, 'AHJ', 9, 2350555, 1);

with parent as (
    insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                    created_by_id, archived)
        values('Proposal Status',null,1,now(),2350555,false)
        returning id ),
     t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                           created_by_id, archived)
         (select c.proposal_status,(select p.id from parent p),1,now(),2350555,false
          from blueraven.customer c
          where c.proposal_status is not null
          group by c.proposal_status))
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
    (select 'Proposal Status',
            7,
            now(),
            2350555,
            1,
            p.id
     from parent p
    );


with parent as (
    insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                    created_by_id, archived)
        values('Setter Appointment Outcome',null,1,now(),2350555,false)
        returning id ),
     t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                           created_by_id, archived)
         (select c.setter_appointment_outcome,(select p.id from parent p),1,now(),2350555,false
          from blueraven.customer c
          where c.setter_appointment_outcome is not null
          group by c.setter_appointment_outcome))
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
    (select 'Setter Appointment Outcome',
            7,
            now(),
            2350555,
            1,
            p.id
     from parent p
    );


with parent as (
    insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                    created_by_id, archived)
        values('Pre Design Status',null,1,now(),2350555,false)
        returning id ),
     t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                           created_by_id, archived)
         (select c.pre_design_status,(select p.id from parent p),1,now(),2350555,false
          from blueraven.customer c
          where c.pre_design_status is not null
          group by c.pre_design_status))
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
    (select 'Pre Design Status',
            7,
            now(),
            2350555,
            1,
            p.id
     from parent p
    );


with parent as (
    insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                    created_by_id, archived)
        values('Deal Stage',null,1,now(),2350555,false)
        returning id ),
     t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
                                           created_by_id, archived)
         (select c.deal_stage,(select p.id from parent p),1,now(),2350555,false
          from blueraven.customer c
          where c.deal_stage is not null
          group by c.deal_stage))
INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
    (select 'Deal Stage',
            7,
            now(),
            2350555,
            1,
            p.id
     from parent p
    );

