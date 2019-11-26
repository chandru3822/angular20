-- drop all the tables created in this script so all the updates go thru correctly
drop table if exists brs.custom_field_value;
drop table if exists brs.custom_field_group_assignment;
drop table if exists brs.custom_field_group;
drop table if exists brs.object_type;
drop table if exists brs.custom_field;
drop table if exists brs.list_of_value;
drop table if exists brs.data_type;



-- removed crappy type migrations from migrate_brs_data.sql
-- drop all of the brs crappy type columns
-- ahj_permit (4)
alter table brs.ahj_permit drop column if exists as_built_payment_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists as_built_payment_type_other;
alter table brs.ahj_permit drop column if exists as_built_submittal_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists as_built_submittal_type_other;
alter table brs.ahj_permit drop column if exists delivery_payment_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists delivery_payment_type_other;
alter table brs.ahj_permit drop column if exists delivery_pickup_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists delivery_pickup_type_other;
alter table brs.ahj_permit drop column if exists follow_up_payment_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists follow_up_payment_type_other;
alter table brs.ahj_permit drop column if exists hoa_approval_required_type_id; --ahj_simple_list_type
alter table brs.ahj_permit drop column if exists hoa_approval_required_type_other;
alter table brs.ahj_permit drop column if exists nem_approval_required_type_id; --ahj_simple_list_type
alter table brs.ahj_permit drop column if exists nem_approval_required_type_other;
alter table brs.ahj_permit drop column if exists revision_payment_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists revision_payment_type_other;
alter table brs.ahj_permit drop column if exists revision_submittal_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists revision_submittal_type_other;
alter table brs.ahj_permit drop column if exists submission_payment_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists submission_payment_type_other;
alter table brs.ahj_permit drop column if exists submittal_type_id; --ahj_submit_type
alter table brs.ahj_permit drop column if exists submittal_type_other;

-- ahj_utility (2)
alter table brs.ahj_utility drop column if exists rebate_program_type_id; -- ahj_simple_list_type
alter table brs.ahj_utility drop column if exists rebate_program_type_other;
alter table brs.ahj_utility drop column if exists signature_required_prior_type_id; -- ahj_simple_list_type
alter table brs.ahj_utility drop column if exists signature_required_prior_type_other;
alter table brs.ahj_utility drop column if exists signature_requested_at_type_id; -- ahj_signature_requested_at_type
alter table brs.ahj_utility drop column if exists signature_requested_at_type_other;
alter table brs.ahj_utility drop column if exists customer_signature_resubmission_type_id; -- ahj_simple_list_type
alter table brs.ahj_utility drop column if exists customer_signature_resubmission_type_other;
alter table brs.ahj_utility drop column if exists when_to_create_application_type_id; -- ahj_when_to_create_application_type
alter table brs.ahj_utility drop column if exists when_to_create_application_type_other;
alter table brs.ahj_utility drop column if exists submission_method_type_id; -- ahj_utility_submission_type
alter table brs.ahj_utility drop column if exists submission_method_type_other;
alter table brs.ahj_utility drop column if exists interconnection_fee_type_id; -- ahj_simple_list_type
alter table brs.ahj_utility drop column if exists interconnection_fee_type_other;
alter table brs.ahj_utility drop column if exists utility_method_type_id; -- ahj_utility_method_type
alter table brs.ahj_utility drop column if exists utility_method_type_other;
alter table brs.ahj_utility drop column if exists inspection_submission_type_id; -- ahj_utility_inspection_submission_type
alter table brs.ahj_utility drop column if exists inspection_submission_type_other;
alter table brs.ahj_utility drop column if exists utility_inspection_required_type_id; -- ahj_simple_list_type
alter table brs.ahj_utility drop column if exists utility_inspection_required_type_other;
alter table brs.ahj_utility drop column if exists followup_method_type_id; -- ahj_pto_followup_type
alter table brs.ahj_utility drop column if exists followup_method_type_other;
alter table brs.ahj_utility drop column if exists ac_disconnect_required; -- custom_dropdown_field ? field or value?
alter table brs.ahj_utility drop column if exists meter_can_taps_allowed; -- custom_dropdown_field ? field or value?
alter table brs.ahj_utility drop column if exists pv_production_meter_required; -- custom_dropdown_field ? field or value?
alter table brs.ahj_utility drop column if exists pv_ac_swap_locations; -- custom_dropdown_field ? field or value?
alter table brs.ahj_utility drop column if exists utility_warning_labels_override; -- custom_dropdown_field ? field or value?

-- ahj_design (1)
alter table brs.ahj_design drop column if exists electrical_code_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists building_code_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists electrical_engineer_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists structural_engineer_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists standard_racking_equipment_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists railless_landscape_attachment_spacing_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists fire_setbacks_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists railless_portrait_attachment_spacing_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists standard_conduit_run_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists warning_labels_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists supplemental_ground_rod_required_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists load_standard_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists wood_standard_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists ult_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists seismic_design_category_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists roof_snow_load_ahj_override_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists snow_load_reduction_allowed_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists wind_exposure_factor_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists wind_exposure_factor_ahj_override_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists risk_category_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists stamp_type_id; -- custom_dropdown_value
alter table brs.ahj_design drop column if exists structural_post_install_letter_required_id; -- custom_dropdown_value

-- ahj_inspection (3)
alter table brs.ahj_inspection drop column if exists scheduling_method_type_id; -- ahj_scheduling_method_type
alter table brs.ahj_inspection drop column if exists scheduling_method_type_other;
alter table brs.ahj_inspection drop column if exists handy_information_type_id; -- ahj_handy_information_type
alter table brs.ahj_inspection drop column if exists handy_information_type_other;
alter table brs.ahj_inspection drop column if exists scheduling_lead_time_type_id; -- ahj_scheduling_lead_time_type
alter table brs.ahj_inspection drop column if exists scheduling_lead_time_type_other;
alter table brs.ahj_inspection drop column if exists inspection_capacity_type_id; -- ahj_inspection_capacity_type
alter table brs.ahj_inspection drop column if exists inspection_capacity_type_other;
alter table brs.ahj_inspection drop column if exists site_access_type_id; -- ahj_site_access_type
alter table brs.ahj_inspection drop column if exists site_access_type_other;
alter table brs.ahj_inspection drop column if exists rough_inspection_required_type_id; -- ahj_rough_inspection_required_type
alter table brs.ahj_inspection drop column if exists rough_inspection_required_type_other;
alter table brs.ahj_inspection drop column if exists soladeck_access_type_id; -- ahj_soladeck_access_type
alter table brs.ahj_inspection drop column if exists soladeck_access_type_other;
alter table brs.ahj_inspection drop column if exists placard_required_type_id; -- ahj_placard_required_type
alter table brs.ahj_inspection drop column if exists placard_required_type_other;
alter table brs.ahj_inspection drop column if exists representative_required_onsite_type_id; -- ahj_representative_required_onsite_type
alter table brs.ahj_inspection drop column if exists representative_required_onsite_type_other;
alter table brs.ahj_inspection drop column if exists special_equipment_type_id; -- ahj_special_equipment_type
alter table brs.ahj_inspection drop column if exists special_equipment_type_other;
alter table brs.ahj_inspection drop column if exists plans_required_type_id; -- ahj_plans_required_type
alter table brs.ahj_inspection drop column if exists plans_required_type_other;
alter table brs.ahj_inspection drop column if exists special_documents_type_id; -- ahj_special_documents_type
alter table brs.ahj_inspection drop column if exists special_documents_type_other;
alter table brs.ahj_inspection drop column if exists results_documentation_type_id; -- ahj_results_documentation_type
alter table brs.ahj_inspection drop column if exists results_documentation_type_other;
alter table brs.ahj_inspection drop column if exists reinspection_fee_type_id; -- ahj_reinspection_fee_type
alter table brs.ahj_inspection drop column if exists reinspection_fee_type_other;
alter table brs.ahj_inspection drop column if exists midpoint_inspection_lead_time_type_id;  -- todo this column is not being used. @judson what should the values be?
alter table brs.ahj_inspection drop column if exists midpoint_inspection_lead_time_type_other;
alter table brs.ahj_inspection drop column if exists homeowner_required;-- custom_dropdown_value
alter table brs.ahj_inspection drop column if exists homeowner_required_on_site;-- custom_dropdown_value
alter table brs.ahj_inspection drop column if exists call_for_time_window;-- custom_dropdown_value
alter table brs.ahj_inspection drop column if exists fall_protection_required;-- custom_dropdown_value
alter table brs.ahj_inspection drop column if exists brs_tech_required;-- custom_dropdown_value

-- drop the brs tables that shouldn't be there
drop table if exists brs.custom_dropdown_value;
drop table if exists brs.custom_dropdown_field;
drop table if exists brs.custom_dropdown_screen;

-- drop all of the brs crappy type tables
drop table if exists brs.ahj_handy_information_type;
drop table if exists brs.ahj_inspection_capacity_type;
drop table if exists brs.ahj_placard_required_type;
drop table if exists brs.ahj_plans_required_type;
drop table if exists brs.ahj_pto_followup_type;
drop table if exists brs.ahj_reinspection_fee_type;
drop table if exists brs.ahj_representative_required_onsite_type;
drop table if exists brs.ahj_results_documentation_type;
drop table if exists brs.ahj_rough_inspection_required_type;
drop table if exists brs.ahj_scheduling_lead_time_type;
drop table if exists brs.ahj_scheduling_method_type;
drop table if exists brs.ahj_signature_requested_at_type;
drop table if exists brs.ahj_site_access_type;
drop table if exists brs.ahj_soladeck_access_type;
drop table if exists brs.ahj_special_documents_type;
drop table if exists brs.ahj_special_equipment_type;
drop table if exists brs.ahj_utility_inspection_submission_type;
drop table if exists brs.ahj_utility_method_type;
drop table if exists brs.ahj_utility_submission_type;
drop table if exists brs.ahj_when_to_create_application_type;
drop table if exists brs.ahj_submit_type;
drop table if exists brs.ahj_simple_list_type;

CREATE TABLE if NOT EXISTS brs.data_type
(
    id        serial                NOT NULL,
    data_type character varying(50) NOT NULL,
    has_list_values boolean not null default false,
    allow_multiple boolean not null default false,
    archived boolean not null default false,
    CONSTRAINT brs_company_data_type_pk PRIMARY KEY (id)
);

CREATE TABLE if not exists brs.list_of_value
(
    id             serial       NOT NULL,
    name           varchar(100) not null,
    code           varchar(50),
    parent_id      integer,
    display_order  integer,
    show_other    boolean not null default false,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id  integer      not null,
    modified_by_id integer,
    archived       boolean   not null   default false,
    CONSTRAINT brs_list_of_value_pk PRIMARY KEY (id),
    CONSTRAINT brs_lov_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_lov_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.custom_field
(
    id                   serial       NOT NULL,
    list_of_value_id     integer,
    field_name           varchar(100) not null,
    field_code           varchar(100),
    data_type_id         integer      NOT NULL,
    date_created         timestamp without time zone DEFAULT now(),
    date_modified         timestamp without time zone,
    created_by_id        integer      not null,
    modified_by_id       integer,
    archived             boolean default false not null,
    CONSTRAINT brs_custom_field_pk PRIMARY KEY (id),
    CONSTRAINT brs_cf_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_cf_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_cf_list_of_value_id_fk FOREIGN KEY (list_of_value_id)
        REFERENCES brs.list_of_value (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_cf_data_type_id_fk FOREIGN KEY (data_type_id)
        REFERENCES brs.data_type (id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if NOT EXISTS brs.object_type
(
    id          serial                NOT NULL,
    object_type character varying(50) NOT NULL,
    object_code character varying(50) NOT NULL,
    archived boolean not null default false,
    CONSTRAINT brs_object_type_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS brs.custom_field_group
(
    id          serial,
    group_name character VARYING(100) not null,
    object_type_id integer not null,
    group_order integer,
    archived boolean not null default false,
    CONSTRAINT brs_custom_field_group_pk PRIMARY KEY (id),
    CONSTRAINT brs_cfgt_object_type_id_fk FOREIGN KEY (object_type_id)
        REFERENCES brs.object_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if NOT EXISTS brs.custom_field_group_assignment
(
    id        serial                NOT NULL,
    custom_field_group_id integer not null,
    custom_field_id            integer,
    field_order                integer not null,
    archived                   boolean not null default false,
    date_created         timestamp without time zone DEFAULT now(),
    date_modified         timestamp without time zone,
    created_by_id        integer      not null,
    modified_by_id       integer,
    CONSTRAINT brs_custom_field_group_assignment_pk PRIMARY KEY (id),
    CONSTRAINT brs_cfga_custom_field_group_id_fk FOREIGN KEY (custom_field_group_id)
        REFERENCES brs.custom_field_group (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_cfga_custom_field_id_fk FOREIGN KEY (custom_field_id)
        REFERENCES brs.custom_field (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_cfga_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_cfga_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.custom_field_value
(
    id              serial  not null,
    source_id       integer not null,
    date_value      date,
    custom_field_group_assignment_id integer not null,
    timestamp_value timestamp,
    boolean_value   boolean,
    text_value      text,
    numeric_value   numeric,
    int_value       integer,
    int_array_value integer[],
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    CONSTRAINT brs_customer_custom_field_value_pk PRIMARY KEY (id),
    CONSTRAINT brs_ccfv_custom_field_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES brs.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_ccfv_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_ccfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
