-- drop table if exists brs.RESIDENTIAL_PROJECT_C;
-- create table if not exists brs.RESIDENTIAL_PROJECT_C
-- (
--   ID                                          VARCHAR(18),
--   OWNER_ID                                    VARCHAR(18),
--   IS_DELETED                                  BOOLEAN,
--   NAME                                        VARCHAR(240),
--   CURRENCY_ISO_CODE                           VARCHAR(9),
--   RECORD_TYPE_ID                              VARCHAR(18),
--   CREATED_DATE                                TIMESTAMPTZ,
--   CREATED_BY_ID                               VARCHAR(18),
--   LAST_MODIFIED_DATE                          TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                         VARCHAR(18),
--   SYSTEM_MODSTAMP                             TIMESTAMPTZ,
--   LAST_ACTIVITY_DATE                          DATE,
--   LAST_VIEWED_DATE                            TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                        TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID                      VARCHAR(18),
--   CONNECTION_SENT_ID                          VARCHAR(18),
--   ACCOUNT_C                                   VARCHAR(18),
--   AHJ_SPECIFIC_EQUIPMENT_C                    VARCHAR(765),
--   AHJ_C                                       VARCHAR(765),
--   BATTERY_STORAGE_SYSTEM_DETAILS_C            VARCHAR(98304),
--   BATTERY_STORAGE_C                           VARCHAR(765),
--   CAN_SOLAR_BREAKER_BE_INSTALLED_IN_MSP_C     VARCHAR(765),
--   CANCELLATION_JUSTIFICATION_C                VARCHAR(765),
--   CONSUMPTION_MONITORING_COMPATIBLE_C         VARCHAR(765),
--   HOA_CONTACT_NUMBER_C                        VARCHAR(120),
--   HOA_NAME_C                                  VARCHAR(765),
--   HOLD_JUSTIFICATION_C                        VARCHAR(765),
--   DESIGN_REQUIRED_C                           DATE,
--   HOMEOWNER_UTILITY_ACCOUNT_NO_C              VARCHAR(765),
--   HOMEOWNER_UTILITY_METER_NO_C                VARCHAR(765),
--   INSTALLATION_TYPE_C                         VARCHAR(765),
--   MAIN_BREAKER_LOCATION_C                     VARCHAR(765),
--   MAIN_BREAKER_RATING_AMPS_C                  VARCHAR(765),
--   MAIN_SERVICE_PANEL_LOCATION_C               VARCHAR(765),
--   MAIN_SERVICE_PANEL_MANUFACTURER_C           VARCHAR(765),
--   MULTI_LEVEL_HOME_C                          VARCHAR(765),
--   OPPORTUNITY_C                               VARCHAR(18),
--   OTHER_MAIN_BREAKER_LOCATION_C               VARCHAR(765),
--   OTHER_MAIN_SERVICE_PANEL_LOCATION_C         VARCHAR(765),
--   OTHER_MAIN_SERVICE_PANEL_MANUFACTURER_C     VARCHAR(765),
--   PERMITTING_AUTHORITY_C                      VARCHAR(765),
--   PRIMARY_CONTACT_C                           VARCHAR(18),
--   PRIORITY_C                                  VARCHAR(765),
--   PROJECT_NUMBER_C                            VARCHAR(90),
--   QUOTE_C                                     VARCHAR(18),
--   SALES_ORDER_NUMBER_C                        VARCHAR(765),
--   CURRENT_RATE_PLAN_C                         VARCHAR(765),
--   SECONDARY_CONTACT_C                         VARCHAR(18),
--   SMART_THERMOSTAT_C                          VARCHAR(765),
--   STATUS_C                                    VARCHAR(765),
--   THERMOSTAT_MANUFACTURER_C                   VARCHAR(765),
--   THERMOSTAT_MODEL_C                          VARCHAR(765),
--   YARD_SIGN_APPROVED_C                        BOOLEAN,
--   HOA_C                                       VARCHAR(765),
--   INSTALLATION_PARTNER_C                      VARCHAR(18),
--   OPPORTUNITY_OWNER_EMAIL_C                   VARCHAR(240),
--   PROJECT_TEMPLATE_C                          VARCHAR(18),
--   ROOF_AGE_C                                  VARCHAR(765),
--   SCHEDULED_SITE_SURVEY_DATE_C                TIMESTAMPTZ,
--   PROPOSED_RATE_PLAN_C                        VARCHAR(765),
--   SCHEDULED_AHJ_INSPECTION_C                  TIMESTAMPTZ,
--   FLAT_ROOF_C                                 VARCHAR(765),
--   HOME_SURVEY_C                               VARCHAR(765),
--   INSTALLATION_MODEL_C                        VARCHAR(18),
--   METER_COMBINERS_C                           VARCHAR(765),
--   WAS_HOUSE_BUILT_BEFORE_1985_C               VARCHAR(765),
--   WAS_HOUSE_BUILT_BEFORE_1987_C               VARCHAR(765),
--   ACTUAL_TIME_HOURS_C                         numeric,
--   BUILDER_WO_DATE_OF_RECEIPT_C                DATE,
--   BUILDER_WO_VALUE_C                          numeric(9, 2),
--   BUILDER_WO_C                                VARCHAR(765),
--   CLOSED_WON_DATE_NH_C                        DATE,
--   COMMUNITY_C                                 VARCHAR(18),
--   CUSTOMER_STATE_TEXT_C                       VARCHAR(765),
--   CUSTOMER_STREET_TEXT_C                      VARCHAR(765),
--   CUSTOMER_ZIP_TEXT_C                         VARCHAR(765),
--   ESCROW_DATE_C                               DATE,
--   HERS_C                                      VARCHAR(765),
--   INSPECTION_PRICE_C                          numeric(18, 2),
--   INVERTER_MODEL_C                            VARCHAR(765),
--   INVERTER_QUANTITY_C                         numeric,
--   LOT_NUMBER_C                                VARCHAR(765),
--   MATERIAL_SHIPPED_DATE_C                     DATE,
--   MONITORING_C                                VARCHAR(765),
--   MOUNTING_TYPE_C                             VARCHAR(765),
--   NUMBER_OF_PANELS_C                          numeric,
--   PDF_COPY_ONLY_C                             VARCHAR(765),
--   PV_ID_C                                     VARCHAR(765),
--   PV_INSTALL_PROMISED_C                       DATE,
--   PV_MODULE_MODEL_C                           VARCHAR(765),
--   PLAN_TYPE_C                                 VARCHAR(18),
--   PROPOSED_SOLAR_BREAKER_INSTALLED_IN_MSP_C   VARCHAR(765),
--   PURCHASE_ORDER_NUMBER_C                     VARCHAR(765),
--   REBATE_CLAIM_NOTES_C                        VARCHAR(765),
--   REBATE_RESERVATION_CONFIRMATION_LOT_C       VARCHAR(765),
--   REBATE_RESERVATION_EXPIRY_DATE_LOT_C        DATE,
--   SDGE_UTILITY_APPLICATION_ID_C               VARCHAR(765),
--   ROOF_1_PITCH_C                              VARCHAR(765),
--   ROOF_1_SYSTEM_ORIENTATION_C                 numeric,
--   ROOF_2_PITCH_C                              VARCHAR(765),
--   ROOF_2_SYSTEM_ORIENTATION_C                 numeric,
--   ROOF_3_PITCH_C                              VARCHAR(765),
--   ROOF_3_SYSTEM_ORIENTATION_C                 numeric,
--   ROOF_4_PITCH_C                              VARCHAR(765),
--   ROOF_4_SYSTEM_ORIENTATION_C                 numeric,
--   ROOF_TYPE_C                                 VARCHAR(765),
--   ROUGH_LABOR_PRICING_C                       numeric(18, 2),
--   ROUGH_WIRE_PROMISED_C                       DATE,
--   ROUGH_WIRE_WO_DATE_RECEIPT_C                DATE,
--   ROUGH_WIRE_WO_VALUE_C                       numeric(9, 2),
--   ROUGH_WIRE_WO_C                             VARCHAR(765),
--   SOLAR_REBATE_ACTUAL_C                       numeric(12, 2),
--   SOLAR_REBATE_EXPECTED_C                     numeric(12, 2),
--   SUN_POWER_DEAL_TYPE_C                       VARCHAR(765),
--   SYSTEM_ADDERS_C                             VARCHAR(4099),
--   SYSTEM_WATTAGE_AC_C                         numeric,
--   SYSTEM_WATTAGE_DC_C                         numeric,
--   TRACKING_NUMBER_C                           VARCHAR(765),
--   TRIM_LABOR_PRICING_C                        numeric(18, 2),
--   TRIM_PROMISED_C                             DATE,
--   TYPE_OF_DESIGN_C                            VARCHAR(765),
--   EV_CHARGER_AVAILABLE_C                      VARCHAR(765),
--   MATERIALS_SHIP_TO_LOCATION_C                VARCHAR(765),
--   PTA_BLDG_INSPECTION_DATE_C                  DATE,
--   PHASE_C                                     VARCHAR(300),
--   PROJECT_CLOSE_DATE_C                        TIMESTAMPTZ,
--   REQUESTED_DELIVERY_DATE_C                   DATE,
--   WITNESS_TEST_DATE_C                         DATE,
--   ORACLE_ORDER_HEADER_ID_C                    VARCHAR(114),
--   ADDERS_VALUE_C                              numeric(18, 2),
--   ADDITIONAL_BUILDER_SERVICES_WO_C            VARCHAR(765),
--   ADDITIONAL_BUILDER_SERVICES_WO_VALUE_C      numeric(18, 2),
--   ADDTL_BUILDER_SERVICES_WODATEOF_RECEIPT_C   DATE,
--   PREVIOUS_PERMIT_ETA_C                       DATE,
--   INVERTER_CONFIGURATION_C                    VARCHAR(18),
--   MODULE_CONFIGURATION_C                      VARCHAR(18),
--   MONITORING_INCLUDED_C                       VARCHAR(765),
--   PERMIT_COST_ACTUAL_C                        numeric(18, 2),
--   PURCHASE_ORDER_C                            VARCHAR(18),
--   ROOF_ATTACHMENT_C                           VARCHAR(765),
--   STORAGE_CONFIGURATION_C                     VARCHAR(18),
--   TOTAL_SOVALUE_C                             numeric(18, 2),
--   SHEET_SIZE_PROJ_C                           VARCHAR(765),
--   TOTAL_NUMBER_OF_SETS_PROJ_C                 numeric,
--   MATERIAL_DELIVERY_DATE_C                    DATE,
--   SCHEDULED_ARRIVAL_DATE_C                    DATE,
--   CF_2_R_C                                    DATE,
--   DESIGN_NOTES_C                              VARCHAR(765),
--   ENERGY_EFFICIENCY_CODE_C                    VARCHAR(300),
--   EST_ESCROW_DATE_C                           DATE,
--   HERS_INSPECTION_NOTES_C                     VARCHAR(765),
--   INTERCONNECTION_NOTES_C                     VARCHAR(393216),
--   NUMBER_OF_SPLIT_ARRAYS_C                    VARCHAR(15),
--   PV_HERS_CERTIFICATION_TYPE_C                VARCHAR(765),
--   DRIP_FEE_C                                  numeric(18, 2),
--   DEALER_FEES_C                               numeric(18, 2),
--   IP_FEE_C                                    numeric(18, 2),
--   SPWR_RECLAIMABLE_REBATE_C                   numeric(18, 2),
--   TPS_FEE_C                                   numeric(18, 2),
--   LINES_READY_TO_SUBMIT_C                     VARCHAR(98304),
--   SALES_ORDER_COMPLETE_DATE_C                 DATE,
--   AMENDED_C                                   BOOLEAN,
--   AMENDMENT_RECONCILED_C                      BOOLEAN,
--   HISTORICAL_SALES_ORDER_NUMBER_C             VARCHAR(765),
--   REBATE_CLAIM_APPROVED_C                     DATE,
--   REBATE_CLAIM_SUBMITTED_C                    DATE,
--   HERS_CERTIFICATE_RECEIVED_C                 DATE,
--   HERS_INSPECTION_COMPLETED_C                 DATE,
--   ROOF_1_NO_OF_MODULES_C                      numeric,
--   ROOF_2_NO_OF_MODULES_C                      numeric,
--   ROOF_3_NO_OF_MODULES_C                      numeric,
--   ROOF_4_NO_OF_MODULES_C                      numeric,
--   BUILDER_INCENTIVE_VALUE_C                   numeric(18, 2),
--   CUSTOMER_CITY_TEXT_C                        VARCHAR(765),
--   MIGRATED_FROM_NA_2_C                        BOOLEAN,
--   NA_2_INVERTER_MODEL_ACTUAL_C                VARCHAR(765),
--   NA_2_MODULE_MODEL_NUMBER_C                  VARCHAR(765),
--   ROOFER_LABOR_PRICING_C                      numeric(18, 2),
--   REV_REC_LINE_C                              numeric,
--   REBATE_CLAIM_EXPIRY_DATE_C                  DATE,
--   PRE_COE_COMMISSIONING_PRICING_C             numeric(8, 2),
--   FURTHER_DISCOUNT_AMOUNT_C                   numeric(18, 2),
--   AC_PRE_PLUMB_C                              numeric(18, 2),
--   FURTHER_DISCOUNT_RATIONALE_C                VARCHAR(765),
--   WO_PRICE_C                                  numeric(9, 2),
--   WO_SYSTEM_SIZE_W_C                          numeric,
--   DEAL_TYPE_DISCREPANCY_C                     BOOLEAN,
--   FURTHER_DISCOUNT_PERCENT_C                  numeric,
--   FURTHER_DISCOUNT_STATUS_C                   VARCHAR(765),
--   HIDDEN_CALCULATED_BUILDER_WO_VALUE_C        numeric(9, 2),
--   MODEL_DISCOUNT_AMOUNT_C                     numeric(18, 2),
--   MODEL_DISCOUNT_PERCENT_C                    numeric,
--   NET_CONTRACTED_PRICE_C                      numeric(18, 2),
--   PRICE_DISCREPANCY_C                         BOOLEAN,
--   SYSTEM_SIZE_DISCREPANCY_C                   BOOLEAN,
--   WRAP_INSURANCE_AMOUNT_C                     numeric(18, 2),
--   BUILDER_INVOICE_AMOUNT_MO_HISTORY_C         BOOLEAN,
--   AC_ROUGH_WIRE_C                             numeric(18, 2),
--   AC_WIRE_INSTALLATION_AFTER_PRE_PLUMB_C      numeric(18, 2),
--   CUSTOM_ADDER_DISTANCE_C                     numeric(18, 2),
--   CUSTOM_ADDER_STEEP_ROOF_C                   numeric(18, 2),
--   MODULE_INSTALLATION_C                       numeric(18, 2),
--   PERMITTING_LABOR_ONLY_C                     numeric(18, 2),
--   X_3_STORY_ROOF_C                            numeric(18, 2),
--   SALES_ADDERS_C                              VARCHAR(3072),
--   ROOFER_PARTNER_C                            VARCHAR(18),
--   PERMIT_ETA_C                                DATE,
--   SCHEDULED_INSTALLATION_DATE_C               TIMESTAMPTZ,
--   PERMIT_AHJ_FEES_C                           numeric(18, 2),
--   PERMIT_EXECUTION_FEES_C                     numeric(18, 2),
--   READY_FOR_INSTALL_C                         DATE,
--   READY_FOR_ROUGH_WIRE_C                      DATE,
--   UTILITY_APPLICATION_ID_C                    numeric,
--   READY_FOR_INSTALL_CHECKBOX_C                BOOLEAN,
--   READY_FOR_ROUGH_WIRE_CHECKBOX_C             BOOLEAN,
--   TRENCH_DATE_PROMISED_C                      DATE,
--   LENGTH_OF_INSTALLATION_C                    VARCHAR(765),
--   SERIAL_NUMBER_C                             VARCHAR(765),
--   SOLAR_ACCESS_C                              numeric,
--   TIME_ZONE_NAME_C                            VARCHAR(765),
--   REMOTE_HOME_SURVEY_STATUS_C                 VARCHAR(765),
--   NH_STORAGE_SIZE_C                           VARCHAR(765),
--   BUILDER_WO_STORAGE_PRICE_C                  numeric(18, 2),
--   STORAGE_PRICE_DISCREPANCY_C                 BOOLEAN,
--   WO_STORAGE_PRICE_C                          numeric(18, 2),
--   AHJNAME_C                                   VARCHAR(18),
--   EV_CHARGER_COMMISSION_C                     numeric(16, 2),
--   EV_CHARGER_MODEL_C                          VARCHAR(765),
--   MPU_INVOICE_APPROVED_DATE_C                 DATE,
--   MPU_INVOICE_AMOUNT_C                        numeric(18, 2),
--   MPU_NEW_BUSBAR_VALUE_C                      VARCHAR(765),
--   MPU_NEW_MAIN_BREAKER_VALUE_C                VARCHAR(765),
--   MPU_PO_NUMBER_C                             VARCHAR(765),
--   MPU_SCOPE_OF_WORK_C                         VARCHAR(765),
--   MPU_SERVICE_TYPE_C                          VARCHAR(765),
--   REROOF_INVOICE_APPROVED_DATE_C              DATE,
--   REROOF_INVOICE_AMOUNT_C                     numeric(18, 2),
--   REROOF_PO_NUMBER_C                          VARCHAR(765),
--   REROOF_PROPOSAL_TYPE_C                      VARCHAR(765),
--   REROOF_SCOPE_OF_WORK_C                      VARCHAR(765),
--   REROOF_PROPOSAL_AMOUNT_C                    numeric(18, 2),
--   SCHEDULED_MPU_DATE_C                        DATE,
--   SCHEDULED_MPU_INSPECTION_DATE_C             DATE,
--   SCHEDULED_REROOF_DATE_C                     DATE,
--   SCHEDULED_REROOF_INSPECTION_DATE_C          DATE,
--   MPU_NOTES_C                                 VARCHAR(98304),
--   REROOF_NOTES_C                              VARCHAR(98304),
--   REROOF_SQUARES_C                            numeric,
--   SCHEDULED_HOME_ENERGY_AUDIT_DATE_C          TIMESTAMPTZ,
--   SCHEDULED_PARALLEL_SITE_SURVEY_DATE_C       TIMESTAMPTZ,
--   SUN_POWER_PERMIT_OVERRIDE_C                 BOOLEAN,
--   EVSE_IP_FEE_C                               numeric(18, 2),
--   EVSE_NOTES_C                                VARCHAR(98304),
--   SCHEDULED_EV_INSTALLATION_DATE_C            DATE,
--   EV_ELECTRICIAN_PARTNER_C                    VARCHAR(18),
--   MPU_ELECTRICIAN_PARTNER_C                   VARCHAR(18),
--   SUN_VAULT_DEAL_TYPE_C                       VARCHAR(765),
--   RP_FIELDS_AND_BUILDER_FILES_VALIDATED_C     VARCHAR(765),
--   COMMITMENT_DATE_C                           DATE,
--   NTP_DATE_C                                  DATE,
--   PTO_DATE_C                                  DATE,
--   RSE_OUTCOME_C                               VARCHAR(765),
--   SITE_ID_C                                   VARCHAR(765),
--   SYSTEM_ACTIVATION_STATUS_C                  VARCHAR(765),
--   WI_FI_CONNECTED_C                           BOOLEAN,
--   ESD_DATE_C                                  DATE,
--   EVSE_COUNT_C                                VARCHAR(765),
--   EVSE_NAME_C                                 VARCHAR(765),
--   EVSE_TYPE_C                                 VARCHAR(765),
--   EV_CHARGER_RETAIL_AMOUNT_C                  numeric(18, 2),
--   PV_ROUGH_PO_C                               VARCHAR(765),
--   PV_TRIM_PO_C                                VARCHAR(765),
--   ROOFER_INSET_PO_C                           VARCHAR(765),
--   STORAGE_ROUGH_PO_C                          VARCHAR(765),
--   STORAGE_TRIM_PO_C                           VARCHAR(765),
--   TRENCH_COMPLETED_BY_C                       VARCHAR(18),
--   TRENCH_DATE_C                               DATE,
--   TRENCH_STARTED_C                            BOOLEAN,
--   STORAGE_INSTALL_COMPLETE_C                  BOOLEAN,
--   STORAGE_INSTALL_PROMISED_C                  DATE,
--   STORAGE_ROUGH_COMPLETE_C                    BOOLEAN,
--   STORAGE_ROUGH_WIRE_PROMISED_C               DATE,
--   EV_CHARGER_PRICE_C                          numeric(18, 2),
--   EV_CHARGER_QUANTITY_C                       numeric,
--   EV_OUTLET_MODEL_C                           VARCHAR(765),
--   EV_OUTLET_PRICE_C                           numeric(18, 2),
--   EV_OUTLET_QUANTITY_C                        numeric,
--   REV_REC_DATE_C                              DATE,
--   UTILITY_TEXT_C                              VARCHAR(765),
--   SUN_VAULT_EC_GUIDE_COMPLEXITY_C             VARCHAR(765),
--   SUN_VAULT_INSTALLATION_COMPLEXITY_C         VARCHAR(765),
--   ACTIVATION_COORDINATOR_C                    VARCHAR(18),
--   SUNVAULT_MODEL_DISCOUNT_AMOUNT_C            numeric(18, 2),
--   SUNVAULT_MODEL_DISCOUNT_C                   numeric,
--   BLOCK_REASON_C                              VARCHAR(765),
--   FORECASTED_UNBLOCK_DATE_C                   DATE,
--   FORECASTED_INSTALL_START_C                  DATE,
--   FORECASTED_INSTALL_COMPLETION_C             DATE,
--   HOA_SUBMISSION_DATE_C                       DATE,
--   ESCROW_DATE_HO_C                            DATE,
--   FOLLOW_UP_DATE_C                            DATE,
--   PERMIT_APPROVED_C                           DATE,
--   PERMIT_ETA_REWORK_REASON_C                  VARCHAR(765),
--   PERMIT_FEES_PAID_C                          VARCHAR(765),
--   PERMIT_FEES_PAID_IN_FULL_C                  BOOLEAN,
--   SOLAR_APP_ELIGIBLE_C                        BOOLEAN,
--   SUBMITTED_THROUGH_SOLAR_APP_C               BOOLEAN,
--   FIRST_QUOTE_LOCK_DATE_C                     DATE,
--   FIRST_SCHEDULED_INSTALLATION_DATE_C         TIMESTAMPTZ,
--   INCENTIVE_STATUS_C                          VARCHAR(765),
--   PROJECT_COORDINATOR_C                       VARCHAR(18),
--   RESCHEDULED_REASON_CODE_C                   VARCHAR(765),
--   RESCHEDULED_REASON_OTHER_C                  VARCHAR(765),
--   FORECASTED_INSTALLATION_COMPLETE_C          TIMESTAMPTZ,
--   FORECASTED_INSTALLATION_START_C             TIMESTAMPTZ,
--   INTERCONNECTION_ETA_DATE_C                  DATE,
--   RA_ONLY_DATE_C                              DATE,
--   TWILIO_HO_ESCROW_DATE_STATUS_C              VARCHAR(765),
--   BETA_LAUNCH_ESCROW_C                        BOOLEAN,
--   CT_CATEGORY_DESIGN_C                        VARCHAR(765),
--   CT_CATEGORY_DISCREPANCY_C                   VARCHAR(765),
--   CT_CATEGORY_FIELD_QUALITY_C                 VARCHAR(765),
--   CT_COMMENTS_C                               VARCHAR(765),
--   CT_SHOULD_BE_INSTALLED_C                    VARCHAR(765),
--   HO_PROVIDED_ESCROW_RESPONSE_C               VARCHAR(765),
--   WAS_CT_INSTALLED_C                          VARCHAR(765),
--   EXISTING_INSTALL_C                          BOOLEAN,
--   _FIVETRAN_SYNCED                            TIMESTAMPTZ,
--   SUN_VAULT_PART_NUMBER_C                     VARCHAR(54),
--   NEW_CONSTRUCTION_ADU_C                      BOOLEAN,
--   HOLD_RELEASE_DATE_C                         DATE,
--   PERMIT_APPLICATION_NUMBER_C                 VARCHAR(765),
--   UTILITY_INFO_EMAIL_SENT_C                   DATE,
--   SITE_BETA_C                                 BOOLEAN,
--   NEM_APPLICABILITY_C                         VARCHAR(765),
--   UTILITY_METER_NUMBER_C                      VARCHAR(765),
--   UTILITY_ACCOUNT_NUMBER_C                    VARCHAR(765),
--   SITE_LAUNCH_TYPE_C                          VARCHAR(765),
--   SITE_PRODUCT_LINE_C                         VARCHAR(765),
--   PRE_INSTALL_SUBMITTED_C                     BOOLEAN,
--   DEEMED_COMPLETED_C                          BOOLEAN,
--   ESTIMATED_INSTALL_LABOR_HOURS_C             numeric,
--   _FIVETRAN_DELETED                           BOOLEAN,
--   PCS_C                                       BOOLEAN,
--   RISK_RECORD_C                               BOOLEAN,
--   RISK_RECORD_DATE_C                          DATE,
--   IS_NEM_2_0_C                                BOOLEAN,
--   STORAGE_SYSTEM_C                            VARCHAR(765),
--   AC_SYSTEM_SIZE_C                            numeric,
--   APPLICATION_DATE_SUBMISSION_DATE_C          TIMESTAMPTZ,
--   STORAGE_SYSTEM_K_WH_C                       numeric,
--   APPLICATION_REVISION_NUMBER_C               VARCHAR(765),
--   INTERCONNECTION_APPLICATION_REVISION_DATE_C DATE,
--   HOA_NAME_2_C                                VARCHAR(765),
--   STORAGE_PARTNER_C                           VARCHAR(18),
--   AMOUNT_CONTRIBUTED_BY_SPWR_C                numeric(18, 2),
--   EXISTING_PV_SYSTEM_SIZE_C                   numeric,
--   EXISTING_INVERTER_TYPE_C                    VARCHAR(765),
--   CHANGE_ORDER_TRANSACTED_DATE_C              DATE,
--   INSTALL_COMPLETED_C                         DATE,
--   DOG_ON_SITE_C                               VARCHAR(765),
--   EXISTING_PV_FINANCIAL_OFFERING_C            VARCHAR(765),
--   REASON_LEVEL_1_C                            VARCHAR(765),
--   INSTALL_COMPLETED_BY_C                      VARCHAR(18),
--   CREDIT_MEMO_TRANSACTED_DATE_C               DATE,
--   AGE_OF_HOME_C                               VARCHAR(765),
--   TRIM_INSTALL_COMPLETED_C                    DATE,
--   CHANGE_ORDER_TOTAL_COST_C                   numeric(18, 2),
--   ATTIC_CRAWL_SPACE_C                         VARCHAR(765),
--   TRIM_INSTALL_COMPLETED_BY_C                 VARCHAR(18),
--   ELAPSED_DATE_TIME_C                         TIMESTAMPTZ,
--   CHANGE_ORDER_TRANSACTED_BY_C                VARCHAR(18),
--   EXISTING_INVERTER_QUANTITY_C                numeric,
--   PV_INSTALL_COMPLETED_BY_C                   VARCHAR(18),
--   INSTALL_COMPLETE_C                          BOOLEAN,
--   STRUCTURAL_OPTION_C                         VARCHAR(765),
--   ROUGH_WIRE_COMPLETED_C                      DATE,
--   AGE_OF_ROOF_C                               VARCHAR(765),
--   ENHANCEMENTS_C                              VARCHAR(765),
--   ELEVATION_C                                 VARCHAR(765),
--   PREFERRED_COMMUNICATION_C                   VARCHAR(765),
--   AMOUNT_CONTRIBUTED_BY_DEALER_C              numeric(18, 2),
--   UNBLOCK_QUOTE_AMENDMENT_C                   BOOLEAN,
--   UTILITY_METER_CONFIRMATION_DATE_C           DATE,
--   COMPLEXITY_INDICATOR_C                      VARCHAR(765),
--   UTILITY_METER_INSTALLED_C                   VARCHAR(765),
--   AMOUNT_CONTRIBUTED_BY_CUSTOMER_C            numeric(18, 2),
--   TRIM_INSTALL_COMPLETE_C                     BOOLEAN,
--   MILESTONE_C                                 VARCHAR(765),
--   PV_INSTALL_COMPLETE_C                       BOOLEAN,
--   EXISTING_MONITORING_DEVICE_C                VARCHAR(765),
--   TREE_TRIM_C                                 VARCHAR(765),
--   INTAKE_NOTES_C                              VARCHAR(98304),
--   ROUGHWIRE_COMPLETE_C                        BOOLEAN,
--   CHANGE_ORDER_ENTERED_BY_C                   VARCHAR(18),
--   ROUGH_WIRE_COMPLETED_BY_C                   VARCHAR(18),
--   CHANGE_ORDER_ENTERED_DATE_C                 DATE,
--   EXISTING_PV_PANEL_TYPE_C                    VARCHAR(765),
--   EXISTING_PV_PANEL_QUANTITY_C                numeric,
--   STORAGE_RW_C                                numeric(18, 2),
--   INVERTER_STATUS_C                           VARCHAR(765),
--   WO_STORAGE_SIZE_C                           VARCHAR(765),
--   STORAGE_SIZE_DISCREPANCY_C                  BOOLEAN,
--   STORAGE_INSTALL_C                           numeric(18, 2),
--   INVOICE_NUMBER_C                            numeric,
--   GATE_CODE_C                                 VARCHAR(765),
--   REASON_LEVEL_2_C                            VARCHAR(765),
--   PRE_COE_COMM_FAILURE_REASON_C               VARCHAR(765),
--   ADDERS_VALUE_QUOTE_C                        numeric(18, 2),
--   CUSTOMER_CONSTRUCTION_PROJECT_C             VARCHAR(765),
--   MICROINVERTER_STATUS_C                      VARCHAR(765),
--   ESCALATION_C                                BOOLEAN,
--   TIME_DIFFERENTIAL_C                         numeric,
--   VIP_C                                       BOOLEAN,
--   ROOF_MATERIAL_C                             VARCHAR(765),
--   CREDIT_MEMO_NUMBER_C                        numeric,
--   HOA_CONTACT_PHONE_EMAIL_C                   VARCHAR(765),
--   PRE_COE_COMM_NOTES_C                        VARCHAR(765),
--   PV_INSTALL_COMPLETED_C                      DATE,
--   LINKED_RP_C                                 VARCHAR(18),
--   STORAGE_INSTALL_COMPLETE_PULL_DATE_C        TIMESTAMPTZ,
--   ROUGH_WIRE_PULL_DATE_C                      TIMESTAMPTZ,
--   INSTALL_PULL_DATE_C                         TIMESTAMPTZ,
--   TRIM_INSTALL_PULL_DATE_C                    TIMESTAMPTZ,
--   STORAGE_ROUGH_COMPLETE_PULL_DATE_C          TIMESTAMPTZ,
--   SITE_SURVEY_COMPLETE_DATE_C                 DATE,
--   AT_RISK_TO_PENDING_CANCELLATION_DATE_C      DATE,
--   PAYMENT_PRE_AUTH_OUTCOME_C                  VARCHAR(765),
--   PERMIT_APPROVED_NOTIFICATION_C              VARCHAR(765),
--   READY_TO_SCHEDULE_NOTIFICATION_C            VARCHAR(765),
--   PTO_DATE_NOTIFICATION_C                     VARCHAR(765),
--   INSTALL_COMPLETE_NOTIFICATION_C             VARCHAR(765),
--   DESIGN_COMPLETED_NOTIFICATION_C             VARCHAR(765),
--   INSPECTION_PASSED_NOTIFICATION_C            VARCHAR(765),
--   SCHEDULED_INSTALL_DATE_NOTIFICATION_C       VARCHAR(765),
--   OK_TO_SCHEDULE_NOTIFICATION_C               VARCHAR(765),
--   OK_TO_SCHEDULE_C                            TIMESTAMPTZ,
--   EV_SITE_SURVEY_C                            numeric(18, 2),
--   STORAGE_CONFIGURATION_GROUP_C               VARCHAR(18),
--   EV_WORKMANSHIP_WARRANTY_C                   TIMESTAMPTZ,
--   ESTIMATED_HARDWARE_DELIVERY_DATE_C          DATE,
--   HARDWARE_DELIVERED_DATE_C                   DATE,
--   DESIGN_REJECTED_DETAILS_C                   VARCHAR(1500),
--   DESIGN_VERIFICATION_C                       VARCHAR(765),
--   TRIGGER_DESIGN_VERIFICATION_C               BOOLEAN,
--   DESIGN_STATUS_C                             VARCHAR(765),
--   SHARE_WITH_GUEST_USER_C                     BOOLEAN,
--   DESIGN_STATUS_DATE_C                        TIMESTAMPTZ,
--   DESIGN_REJECTED_REASON_C                    VARCHAR(765),
--   INSTALLATION_PHOTO_CIRCLE_LINK_C            VARCHAR(765),
--   OM_PHOTO_CIRCLE_LINK_C                      VARCHAR(765),
--   AUTO_BOOKED_C                               BOOLEAN,
--   SITE_SURVEY_PHOTO_CIRCLE_LINK_C             VARCHAR(765),
--   INSPECTION_PHOTO_CIRCLE_LINK_C              VARCHAR(765),
--   T_24_NOTES_C                                VARCHAR(393216),
--   STORAGE_ROUGH_COMPLETE_DATE_C               DATE,
--   STORAGE_INSTALL_COMPLETE_DATE_C             DATE,
--   STORAGE_ROUGH_COMPLETED_BY_C                VARCHAR(18),
--   STORAGE_INSTALL_COMPLETED_BY_C              VARCHAR(18),
--   OWNING_TEAM_C                               VARCHAR(765),
--   CUSTOMER_CONTACT_UPDATE_DATE_C              DATE,
--   INTEGRATION_STATUS_C                        VARCHAR(765),
--   TIGER_TEAM_C                                BOOLEAN,
--   CUSTOMER_CONTACT_UPDATE_C                   VARCHAR(765),
--   MISC_NOTES_C                                VARCHAR(765),
--   MODULE_COUNT_DISCREPANCY_C                  BOOLEAN,
--   ACTIVATE_INSTALL_TRACKER_TIMESTAMP_C        TIMESTAMPTZ,
--   EMAILS_SENT_C                               VARCHAR(4099),
--   DAYLIGHT_SAVINGS_OFFSET_C                   numeric,
--   OPP_TEAM_COMPLETE_C                         BOOLEAN,
--   UPDATE_SHARING_C                            BOOLEAN,
--   INTERNET_ACCESS_C                           VARCHAR(765),
--   TIME_ZONE_ID_C                              VARCHAR(765),
--   WO_STORAGE_C                                VARCHAR(18),
--   TIME_ZONE_RAW_OFFSET_C                      numeric
-- );
--
-- drop table if exists brs.ACCOUNT;
-- create table if not exists brs.ACCOUNT
-- (
--   ID                                                  VARCHAR(18),
--   IS_DELETED                                          BOOLEAN,
--   MASTER_RECORD_ID                                    VARCHAR(18),
--   NAME                                                VARCHAR(765),
--   LAST_NAME                                           VARCHAR(240),
--   FIRST_NAME                                          VARCHAR(120),
--   SALUTATION                                          VARCHAR(120),
--   TYPE                                                VARCHAR(765),
--   RECORD_TYPE_ID                                      VARCHAR(18),
--   PARENT_ID                                           VARCHAR(18),
--   BILLING_STREET                                      VARCHAR(765),
--   BILLING_CITY                                        VARCHAR(120),
--   BILLING_STATE                                       VARCHAR(240),
--   BILLING_POSTAL_CODE                                 VARCHAR(60),
--   BILLING_COUNTRY                                     VARCHAR(240),
--   BILLING_LATITUDE                                    numeric,
--   BILLING_LONGITUDE                                   numeric,
--   BILLING_GEOCODE_ACCURACY                            VARCHAR(120),
--   SHIPPING_STREET                                     VARCHAR(765),
--   SHIPPING_CITY                                       VARCHAR(120),
--   SHIPPING_STATE                                      VARCHAR(240),
--   SHIPPING_POSTAL_CODE                                VARCHAR(60),
--   SHIPPING_COUNTRY                                    VARCHAR(240),
--   SHIPPING_LATITUDE                                   numeric,
--   SHIPPING_LONGITUDE                                  numeric,
--   SHIPPING_GEOCODE_ACCURACY                           VARCHAR(120),
--   PHONE                                               VARCHAR(120),
--   FAX                                                 VARCHAR(120),
--   ACCOUNT_NUMBER                                      VARCHAR(120),
--   WEBSITE                                             VARCHAR(765),
--   PHOTO_URL                                           VARCHAR(765),
--   SIC                                                 VARCHAR(60),
--   INDUSTRY                                            VARCHAR(765),
--   ANNUAL_REVENUE                                      numeric(18),
--   NUMBER_OF_EMPLOYEES                                 numeric,
--   OWNERSHIP                                           VARCHAR(765),
--   TICKER_SYMBOL                                       VARCHAR(60),
--   DESCRIPTION                                         VARCHAR(96000),
--   RATING                                              VARCHAR(765),
--   SITE                                                VARCHAR(240),
--   CURRENCY_ISO_CODE                                   VARCHAR(9),
--   OWNER_ID                                            VARCHAR(18),
--   CREATED_DATE                                        TIMESTAMPTZ,
--   CREATED_BY_ID                                       VARCHAR(18),
--   LAST_MODIFIED_DATE                                  TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                                 VARCHAR(18),
--   SYSTEM_MODSTAMP                                     TIMESTAMPTZ,
--   LAST_ACTIVITY_DATE                                  DATE,
--   LAST_VIEWED_DATE                                    TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                                TIMESTAMPTZ,
--   IS_PARTNER                                          BOOLEAN,
--   IS_CUSTOMER_PORTAL                                  BOOLEAN,
--   PERSON_CONTACT_ID                                   VARCHAR(18),
--   IS_PERSON_ACCOUNT                                   BOOLEAN,
--   CHANNEL_PROGRAM_NAME                                VARCHAR(765),
--   CHANNEL_PROGRAM_LEVEL_NAME                          VARCHAR(765),
--   PERSON_MAILING_STREET                               VARCHAR(765),
--   PERSON_MAILING_CITY                                 VARCHAR(120),
--   PERSON_MAILING_STATE                                VARCHAR(240),
--   PERSON_MAILING_POSTAL_CODE                          VARCHAR(60),
--   PERSON_MAILING_COUNTRY                              VARCHAR(240),
--   PERSON_MAILING_LATITUDE                             numeric,
--   PERSON_MAILING_LONGITUDE                            numeric,
--   PERSON_MAILING_GEOCODE_ACCURACY                     VARCHAR(120),
--   PERSON_OTHER_STREET                                 VARCHAR(765),
--   PERSON_OTHER_CITY                                   VARCHAR(120),
--   PERSON_OTHER_STATE                                  VARCHAR(240),
--   PERSON_OTHER_POSTAL_CODE                            VARCHAR(60),
--   PERSON_OTHER_COUNTRY                                VARCHAR(240),
--   PERSON_OTHER_LATITUDE                               numeric,
--   PERSON_OTHER_LONGITUDE                              numeric,
--   PERSON_OTHER_GEOCODE_ACCURACY                       VARCHAR(120),
--   PERSON_MOBILE_PHONE                                 VARCHAR(120),
--   PERSON_HOME_PHONE                                   VARCHAR(120),
--   PERSON_OTHER_PHONE                                  VARCHAR(120),
--   PERSON_ASSISTANT_PHONE                              VARCHAR(120),
--   PERSON_EMAIL                                        VARCHAR(240),
--   PERSON_TITLE                                        VARCHAR(240),
--   PERSON_DEPARTMENT                                   VARCHAR(240),
--   PERSON_ASSISTANT_NAME                               VARCHAR(120),
--   PERSON_LEAD_SOURCE                                  VARCHAR(765),
--   PERSON_BIRTHDATE                                    DATE,
--   PERSON_HAS_OPTED_OUT_OF_EMAIL                       BOOLEAN,
--   PERSON_DO_NOT_CALL                                  BOOLEAN,
--   PERSON_LAST_CUREQUEST_DATE                          TIMESTAMPTZ,
--   PERSON_LAST_CUUPDATE_DATE                           TIMESTAMPTZ,
--   PERSON_EMAIL_BOUNCED_REASON                         VARCHAR(765),
--   PERSON_EMAIL_BOUNCED_DATE                           TIMESTAMPTZ,
--   PERSON_INDIVIDUAL_ID                                VARCHAR(18),
--   JIGSAW                                              VARCHAR(60),
--   JIGSAW_COMPANY_ID                                   VARCHAR(60),
--   ACCOUNT_SOURCE                                      VARCHAR(765),
--   SIC_DESC                                            VARCHAR(240),
--   CONNECTION_RECEIVED_ID                              VARCHAR(18),
--   CONNECTION_SENT_ID                                  VARCHAR(18),
--   ACBPARANET_ID_C                                     VARCHAR(75),
--   ALLIANCE_PROGRAM_PARTNER_C                          BOOLEAN,
--   ANALYSIS_YEAR_C                                     VARCHAR(15),
--   ASSIGNED_TSE_C                                      VARCHAR(18),
--   SIGNED_RESIDENTIAL_INSTALLER_AGREEMENT_C            BOOLEAN,
--   AUTHORIZED_PARTNER_DATE_C                           DATE,
--   AUTHORIZED_TO_ORDER_C                               BOOLEAN,
--   COMPLETED_AND_SIGNED_CREDIT_APPLICATION_C           BOOLEAN,
--   COUNTRY_DOMAIN_C                                    VARCHAR(765),
--   CREDIT_CHECK_C                                      BOOLEAN,
--   CREDIT_HOLD_C                                       BOOLEAN,
--   CREDIT_LIMIT_DATE_C                                 DATE,
--   CREDIT_LIMIT_C                                      numeric(10, 2),
--   FEDERAL_AGENCY_C                                    BOOLEAN,
--   FORECASTING_TOOL_ACCESS_C                           BOOLEAN,
--   INTEGRATION_ID_C                                    VARCHAR(60),
--   LAST_OPPORTUNITY_ASSIGNED_DATE_C                    DATE,
--   MANAGE_OPPORTUNITIES_C                              BOOLEAN,
--   NEXT_CREDIT_REVIEW_C                                DATE,
--   NUM_OPEN_OPPORTUNITIES_C                            numeric,
--   OPPORTUNITY_CLOSE_RATE_C                            numeric,
--   ORACLE_ACCOUNT_CREATED_C                            BOOLEAN,
--   OVERRIDE_DUPLICATE_CHECK_C                          BOOLEAN,
--   PARTICIPATE_IN_CUSTOMER_SURVEY_C                    BOOLEAN,
--   PARTICIPATE_IN_INSPECTION_SURVEY_C                  BOOLEAN,
--   PARTNER_ACTIVATED_DATE_TIME_C                       TIMESTAMPTZ,
--   PARTNER_APPLICATION_C                               VARCHAR(18),
--   PARTNER_FACTS_C                                     VARCHAR(96000),
--   PARTNER_LOGO_C                                      VARCHAR(765),
--   PARTNER_PORTAL_ACCESS_C                             BOOLEAN,
--   PAYBACK_PLAN_C                                      BOOLEAN,
--   PREFERRED_AGENT_C                                   VARCHAR(18),
--   PRIMARY_CONTACT_C                                   VARCHAR(18),
--   PROMOTED_PREMIER_DATE_C                             DATE,
--   RSM_C                                               VARCHAR(18),
--   RESALE_CERTIFICATE_C                                BOOLEAN,
--   REVIEW_CYCLE_C                                      VARCHAR(765),
--   SENT_PARTNER_PACKAGE_C                              BOOLEAN,
--   SIGNED_AUTHORIZED_PARTNER_AGREEMENT_C               BOOLEAN,
--   SIGNED_NON_DISCLOSURE_AGREEMENT_C                   BOOLEAN,
--   SIGNED_PREMIER_PARTNER_AGREEMENT_C                  BOOLEAN,
--   SIGNED_AND_NOTARIZED_PERSONAL_GUARANTY_C            BOOLEAN,
--   SMART_STORE_ACCESS_C                                BOOLEAN,
--   SOURCE_REFERENCE_C                                  VARCHAR(150),
--   STATUS_C                                            VARCHAR(765),
--   SUN_POWER_UNIVERSITY_ACCESS_C                       BOOLEAN,
--   TERMINATED_DATE_C                                   DATE,
--   TERRITORY_ASSIGNED_C                                BOOLEAN,
--   TOTAL_EXPERIENCE_IN_SOLAR_BUSINESS_C                VARCHAR(765),
--   WELCOME_COMMUNICATION_CUSTOMER_TEAM_C               BOOLEAN,
--   WELCOME_KIT_ORDERED_C                               BOOLEAN,
--   ASSIGNED_PSR_IDS_C                                  VARCHAR(765),
--   ASSIGNED_PSR_S_C                                    VARCHAR(765),
--   TERRITORY_C                                         VARCHAR(300),
--   THEATER_C                                           VARCHAR(765),
--   RESIDENTIAL_INSTALLER_SINCE_DATE_C                  DATE,
--   ORACLE_ACCOUNT_NUMBER_C                             VARCHAR(120),
--   PROMOTED_AUTHORIZED_PARTNER_DATE_C                  DATE,
--   OPPORTUNITY_RECIPIENT_C                             VARCHAR(18),
--   SIGNED_AUTHORIZED_SR_2_PARTNER_AGREEMENT_C          BOOLEAN,
--   EMAIL_C                                             VARCHAR(240),
--   PARTNER_CLASS_C                                     VARCHAR(765),
--   REFERRAL_PROGRAM_STATUS_C                           VARCHAR(765),
--   REFERRAL_REWARD_COMPLETE_C                          BOOLEAN,
--   EXECUTIVES_VIEW_ALL_OPPORTUNITIES_C                 BOOLEAN,
--   ALLOW_ALL_TO_VIEW_OPPORTUNITIES_C                   BOOLEAN,
--   ONLINE_ORDER_ACCESS_C                               BOOLEAN,
--   ORACLE_OPERATING_UNIT_C                             VARCHAR(765),
--   PRIMARY_PSR_C                                       VARCHAR(18),
--   RESIDENTIAL_INSTALLER_DATE_C                        DATE,
--   AUTHORIZED_SUNRISE_2_PARTNER_DATE_C                 DATE,
--   APNS_C                                              VARCHAR(297),
--   ACCOUNT_ACRONYM_C                                   VARCHAR(30),
--   ACCOUNT_CODE_C                                      VARCHAR(60),
--   ACCOUNT_POTENTIAL_C                                 VARCHAR(765),
--   ACTIVE_IN_THE_FOLLOWING_U_S_STATES_C                VARCHAR(360),
--   AVG_LOCATION_SIZE_K_WP_C                            VARCHAR(765),
--   BANK_GUARANTEE_C                                    BOOLEAN,
--   BEST_TIME_TO_CALL_C                                 VARCHAR(765),
--   PRIMARY_RMA_SPECIALIST_C                            VARCHAR(18),
--   CONTRACT_WITH_AN_ENERGY_OFFTAKER_C                  VARCHAR(765),
--   CURRENT_ENERGY_PROJECT_DESCRIPTION_C                VARCHAR(765),
--   DAS_ID_C                                            VARCHAR(180),
--   D_U_N_S_C                                           VARCHAR(60),
--   DO_YOU_HAVE_AN_INTERCONNECTION_AGREEMENT_C          VARCHAR(765),
--   ELITE_PARTNER_SINCE_DATE_C                          DATE,
--   ELITE_PARTNER_DATE_C                                DATE,
--   ENTITY_FILE_NUMBER_C                                VARCHAR(45),
--   ENTITY_TYPE_C                                       VARCHAR(765),
--   EQUITY_INVESTOR_A_OWNERSHIP_C                       numeric,
--   EQUITY_INVESTOR_A_C                                 VARCHAR(18),
--   EQUITY_INVESTOR_B_OWNERSHIP_C                       numeric,
--   EQUITY_INVESTOR_B_C                                 VARCHAR(18),
--   INTERNAL_CLIENT_NAME_C                              VARCHAR(360),
--   INVESTOR_CATEGORY_C                                 VARCHAR(765),
--   KEY_VERTICAL_C                                      VARCHAR(765),
--   LEAD_QUALIFICATION_NOTES_C                          VARCHAR(96000),
--   MW_POTENTIAL_AVAILABLE_INCENTIVES_C                 VARCHAR(765),
--   MW_POTENTIAL_NO_CURRENT_INCENTIVES_C                VARCHAR(765),
--   NEAREST_CITY_OR_TOWN_C                              VARCHAR(120),
--   NUMBER_OF_EMPLOYEES_C                               numeric,
--   NUMBER_OF_HOMES_BUILT_YEAR_C                        numeric,
--   NUMBER_OF_SITES_C                                   numeric,
--   OSKEY_ID_C                                          VARCHAR(48),
--   PLATINUM_ACCOUNT_C                                  BOOLEAN,
--   PERCENTAGE_MULTI_FAMILY_HOMES_C                     numeric,
--   PERCENTAGE_OTHER_TYPE_OF_HOMES_C                    numeric,
--   PERCENTAGE_SINGLE_FAMILY_HOMES_C                    numeric,
--   PINNACLE_PASSWORD_C                                 VARCHAR(75),
--   PINNACLE_USERNAME_C                                 VARCHAR(75),
--   OPERATIONS_COORDINATOR_C                            VARCHAR(18),
--   WIND_C                                              BOOLEAN,
--   IMAGE_C                                             VARCHAR(98304),
--   ROOF_TYPE_C                                         VARCHAR(4099),
--   RUGOSITE_C                                          VARCHAR(765),
--   PRIOR_SOLAR_USER_C                                  VARCHAR(765),
--   PRIOR_ENERGY_PROJECT_EXPERIENCE_C                   VARCHAR(765),
--   PROJECT_ROLE_C                                      VARCHAR(765),
--   PROMOTED_ELITE_PARTNER_DATE_C                       DATE,
--   RSM_2_C                                             VARCHAR(18),
--   REBATE_C                                            numeric,
--   SERVICE_LEVEL_C                                     VARCHAR(765),
--   SIGNED_AGREEMENT_C                                  VARCHAR(765),
--   SIGNED_ELITE_PARTNER_AGREEMENT_C                    BOOLEAN,
--   SOLAR_PROCUREMENT_STRUCTURE_C                       VARCHAR(765),
--   SOLAR_C                                             BOOLEAN,
--   SNOW_TOPOGRAPHY_C                                   VARCHAR(765),
--   LOCATION_MATCH_STATUS_C                             VARCHAR(765),
--   STATE_QUALIFICATIONS_PENDING_C                      VARCHAR(4099),
--   STATE_QUALIFICATIONS_C                              VARCHAR(4099),
--   CUSTOMER_PORTAL_PING_USER_C                         VARCHAR(18),
--   TEST_PARTNER_FACTS_C                                VARCHAR(765),
--   TOTAL_ACREAGE_OF_SITE_C                             numeric,
--   CASH_PARTNER_C                                      BOOLEAN,
--   UTILITY_TYPE_C                                      VARCHAR(765),
--   WHICH_UTILITY_SERVICE_AREA_S_C                      VARCHAR(4099),
--   WILLING_TO_SIGN_MASTER_AGREEMENT_C                  VARCHAR(765),
--   LOCATION_MATCH_STATUS_TEXT_C                        VARCHAR(765),
--   SUN_POWER_PRODUCTS_AND_SERVICES_CONTACT_C           VARCHAR(765),
--   NOTES_C                                             VARCHAR(765),
--   CRSM_C                                              VARCHAR(18),
--   SECOND_LEVEL_SIC_NAME_C                             VARCHAR(750),
--   ACCOUNT_STATUS_C                                    VARCHAR(765),
--   AREAS_OF_EXPERTISE_C                                VARCHAR(4099),
--   BUSINESS_UNIT_C                                     VARCHAR(765),
--   CONTACT_NAME_C                                      VARCHAR(750),
--   FIRST_LEVEL_SIC_NAME_C                              VARCHAR(750),
--   HD_LEAD_STATUS_C                                    VARCHAR(765),
--   LEAD_APPROVAL_C                                     VARCHAR(765),
--   NUMBER_OF_ACTIVE_SITES_C                            numeric,
--   NUMBER_OF_INACTIVE_SITES_C                          numeric,
--   REASON_FOR_INACTIVE_C                               VARCHAR(765),
--   SPWR_INDUSTRY_TYPE_C                                VARCHAR(765),
--   SPWR_RELATIONSHIP_TYPE_C                            VARCHAR(4099),
--   THIRD_LEVEL_SIC_NAME_C                              VARCHAR(750),
--   X_ACCOUNT_OWNER_C                                   VARCHAR(18),
--   BUSINESS_UNIT_1_C                                   VARCHAR(765),
--   LOYALTY_PARTNER_C                                   BOOLEAN,
--   MEGAWATT_C                                          VARCHAR(48),
--   SAME_AS_CASH_PROGRAM_PARTNER_C                      BOOLEAN,
--   LEASE_PROGRAM_PARTNER_C                             BOOLEAN,
--   WOMAN_OWNED_BUSINESS_C                              BOOLEAN,
--   UNDERREPRESENTED_MINORITY_OWNED_BUSINESS_C          BOOLEAN,
--   CERTIFICATION_NUMBER_FOR_WOMAN_OWNED_C              VARCHAR(150),
--   CERTIFICATION_NUMBER_FOR_MINORITY_OWNED_C           VARCHAR(150),
--   CERTIFYING_AGENCY_FOR_WOMAN_OWNED_C                 VARCHAR(300),
--   CERTIFYING_AGENCY_FOR_MINORITY_OWNED_C              VARCHAR(300),
--   FACILITY_ADDRESS_C                                  VARCHAR(765),
--   FACILITY_ADDRESS_2_C                                VARCHAR(765),
--   FACILITY_CITY_C                                     VARCHAR(765),
--   FACILITY_STATE_C                                    VARCHAR(765),
--   FACILITY_ZIP_C                                      VARCHAR(180),
--   AVAILABLE_CREDIT_C                                  numeric(10, 2),
--   OPEN_BALANCE_C                                      numeric(10, 2),
--   REQUEST_CONNECTION_CODE_C                           VARCHAR(45),
--   REQUEST_CONNECTION_TITLE_OWNER_1_C                  VARCHAR(297),
--   INTERCONNECTION_REQUEST_FILED_C                     DATE,
--   INTERCONNECTION_AGREEMENT_EXECUTED_C                DATE,
--   PHASE_I_STUDY_RECEIVED_C                            DATE,
--   PHASE_I_STUDY_ACCEPTED_C                            DATE,
--   EXPECTED_DATE_CONNECTION_BUILDING_C                 DATE,
--   ACCEPTING_PHASE_I_VALID_UNTIL_C                     DATE,
--   INTERCONNECTION_APPLICATION_SUBMITTED_C             DATE,
--   INTERCONNECTION_APPROVED_C                          DATE,
--   EXPECTED_DATE_SUBSTATION_BUILDING_C                 DATE,
--   TRANSMISSION_CAPACITY_USED_C                        numeric,
--   TRANSMISSION_CAPACITY_C                             numeric,
--   AMOUNT_PAST_DUE_C                                   numeric,
--   CONTACT_LANGUAGE_C                                  VARCHAR(765),
--   HOOVERS_ID_C                                        VARCHAR(60),
--   MULTI_QUARTER_CONTRACT_PARTICIPANT_C                BOOLEAN,
--   SEND_PDF_NOTIFICATION_C                             BOOLEAN,
--   SUBSCRIPTION_DATE_C                                 TIMESTAMPTZ,
--   ADDITIONAL_OPPORTUNITY_EMAIL_RECIPIENT_C            VARCHAR(240),
--   ONLINE_ORDER_ACCESS_DATE_C                          DATE,
--   ORACLE_ACCOUNT_CREATED_DATE_C                       DATE,
--   LOCATION_C                                          VARCHAR(18),
--   SMS_SITE_ID_C                                       VARCHAR(60),
--   PE_GU_START_DATE_C                                  DATE,
--   EXPECTED_PERFORMANCE_YEAR_1_K_WH_C                  numeric,
--   PE_GU_PROGRAM_C                                     VARCHAR(765),
--   MODULE_CATEGORY_C                                   VARCHAR(765),
--   TILT_C                                              numeric,
--   AZIMUTH_DEGREES_C                                   numeric,
--   GENERAL_DE_RATE_PERCENT_C                           numeric,
--   IS_PREMIER_CANDIDATE_C                              BOOLEAN,
--   MQC_1_MULTI_QUARTER_CONTRACT_PARTICIPANT_C          BOOLEAN,
--   MQC_2_MULTI_QUARTER_CONTRACT_PARTICIPANT_C          BOOLEAN,
--   CSAT_CYCLE_CODE_C                                   VARCHAR(765),
--   CAN_SELL_SUN_POWER_20_YR_LOAN_C                     BOOLEAN,
--   MONITOR_PROMOTION_PARTICIPANT_C                     BOOLEAN,
--   STUDY_DEPOSIT_AMT_C                                 numeric(18, 2),
--   STUDY_DEPOSIT_REMAINING_C                           numeric(18, 2),
--   SITE_CONTROL_AMOUNT_C                               numeric(18, 2),
--   SITE_CONTROL_REMAINING_C                            numeric(18, 2),
--   EUC_C                                               BOOLEAN,
--   ACH_OPT_IN_C                                        BOOLEAN,
--   NH_SSE_TYPE_C                                       VARCHAR(4099),
--   WARRANTY_SIGNED_ITALY_C                             BOOLEAN,
--   CONTRACTORS_LICENSE_C                               VARCHAR(150),
--   INSURANCE_CARRIER_C                                 VARCHAR(150),
--   INSURANCE_POLICY_C                                  VARCHAR(150),
--   REQUESTED_CREDIT_AMOUNT_C                           numeric(18),
--   CREDIT_AMOUNT_APPROVED_C                            numeric(18),
--   CLUSTER_STATUS_C                                    VARCHAR(98304),
--   CREDIT_CHECK_REQUIRED_C                             VARCHAR(765),
--   ARE_RECENT_FINANCIALS_OR_LINK_ATTACHED_C            VARCHAR(765),
--   NET_TERMS_C                                         VARCHAR(297),
--   PARTNER_PORTAL_REGISTRATION_C                       BOOLEAN,
--   LEASE_C                                             BOOLEAN,
--   LEASE_2_0_PROGRAM_PARTNER_C                         BOOLEAN,
--   ORACLE_VENDOR_NUMBER_C                              VARCHAR(90),
--   ORACLE_CUSTOMER_CLASSIFICATION_C                    VARCHAR(765),
--   ORACLE_VENDOR_SITE_CODE_C                           VARCHAR(90),
--   ORACLE_WAREHOUSE_C                                  VARCHAR(765),
--   ORACLE_ACCOUNT_TYPE_C                               VARCHAR(765),
--   ORACLE_ORDER_TYPE_C                                 VARCHAR(765),
--   ORACLE_SALES_CHANNEL_C                              VARCHAR(765),
--   ORACLE_COUNTY_C                                     VARCHAR(765),
--   RENEWAL_COMMERCIAL_10_C                             VARCHAR(150),
--   RENEWAL_RESIDENTIAL_10_C                            VARCHAR(150),
--   LEASE_CUSTOMER_C                                    BOOLEAN,
--   LEASE_ORDER_PLACED_C                                BOOLEAN,
--   ORACLE_PAYMENT_TERMS_C                              VARCHAR(765),
--   ORACLE_RELATED_ACCOUNT_C                            VARCHAR(18),
--   CUSTOMER_INTERFACE_ERROR_C                          VARCHAR(6000),
--   CUSTOMER_INTERFACE_STATUS_C                         BOOLEAN,
--   TEAM_LEAD_C                                         VARCHAR(18),
--   ORACLE_RELATED_ACCOUNT_BILL_TO_C                    VARCHAR(765),
--   ORACLE_RELATED_ACCOUNT_SHIPTO_C                     VARCHAR(765),
--   ORACLE_RELATED_ACCOUNT_RECIPROCAL_C                 VARCHAR(765),
--   ORACLE_SHIPPING_COUNTY_C                            VARCHAR(765),
--   COM_OPP_RECIPIENT_PRIMARY_C                         VARCHAR(18),
--   FORD_PROGRAM_PARTNER_C                              BOOLEAN,
--   PENDING_LITIGATION_C                                BOOLEAN,
--   ORACLE_VENDOR_EMAIL_C                               VARCHAR(240),
--   ACCOUNT_CATEGORY_C                                  VARCHAR(765),
--   AREA_SALES_MANAGER_C                                VARCHAR(18),
--   NEW_TYPE_REQUEST_C                                  VARCHAR(765),
--   NEW_TYPE_REQUEST_STATUS_C                           VARCHAR(765),
--   ADMIN_NOTES_C                                       VARCHAR(297),
--   CPR_ID_C                                            VARCHAR(60),
--   CPR_COMPANY_ID_C                                    VARCHAR(120),
--   CREDIT_CHECK_APPROVAL_DATE_C                        DATE,
--   CREDIT_CHECK_STATUS_C                               VARCHAR(765),
--   CREDIT_CHECK_SUBMISSION_DATE_C                      DATE,
--   CREDIT_CHECK_PASSED_C                               BOOLEAN,
--   LEASE_DOC_CREATED_C                                 BOOLEAN,
--   ORACLE_VENDOR_EMAIL_FIELD_VALUE_C                   VARCHAR(240),
--   PARTNER_ACCOUNT_C                                   VARCHAR(18),
--   QUOTE_TYPE_IS_LEASE_C                               BOOLEAN,
--   CREDIT_CHECK_ERROR_MESSAGE_C                        VARCHAR(765),
--   DEALER_LOCATOR_PHONE_C                              VARCHAR(120),
--   VENDOR_SUBORDINATE_C                                BOOLEAN,
--   CONTACT_LAST_MODIFIED_DATE_C                        TIMESTAMPTZ,
--   DEALER_LOCATOR_OPT_OUT_C                            BOOLEAN,
--   MULTIPLE_METERS_C                                   BOOLEAN,
--   CONTRACTORS_LIC_EXPIRY_C                            DATE,
--   INSURANCE_POL_EXPIRY_C                              DATE,
--   MARKETING_ZONE_C                                    VARCHAR(765),
--   SUN_POWER_DEALER_WEB_PAGE_URL_C                     VARCHAR(765),
--   INVOICE_DOCUMENT_EMAIL_C                            VARCHAR(240),
--   XXXXX_C                                             VARCHAR(210000),
--   GEO_LATITUDE_S                                      numeric,
--   GEO_LONGITUDE_S                                     numeric,
--   LAT_C                                               numeric,
--   LEAD_FLOW_OPT_OUT_C                                 BOOLEAN,
--   LOG_C                                               numeric,
--   OPPORTUNITY_CLOSE_C                                 numeric,
--   COMMERCIAL_PSR_C                                    VARCHAR(18),
--   BUSINESS_HOURS_C                                    VARCHAR(18),
--   REVIEW_PROPOSAL_DESIGN_C                            BOOLEAN,
--   CONTACT_SLA_C                                       numeric,
--   DEALER_SCORE_PERCENT_C                              numeric,
--   LEASE_STATUS_EMAIL_OPT_OUT_C                        VARCHAR(765),
--   VERTICAL_C                                          VARCHAR(765),
--   SUB_VERTICAL_C                                      VARCHAR(765),
--   RATING_COMMENTS_C                                   VARCHAR(98304),
--   SALES_TAX_RATE_C                                    numeric,
--   FILING_STATUS_C                                     VARCHAR(765),
--   INCOME_C                                            numeric(18),
--   CREDIT_CUSTOMER_ID_C                                VARCHAR(108),
--   CREDIT_CUSTOMER_NUMBER_C                            VARCHAR(108),
--   CURRENT_RATE_C                                      VARCHAR(765),
--   DEFAULT_IMAGE_C                                     BOOLEAN,
--   ON_MARKUP_ONLY_C                                    BOOLEAN,
--   GENERAL_LIABILITY_EXP_C                             DATE,
--   AUTOMOTIVE_EXP_C                                    DATE,
--   BUILDERS_RISK_EXP_C                                 DATE,
--   WORKERS_COMP_EXP_C                                  DATE,
--   DEALER_SCORE_SUMMARY_C                              VARCHAR(98304),
--   DEALER_SCORE_TOTAL_C                                numeric,
--   GEOLOCATION_LATITUDE_S                              numeric,
--   GEOLOCATION_LONGITUDE_S                             numeric,
--   IS_ADDRESS_UPDATED_C                                BOOLEAN,
--   OPP_CONVERT_RATE_C                                  numeric,
--   RSM_DISCRETIONARY_ADJ_C                             numeric,
--   SFDC_TIMELY_UPDATES_C                               numeric,
--   ALTITUDE_C                                          VARCHAR(765),
--   ANNUAL_ELECTRICITY_C                                numeric(18),
--   ANNUAL_ENERGY_CONSUMPTION_KWH_C                     numeric,
--   APPROVAL_APPROVED_C                                 DATE,
--   CLOSE_DATE_C                                        DATE,
--   CUSTOMER_ONBOARDING_STATUS_C                        VARCHAR(765),
--   DISTANCE_FROM_OCEAN_C                               VARCHAR(765),
--   INTERFACE_STATUS_C                                  VARCHAR(765),
--   INVALID_DEPARTMENT_C                                BOOLEAN,
--   IS_PARTY_TRULY_HOMEOWNER_C                          VARCHAR(765),
--   LAST_NAME_C                                         VARCHAR(90),
--   MAXIMUM_CELL_TEMPERATURE_C                          VARCHAR(765),
--   MINIMUM_CELL_TEMPERATURE_C                          VARCHAR(765),
--   ORIGINATION_APPROVED_C                              DATE,
--   PROTECTED_AREA_C                                    VARCHAR(765),
--   RUN_ORIGINATION_DOCS_TRIGGER_C                      BOOLEAN,
--   STAGE_C                                             VARCHAR(765),
--   UCC_FILED_DATE_C                                    DATE,
--   PORTAL_PASSWORD_C                                   VARCHAR(525),
--   PORTAL_URL_C                                        VARCHAR(765),
--   CHATTER_GROUP_NAME_C                                VARCHAR(150),
--   ADMIRAL_PROGRAM_PARTNER_C                           BOOLEAN,
--   ADMIRAL_PROGRAM_TYPE_C                              VARCHAR(4099),
--   BUSINESS_FUNCTION_C                                 VARCHAR(4099),
--   CERTIFIED_C                                         BOOLEAN,
--   FEE_CAL_LATITUDE_C                                  VARCHAR(60),
--   FEE_CAL_LONGITUDE_C                                 VARCHAR(60),
--   SPECIALIZED_INSTALLER_C                             VARCHAR(765),
--   SPECIALIZED_SELLER_C                                VARCHAR(765),
--   COUNTRIES_OF_INTEREST_C                             VARCHAR(4099),
--   PARTNER_OPT_OUT_OK_TO_SHIP_COMM_C                   BOOLEAN,
--   NAME_OF_PAST_DEALS_C                                VARCHAR(98304),
--   TYPE_OF_CAPITAL_C                                   VARCHAR(4099),
--   HQ_DUNS_NUMBER_C                                    VARCHAR(765),
--   LOCATION_OWNERSHIP_C                                VARCHAR(765),
--   LOCATION_TYPE_C                                     VARCHAR(765),
--   REPORTING_LOCATIONS_C                               numeric,
--   SITE_NO_EMPLOYEES_C                                 numeric,
--   PORTAL_USERNAME_C                                   VARCHAR(765),
--   REASON_FOR_TERMINATION_C                            VARCHAR(4099),
--   MILESTONE_C                                         VARCHAR(765),
--   SSO_USER_C                                          VARCHAR(18),
--   AVAILABLE_LENDER_C                                  VARCHAR(4099),
--   DSE_CUSTOMER_TYPE_C                                 VARCHAR(765),
--   DSE_IS_CUSTOMER_C                                   BOOLEAN,
--   DSE_SITE_C                                          VARCHAR(765),
--   ANNUAL_NPS_REPORT_LINK_C                            VARCHAR(765),
--   PARTNER_ACCESS_ID_C                                 VARCHAR(120),
--   IS_SPECTRUM_PARTNER_C                               BOOLEAN,
--   LAST_ASSIGNED_DATE_C                                DATE,
--   LEAD_ASSIGNMENT_COUNT_C                             numeric,
--   LEAD_PRIORITY_MAXIMUM_C                             numeric,
--   LEAD_PRIORITY_MINIMUM_C                             numeric,
--   PRIORITY_ASSIGNMENT_C                               VARCHAR(765),
--   OPTED_OUT_OF_OK_TO_SHIP_ONCE_C                      BOOLEAN,
--   PARTNER_OPT_OUT_OK_TO_SHIP_C                        BOOLEAN,
--   SUNRISE_C                                           VARCHAR(765),
--   EXTERNAL_DESIGN_PROJECT_ID_C                        VARCHAR(765),
--   DEFAULT_DEALER_WAREHOUSE_SHIPPING_SITE_C            VARCHAR(18),
--   SHIPPING_SITE_C                                     VARCHAR(18),
--   ORIGINATION_FEE_PARTICIPANT_C                       BOOLEAN,
--   RESIDENTIAL_FIELD_SUPERVISOR_C                      VARCHAR(18),
--   RLCPA_NOTES_C                                       VARCHAR(765),
--   S_P_500_C                                           VARCHAR(240),
--   PHONE_US_PREFIX_C                                   VARCHAR(120),
--   LOCATION_SIZE_C                                     numeric,
--   BUSINESS_REGISTRATION_C                             VARCHAR(18),
--   FORTUNE_1000_RANKING_C                              numeric,
--   CO_BRAND_PARTNER_C                                  VARCHAR(300),
--   LOAN_PARTNER_C                                      BOOLEAN,
--   REFERENCE_SHEET_C                                   VARCHAR(30000),
--   SPECIAL_PROGRAMS_C                                  VARCHAR(4099),
--   F_500_LIST_C                                        VARCHAR(765),
--   ERS_ENROLLMENT_DATE_C                               DATE,
--   MONITORING_COMMISSIONING_DATE_C                     DATE,
--   TOTAL_ENERGY_PRODUCED_C                             numeric,
--   TOTAL_ENERGY_USED_C                                 numeric,
--   CHANNEL_C                                           VARCHAR(765),
--   SECTOR_CASH_C                                       VARCHAR(4099),
--   SECTOR_LEASE_C                                      VARCHAR(4099),
--   SECTOR_LOAN_C                                       VARCHAR(4099),
--   VAT_NUMBER_C                                        VARCHAR(48),
--   ENGAGEMENT_PRIORITY_C                               VARCHAR(765),
--   PAIRED_DESIGN_EXISTS_C                              BOOLEAN,
--   PARTNER_LOGO_URL_C                                  VARCHAR(150),
--   SUB_REGION_C                                        VARCHAR(765),
--   I_SUPPLIER_C                                        BOOLEAN,
--   DESIGN_PROJECT_ID_C                                 VARCHAR(765),
--   DESIGN_TOOL_ORGANIZATION_ID_C                       VARCHAR(765),
--   SEGMENT_C                                           VARCHAR(765),
--   CUSTOMER_GROUP_C                                    VARCHAR(90),
--   SUB_CONTRACTOR_C                                    VARCHAR(765),
--   BACKGROUND_CHECK_C                                  BOOLEAN,
--   ENGAGIO_ENGAGED_PEOPLE_C                            numeric,
--   ENGAGIO_ENGAGEMENT_MINUTES_LAST_3_MONTHS_C          numeric,
--   ENGAGIO_ENGAGEMENT_MINUTES_LAST_7_DAYS_C            numeric,
--   ENGAGIO_FIRST_ENGAGEMENT_DATE_C                     TIMESTAMPTZ,
--   ENGAGIO_MQADATE_C                                   TIMESTAMPTZ,
--   ENGAGIO_STATUS_C                                    VARCHAR(120),
--   ENGAGIO_WEB_VISITS_LAST_3_MONTHS_C                  numeric,
--   GENABILITY_ACCOUNT_ID_C                             VARCHAR(765),
--   GOOGLE_PIN_ADJUSTED_C                               BOOLEAN,
--   NEW_PARTNER_AGREEMENT_2017_DATE_C                   DATE,
--   SINGED_NEW_PARTNER_AGREEMENT_2017_C                 BOOLEAN,
--   OPT_OUT_PREFERENCE_C                                VARCHAR(765),
--   SPWR_CASH_PARTNER_C                                 BOOLEAN,
--   SECTOR_SPWR_CASH_C                                  VARCHAR(4099),
--   COMMERCIAL_DEALER_TIER_C                            VARCHAR(765),
--   AES_SYSTEM_ID_C                                     VARCHAR(765),
--   PURGE_BY_C                                          VARCHAR(18),
--   PURGE_REASON_C                                      VARCHAR(765),
--   PURGE_RECORD_C                                      BOOLEAN,
--   LOYALTY_TIER_C                                      VARCHAR(765),
--   RETROFIT_TERRITORY_C                                VARCHAR(765),
--   CALL_ATTEMPT_C                                      numeric,
--   SCHEDULED_CALL_DATE_C                               DATE,
--   MY_SUN_POWER_FEATURES_C                             VARCHAR(4099),
--   FUSION_CUSTOMER_ID_C                                VARCHAR(45),
--   FUSION_CUSTOMER_PARTY_ID_C                          VARCHAR(45),
--   FUSION_VENDOR_ID_C                                  VARCHAR(384),
--   FUSION_VENDOR_SITE_ID_C                             VARCHAR(384),
--   CVAR_LEAD_FLOW_OPT_OUT_C                            BOOLEAN,
--   PARTNER_RECORD_TYPE_C                               VARCHAR(150),
--   PARTNER_STATUS_C                                    VARCHAR(765),
--   ALLOWED_FINANCE_TYPE_FOR_STORAGE_C                  VARCHAR(4099),
--   FINANCE_ACCOUNTING_CONTACT_PERSON_C                 VARCHAR(765),
--   PHONE_CALL_OTHER_THAN_LEAD_CONTACT_C                VARCHAR(4099),
--   PHONE_NUMBER_C                                      VARCHAR(120),
--   PHYSICAL_MEETING_VALIDATED_BY_SALES_C               BOOLEAN,
--   WEBSITE_VERIFIED_C                                  VARCHAR(765),
--   ORACLE_VENDOR_NAME_C                                VARCHAR(765),
--   DEALER_COUNTERSIGN_CONTACT_C                        VARCHAR(18),
--   REMOTE_HOME_SURVEY_ACTIVATION_DATE_C                DATE,
--   REMOTE_HOME_SURVEY_STATUS_C                         VARCHAR(765),
--   DEAL_CLOSE_STATUS_C                                 VARCHAR(765),
--   AHJNAME_C                                           VARCHAR(18),
--   APPOINTMENT_REMINDER_OPT_OUT_C                      BOOLEAN,
--   INVITATION_SENT_DATE_TIME_C                         TIMESTAMPTZ,
--   LENDER_OVERRIDE_C                                   VARCHAR(765),
--   LOAN_PAYMENT_CLASSIFICATION_C                       VARCHAR(765),
--   CONNECTED_SOLUTIONS_PARTICIPANT_C                   VARCHAR(765),
--   DEALER_HIC_C                                        BOOLEAN,
--   PPA_PARTNER_C                                       BOOLEAN,
--   SECTOR_PPA_C                                        VARCHAR(765),
--   SPD_ECEMAIL_C                                       VARCHAR(240),
--   ADVOCATE_C                                          VARCHAR(18),
--   FIELD_APPLICATIONS_ENGINEER_C                       VARCHAR(18),
--   RINGDNA_HAS_OPTED_OUT_OF_SMS_2_C                    BOOLEAN,
--   INSTALL_TRACKER_ACTIVATION_DATE_C                   TIMESTAMPTZ,
--   OC_C                                                VARCHAR(18),
--   PDM_C                                               VARCHAR(18),
--   RINGDNA_100_ACTIVE_C                                VARCHAR(765),
--   RINGDNA_100_CALL_ATTEMPTS_C                         numeric,
--   RINGDNA_100_CUSTOMER_PRIORITY_C                     VARCHAR(765),
--   RINGDNA_100_EMAIL_ATTEMPTS_C                        numeric,
--   RINGDNA_100_FIRST_INBOUND_CALL_C                    TIMESTAMPTZ,
--   RINGDNA_100_FIRST_OUTBOUND_CALL_C                   TIMESTAMPTZ,
--   RINGDNA_100_LAST_EMAIL_ATTEMPT_C                    TIMESTAMPTZ,
--   RINGDNA_100_LAST_INBOUND_CALL_C                     TIMESTAMPTZ,
--   RINGDNA_100_LAST_OUTBOUND_CALL_C                    TIMESTAMPTZ,
--   RINGDNA_100_NUMBEROF_LOCATIONS_C                    numeric,
--   RINGDNA_100_RESPONSE_TYPE_C                         VARCHAR(765),
--   RINGDNA_100_RING_DNA_CONTEXT_C                      BOOLEAN,
--   RINGDNA_100_SLAEXPIRATION_DATE_C                    DATE,
--   RINGDNA_100_SLASERIAL_NUMBER_C                      VARCHAR(30),
--   RINGDNA_100_SLA_C                                   VARCHAR(765),
--   RINGDNA_100_TIME_TO_FIRST_DIAL_MINUTES_C            numeric,
--   RINGDNA_100_TIME_TO_FIRST_RESPONSE_C                numeric,
--   RINGDNA_100_UPSELL_OPPORTUNITY_C                    VARCHAR(765),
--   MESSAGE_UNREAD_C                                    BOOLEAN,
--   EC_INTRO_SMS_SENT_C                                 BOOLEAN,
--   SERVICES_OFFERED_C                                  VARCHAR(4099),
--   DLL_CREDIT_C                                        BOOLEAN,
--   AGREEMENT_ALIGNED_C                                 BOOLEAN,
--   LAST_CHECK_DATE_C                                   DATE,
--   BEST_TIME_TO_CALL_PC                                VARCHAR(765),
--   INTEGRATION_ID_PC                                   VARCHAR(60),
--   IS_ENGINEER_PC                                      BOOLEAN,
--   MARKETING_OPT_IN_PC                                 BOOLEAN,
--   OVERRIDE_DUPLICATE_CHECK_PC                         BOOLEAN,
--   TERMINATED_PC                                       BOOLEAN,
--   SALES_COMMUNICATIONS_PC                             BOOLEAN,
--   COUNTRY_DOMAIN_PC                                   VARCHAR(765),
--   LMS_ROLE_PC                                         VARCHAR(765),
--   SUBSCRIPTION_PC                                     VARCHAR(4099),
--   PARTNER_PORTAL_USER_PC                              VARCHAR(18),
--   PROFILE_TEMP_PC                                     VARCHAR(765),
--   ROLE_TEMP_PC                                        VARCHAR(765),
--   HIRE_DATE_PC                                        DATE,
--   BULLETINS_OPT_OUT_PC                                BOOLEAN,
--   REFERRAL_PROGRAM_STATUS_PC                          VARCHAR(765),
--   PROMO_CODE_PC                                       VARCHAR(240),
--   AUTHORIZED_TO_ORDER_PC                              BOOLEAN,
--   CONTACT_METHOD_PC                                   VARCHAR(765),
--   DIRECT_MARKETING_OPT_OUT_PC                         BOOLEAN,
--   DO_NOT_CALL_OPT_OUT_PC                              BOOLEAN,
--   DO_NOT_MARKET_TO_BECAUSE_PC                         VARCHAR(765),
--   NEWSLETTER_OPT_OUT_PC                               BOOLEAN,
--   PHONE_DIRECT_PC                                     VARCHAR(120),
--   SEMINAR_EVENT_OPT_OUT_PC                            BOOLEAN,
--   CSAT_LAST_REPONSE_DATE_PC                           TIMESTAMPTZ,
--   CSAT_NPS_SCORE_PC                                   numeric,
--   CSAT_RANDOM_DISTRIBUTION_PC                         numeric,
--   FUSION_CONTACT_ID_PC                                VARCHAR(45),
--   CONTACT_LANGUAGE_PC                                 VARCHAR(765),
--   D_U_N_S_PC                                          VARCHAR(60),
--   PARTNER_PORTAL_REGISTRATION_PC                      BOOLEAN,
--   ORACLE_CONTACT_ID_PC                                VARCHAR(765),
--   FUNCTION_PC                                         VARCHAR(765),
--   MANAGEMENT_LEVEL_PC                                 VARCHAR(765),
--   ROLE_PC                                             VARCHAR(765),
--   ELOQUA_LEAD_SCORE_IMPLICIT_PC                       numeric,
--   ELOQUA_LEAD_SCORE_EXPLICIT_PC                       numeric,
--   ELOQUA_LEAD_RATING_COMBINED_PC                      VARCHAR(6),
--   REFERRER_PC                                         BOOLEAN,
--   REFERRER_ACCOUNT_PC                                 VARCHAR(18),
--   CPR_ID_PC                                           VARCHAR(60),
--   INCLUDE_IN_LEASE_DOC_PC                             BOOLEAN,
--   LEASE_DOC_CREATION_ALLOWED_PC                       BOOLEAN,
--   PRIMARY_PC                                          BOOLEAN,
--   IS_UPDATED_FROM_ACCOUNT_PC                          BOOLEAN,
--   SPWR_REFERENCE_PC                                   VARCHAR(765),
--   DATE_REFERENCE_LAST_UPDATED_PC                      DATE,
--   REFERENCE_SHEET_PC                                  VARCHAR(765),
--   REFERENCE_RATING_PC                                 VARCHAR(765),
--   ALLIANCE_CONTACT_PC                                 BOOLEAN,
--   LEASE_COURSE_STATUS_PC                              VARCHAR(4099),
--   CREDIT_CUSTOMER_ID_PC                               VARCHAR(108),
--   CREDIT_CUSTOMER_NUMBER_PC                           VARCHAR(108),
--   CONTACT_STATUS_PC                                   VARCHAR(765),
--   ISSUE_RESOLUTION_SURVEY_OPT_OUT_PC                  BOOLEAN,
--   BIRTH_COUNTRY_PC                                    VARCHAR(72),
--   INTERFACE_MESSAGE_PC                                VARCHAR(6000),
--   INTERFACE_STATUS_PC                                 VARCHAR(765),
--   MARITAL_STATUS_DEL_PC                               VARCHAR(765),
--   PROFESSION_PC                                       VARCHAR(72),
--   IS_OVER_21_YEARS_OF_AGE_PC                          BOOLEAN,
--   CUSTOMER_PORTAL_ACTIVATION_LINK_PC                  VARCHAR(765),
--   EMAIL_OPT_OUT_PC                                    BOOLEAN,
--   DO_NOT_SYNCH_TO_ELOQUA_PC                           BOOLEAN,
--   PHONE_US_PREFIX_PC                                  VARCHAR(120),
--   PHONE_UNFORMATTED_PC                                VARCHAR(75),
--   UTILITY_ACCOUNT_HOLDER_PC                           BOOLEAN,
--   DELEGATION_PC                                       VARCHAR(18),
--   MOBILE_US_PREFIX_PC                                 VARCHAR(120),
--   LEASE_TRANSFER_WK_PC                                BOOLEAN,
--   FUSION_CONTACT_PARTY_ID_PC                          VARCHAR(45),
--   E_INVOICE_VALID_RECIPIENT_PC                        BOOLEAN,
--   ELOQUA_CONTACT_ID_PC                                VARCHAR(765),
--   ORACLE_CONTACT_STATUS_PC                            VARCHAR(765),
--   PREFERRED_LANGUAGE_CODE_PC                          VARCHAR(765),
--   ENGAGIO_DEPARTMENT_PC                               VARCHAR(384),
--   ENGAGIO_ENGAGEMENT_MINUTES_LAST_3_MONTHS_PC         numeric,
--   ENGAGIO_ENGAGEMENT_MINUTES_LAST_7_DAYS_PC           numeric,
--   ENGAGIO_FIRST_ENGAGEMENT_DATE_PC                    TIMESTAMPTZ,
--   ENGAGIO_ROLE_PC                                     VARCHAR(384),
--   CAMPAIGN_PC                                         VARCHAR(18),
--   ISSUE_RESOLUTION_SURVEY_SENT_DATE_PC                DATE,
--   SATISFACTION_SURVEY_OPT_IN_PC                       BOOLEAN,
--   TEXT_MESSAGE_OPT_OUT_PC                             BOOLEAN,
--   ORACLE_UPDATE_PC                                    BOOLEAN,
--   CUSTOMER_PORTAL_ACTIVATION_LINK_LONG_PC             VARCHAR(98304),
--   AUTHORIZED_TO_PAY_PC                                BOOLEAN,
--   DO_NOT_SELL_MY_DATA_PC                              BOOLEAN,
--   SPD_ECEMAIL_PC                                      VARCHAR(240),
--   RINGDNA_HAS_OPTED_OUT_OF_SMS_PC                     BOOLEAN,
--   RINGDNA_100_CALL_ATTEMPTS_PC                        numeric,
--   RINGDNA_100_EMAIL_ATTEMPTS_PC                       numeric,
--   RINGDNA_100_FIRST_INBOUND_CALL_PC                   TIMESTAMPTZ,
--   RINGDNA_100_FIRST_INBOUND_MESSAGE_PC                TIMESTAMPTZ,
--   RINGDNA_100_FIRST_OUTBOUND_CALL_PC                  TIMESTAMPTZ,
--   RINGDNA_100_FIRST_OUTBOUND_MESSAGE_PC               TIMESTAMPTZ,
--   RINGDNA_100_LANGUAGES_PC                            VARCHAR(300),
--   RINGDNA_100_LAST_EMAIL_ATTEMPT_PC                   TIMESTAMPTZ,
--   RINGDNA_100_LAST_INBOUND_CALL_PC                    TIMESTAMPTZ,
--   RINGDNA_100_LAST_INBOUND_MESSAGE_PC                 TIMESTAMPTZ,
--   RINGDNA_100_LAST_OUTBOUND_CALL_PC                   TIMESTAMPTZ,
--   RINGDNA_100_LAST_OUTBOUND_MESSAGE_PC                TIMESTAMPTZ,
--   RINGDNA_100_LEVEL_PC                                VARCHAR(765),
--   RINGDNA_100_MESSAGE_ATTEMPTS_PC                     numeric,
--   RINGDNA_100_RESPONSE_TYPE_PC                        VARCHAR(765),
--   RINGDNA_100_RING_DNA_CONTEXT_PC                     BOOLEAN,
--   RINGDNA_100_TIME_TO_FIRST_DIAL_MINUTES_PC           numeric,
--   RINGDNA_100_TIME_TO_FIRST_RESPONSE_PC               numeric,
--   _FIVETRAN_SYNCED                                    TIMESTAMPTZ,
--   LAST_MODIFIED_BY_PC_C                               VARCHAR(765),
--   HOMEOWNER_PREFERRED_NAME_C                          VARCHAR(765),
--   RINGDNA_100_LATEST_DISPOSITION_PC                   VARCHAR(765),
--   LEGAL_BUSINESS_NAME_C                               VARCHAR(765),
--   _FIVETRAN_DELETED                                   BOOLEAN,
--   ACCOUNT_FLAG_COMMENT_C                              VARCHAR(30000),
--   ACCOUNT_FLAG_C                                      VARCHAR(4099),
--   OPERATING_HOURS_ID                                  VARCHAR(18),
--   CONSULTATION_CALENDAR_LINK_C                        VARCHAR(765),
--   SMS_MANAGER_PC                                      VARCHAR(18),
--   PLACEKEY_ID_C                                       VARCHAR(765),
--   AD_PROJECT_ID_C                                     VARCHAR(765),
--   ORTOO_QRA_Q_ASSIGN_LAST_ASSIGNED_DATE_C             TIMESTAMPTZ,
--   ORTOO_QRA_ASSIGNED_FROM_GROUP_PC                    VARCHAR(54),
--   ORTOO_QRA_ASSIGNED_FROM_QUEUE_C                     VARCHAR(54),
--   ORTOO_QRA_Q_ASSIGN_LAST_ASSIGNED_DATE_PC            TIMESTAMPTZ,
--   ORTOO_QRA_ASSIGNED_FROM_QUEUE_PC                    VARCHAR(54),
--   ORTOO_QRA_ASSIGNED_FROM_GROUP_C                     VARCHAR(54),
--   NET_SETTING_C                                       BOOLEAN,
--   EXTERNAL_INSTALLING_PARTNER_PHONE_C                 VARCHAR(120),
--   PARTNER_CUSTOMER_ID_C                               VARCHAR(150),
--   EXTERNAL_PARTNER_NAME_C                             VARCHAR(765),
--   EXTERNAL_INSTALLING_PARTNER_EMAIL_C                 VARCHAR(240),
--   PARTNER_SITE_ID_C                                   VARCHAR(150),
--   EXTERNAL_INSTALLING_PARTNER_NAME_C                  VARCHAR(450),
--   PARTNER_ORDER_ID_C                                  VARCHAR(150),
--   PARTNER_CONTACT_ID_PC                               VARCHAR(150),
--   TWILIO_SF_LAST_MESSAGE_STATUS_DATE_PC               TIMESTAMPTZ,
--   TWILIO_SF_LAST_MESSAGE_STATUS_PC                    VARCHAR(765),
--   FSL_VERIFICATION_CODE_PC                            VARCHAR(765),
--   ACTIVITY_METRIC_ID                                  VARCHAR(18),
--   ACTIVITY_METRIC_ROLLUP_ID                           VARCHAR(18),
--   SR_NUMBER_FOR_SSS_PC                                VARCHAR(765),
--   IS_PRIORITY_RECORD                                  BOOLEAN,
--   SEED_STOCK_RMA_PROGRAM_C                            BOOLEAN,
--   PRE_POSITIONED_INVENTORY_PROGRAM_C                  BOOLEAN,
--   SPRI_LOCATION_PC                                    VARCHAR(4099),
--   TECHNICAL_PROJECT_MANAGER_C                         VARCHAR(18),
--   ND_OPERATIONS_SPECIALIST_C                          VARCHAR(18),
--   CUSTOMER_ACCOUNT_MANAGER_C                          VARCHAR(18),
--   OPERATIONS_MANAGER_C                                VARCHAR(18),
--   INSTALLATION_PARTNER_MANAGER_C                      VARCHAR(18),
--   PERSON_HAS_OPTED_OUT_OF_FAX                         BOOLEAN,
--   RDNACADENCE_LANGUAGES_PC                            VARCHAR(300),
--   RDNACADENCE_IS_ACTIVATED_PC                         BOOLEAN,
--   RDNACADENCE_NUMBER_OF_SEQUENCE_EMAILS_TO_OPENED_PC  numeric,
--   RINGDNA_SLASERIAL_NUMBER_C                          VARCHAR(30),
--   RINGDNA_CUSTOMER_PRIORITY_C                         VARCHAR(765),
--   RDNACADENCE_NUMBER_OF_DEFERRED_SEQUENCE_ACTIONS_PC  numeric,
--   RDNACADENCE_REPLIED_TO_SEQUENCE_EMAIL_PC            BOOLEAN,
--   RDNACADENCE_NUMBER_OF_SEQUENCE_EMAILS_TO_REPLY_PC   numeric,
--   RDNACADENCE_CADENCE_ID_PC                           VARCHAR(18),
--   RDNACADENCE_PENDING_SEQUENCE_PC                     VARCHAR(18),
--   RINGDNA_SLA_C                                       VARCHAR(765),
--   RDNACADENCE_PRIORITY_PC                             numeric,
--   RDNACADENCE_NUMBER_OF_SEQUENCE_EMAILS_SENT_PC       numeric,
--   RDNACADENCE_NUMBER_OF_PERFORMED_SEQUENCE_ACTIONS_PC numeric,
--   RDNACADENCE_ENTRANCE_CRITERIA_MATCHED_DATE_PC       TIMESTAMPTZ,
--   RINGDNA_ACTIVE_C                                    VARCHAR(765),
--   RINGDNA_UPSELL_OPPORTUNITY_C                        VARCHAR(765),
--   RDNACADENCE_CADENCE_PERFORMED_PC                    BOOLEAN,
--   RINGDNA_SLAEXPIRATION_DATE_C                        DATE,
--   LMS_JOB_ID_PC                                       VARCHAR(4099),
--   RINGDNA_NUMBEROF_LOCATIONS_C                        numeric,
--   RDNACADENCE_OPPORTUNITY_ID_PC                       VARCHAR(60),
--   RDNACADENCE_OPENED_SEQUENCE_EMAIL_PC                BOOLEAN,
--   RDNACADENCE_DRIP_SEQUENCE_PENDING_PC                BOOLEAN
-- );
--
-- drop table if exists brs.ahj_utility_c;
-- create table if not exists brs.AHJ_UTILITY_C
-- (
--   ID                                     VARCHAR(18),
--   OWNER_ID                               VARCHAR(18),
--   IS_DELETED                             BOOLEAN,
--   NAME                                   VARCHAR(240),
--   CURRENCY_ISO_CODE                      VARCHAR(9),
--   CREATED_DATE                           TIMESTAMPTZ,
--   CREATED_BY_ID                          VARCHAR(18),
--   LAST_MODIFIED_DATE                     TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                    VARCHAR(18),
--   SYSTEM_MODSTAMP                        TIMESTAMPTZ,
--   LAST_VIEWED_DATE                       TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                   TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID                 VARCHAR(18),
--   CONNECTION_SENT_ID                     VARCHAR(18),
--   AC_DISCONNECT_REQUIRED_C               BOOLEAN,
--   AC_DISCONNECT_REQUIREMENT_NOTES_C      VARCHAR(98304),
--   AHJ_UTILITY_ID_C                       VARCHAR(240),
--   ADDITIONAL_UTILITY_NOTES_C             VARCHAR(98304),
--   LAYOUT_REQUIRED_C                      BOOLEAN,
--   LINE_DIAGRAM_REQUIRED_C                BOOLEAN,
--   OVERSIZING_ALLOWANCE_AND_REQUIREMENT_C VARCHAR(98304),
--   PROD_METER_REQUIRED_C                  VARCHAR(765),
--   PRODUCTION_METER_NOTES_C               VARCHAR(98304),
--   TURN_AROUND_TIME_C                     numeric,
--   UTILITY_PLACE_CARD_REQUIREMENT_C       VARCHAR(98304),
--   STATE_C                                VARCHAR(765),
--   ACTIVATION_TRACKER_ENABLED_C           BOOLEAN,
--   _FIVETRAN_DELETED                      BOOLEAN,
--   _FIVETRAN_SYNCED                       TIMESTAMPTZ,
--   UTILITY_PRE_COMM_NOTES_C               VARCHAR(98304),
--   PERMIT_COLLECTION_URL_C                VARCHAR(765),
--   UTILITY_POC_C                          VARCHAR(765),
--   ADDITIONAL_DOCUMENTS_C                 VARCHAR(765),
--   APPLICATION_PORTAL_URL_C               VARCHAR(765),
--   GBFS_HANDOFF_C                         BOOLEAN,
--   FINAL_PERMIT_REQUIREMENTS_C            VARCHAR(765),
--   ESS_URL_C                              VARCHAR(765),
--   GBFS_PROCESS_LINK_C                    BOOLEAN,
--   SIZE_RESTRICTIONS_C                    VARCHAR(765),
--   INSURANCE_COPY_REQUIRED_C              BOOLEAN,
--   IC_REQUIREMENTS_DOCUMENTED_C           BOOLEAN,
--   INTERCONNECT_FEES_C                    numeric(17, 2),
--   LAST_UTILITY_PROCESS_REVIEW_C          DATE,
--   PTO_TIMELINE_C                         VARCHAR(765),
--   PRE_APPROVAL_PROCESS_C                 VARCHAR(765),
--   UTILITY_URL_C                          VARCHAR(765),
--   PAYMENT_TYPE_C                         VARCHAR(765),
--   ADDITIONAL_PERMIT_IC_NOTES_C           VARCHAR(765),
--   DESIGN_FOLDER_C                        VARCHAR(765),
--   ESS_REQUIREMENTS_C                     VARCHAR(765),
--   PANEL_INVERTER_SPEC_SHEET_REQUIRED_C   BOOLEAN,
--   BUILDER_SIGNATURE_REQUIRED_C           BOOLEAN,
--   ESS_REQUIREMENTS_DOCUMENTED_C          VARCHAR(765),
--   FINAL_PERMIT_COLLECTION_C              VARCHAR(765),
--   PRE_APPROVAL_REQUIRED_C                BOOLEAN,
--   AC_DISCO_SPEC_SHEET_REQUIRED_C         BOOLEAN,
--   SUBMITTAL_C                            VARCHAR(765),
--   BUYER_VS_BUILDER_SUBMITTALS_C          VARCHAR(765),
--   SIDE_ELEVATION_REQUIRED_C              BOOLEAN
-- );
--
--
-- drop table if exists brs.ALLIANCE_PARTNER_C;
-- create table if not exists brs.ALLIANCE_PARTNER_C
-- (
--   ID                            VARCHAR(18),
--   OWNER_ID                      VARCHAR(18),
--   IS_DELETED                    BOOLEAN,
--   NAME                          VARCHAR(240),
--   CURRENCY_ISO_CODE             VARCHAR(9),
--   RECORD_TYPE_ID                VARCHAR(18),
--   CREATED_DATE                  TIMESTAMPTZ,
--   CREATED_BY_ID                 VARCHAR(18),
--   LAST_MODIFIED_DATE            TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID           VARCHAR(18),
--   SYSTEM_MODSTAMP               TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID        VARCHAR(18),
--   CONNECTION_SENT_ID            VARCHAR(18),
--   RESIDENTIAL_PROJECT_C         VARCHAR(18),
--   PARTNER_ACCOUNT_C             VARCHAR(18),
--   ROLE_C                        VARCHAR(765),
--   COMMUNITY_C                   VARCHAR(18),
--   UPDATE_RPON_ICD_C             BOOLEAN,
--   LOAN_PAYMENT_CLASSIFICATION_C VARCHAR(150),
--   _FIVETRAN_SYNCED              TIMESTAMPTZ,
--   _FIVETRAN_DELETED             BOOLEAN,
--   CUSTOMER_ACCOUNT_C            VARCHAR(18)
-- );
--
--
-- drop table if exists brs.BUILDER_PRICING_C;
-- create table if not exists brs.BUILDER_PRICING_C
-- (
--   ID                            VARCHAR(18),
--   OWNER_ID                      VARCHAR(18),
--   IS_DELETED                    BOOLEAN,
--   NAME                          VARCHAR(240),
--   CURRENCY_ISO_CODE             VARCHAR(9),
--   CREATED_DATE                  TIMESTAMPTZ,
--   CREATED_BY_ID                 VARCHAR(18),
--   LAST_MODIFIED_DATE            TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID           VARCHAR(18),
--   SYSTEM_MODSTAMP               TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID        VARCHAR(18),
--   CONNECTION_SENT_ID            VARCHAR(18),
--   COMMUNITY_C                   VARCHAR(18),
--   LEASE_INCENTIVE_FEE_C         numeric(9, 2),
--   NET_CONTRACTED_PRICE_C        numeric(9, 2),
--   NOTES_C                       VARCHAR(765),
--   SYSTEM_WATTAGE_DC_C           numeric,
--   ACTIVE_C                      BOOLEAN,
--   WRAP_INSURANCE_PERCENT_C      numeric,
--   CASH_INCENTIVE_FEE_C          numeric(9, 2),
--   _FIVETRAN_SYNCED              TIMESTAMPTZ,
--   _FIVETRAN_DELETED             BOOLEAN,
--   CODE_YEAR_C                   VARCHAR(765),
--   STORAGE_SIZE_C                VARCHAR(765),
--   STORAGE_PRICE_C               numeric(18, 2),
--   NEM_3_0_LEASE_INCENTIVES_C    numeric(9, 2),
--   STORAGE_CONFIGURATION_GROUP_C VARCHAR(18)
-- );
--
--
--
-- drop table if exists brs.CAMPAIGN;
-- create table if not exists brs.CAMPAIGN
-- (
--   ID                                         VARCHAR(18),
--   IS_DELETED                                 BOOLEAN,
--   NAME                                       VARCHAR(240),
--   PARENT_ID                                  VARCHAR(18),
--   TYPE                                       VARCHAR(765),
--   RECORD_TYPE_ID                             VARCHAR(18),
--   STATUS                                     VARCHAR(765),
--   START_DATE                                 DATE,
--   END_DATE                                   DATE,
--   CURRENCY_ISO_CODE                          VARCHAR(9),
--   EXPECTED_REVENUE                           numeric(18),
--   BUDGETED_COST                              numeric(18),
--   ACTUAL_COST                                numeric(18),
--   EXPECTED_RESPONSE                          numeric,
--   NUMBER_SENT                                numeric,
--   IS_ACTIVE                                  BOOLEAN,
--   DESCRIPTION                                VARCHAR(96000),
--   CAMPAIGN_IMAGE_ID                          VARCHAR(18),
--   NUMBER_OF_LEADS                            numeric,
--   NUMBER_OF_CONVERTED_LEADS                  numeric,
--   NUMBER_OF_CONTACTS                         numeric,
--   NUMBER_OF_RESPONSES                        numeric,
--   NUMBER_OF_OPPORTUNITIES                    numeric,
--   NUMBER_OF_WON_OPPORTUNITIES                numeric,
--   AMOUNT_ALL_OPPORTUNITIES                   numeric(18),
--   AMOUNT_WON_OPPORTUNITIES                   numeric(18),
--   HIERARCHY_NUMBER_OF_LEADS                  numeric,
--   HIERARCHY_NUMBER_OF_CONVERTED_LEADS        numeric,
--   HIERARCHY_NUMBER_OF_CONTACTS               numeric,
--   HIERARCHY_NUMBER_OF_RESPONSES              numeric,
--   HIERARCHY_NUMBER_OF_OPPORTUNITIES          numeric,
--   HIERARCHY_NUMBER_OF_WON_OPPORTUNITIES      numeric,
--   HIERARCHY_AMOUNT_ALL_OPPORTUNITIES         numeric(18),
--   HIERARCHY_AMOUNT_WON_OPPORTUNITIES         numeric(18),
--   HIERARCHY_NUMBER_SENT                      numeric,
--   HIERARCHY_EXPECTED_REVENUE                 numeric(18),
--   HIERARCHY_BUDGETED_COST                    numeric(18),
--   HIERARCHY_ACTUAL_COST                      numeric(18),
--   OWNER_ID                                   VARCHAR(18),
--   CREATED_DATE                               TIMESTAMPTZ,
--   CREATED_BY_ID                              VARCHAR(18),
--   LAST_MODIFIED_DATE                         TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                        VARCHAR(18),
--   SYSTEM_MODSTAMP                            TIMESTAMPTZ,
--   LAST_ACTIVITY_DATE                         DATE,
--   LAST_VIEWED_DATE                           TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                       TIMESTAMPTZ,
--   CAMPAIGN_MEMBER_RECORD_TYPE_ID             VARCHAR(18),
--   BUSINESS_UNIT_C                            VARCHAR(765),
--   CAMPAIGN_GOAL_C                            VARCHAR(765),
--   CAMPAIGN_ID_C                              VARCHAR(765),
--   CAMPAIGN_TARGET_AUDIENCE_C                 VARCHAR(96000),
--   EXPECTED_LEADS_C                           numeric,
--   EXPECTED_LEADS_PERCENTAGE_C                numeric,
--   EXPECTED_OPPORTUNITY_PERCENTAGE_C          numeric,
--   INDUSTRY_VERTICAL_C                        VARCHAR(765),
--   LIST_DESCRIPTION_C                         VARCHAR(96000),
--   PROMO_CODE_C                               VARCHAR(240),
--   INTEGRATION_ID_C                           VARCHAR(60),
--   RLC_TYPE_C                                 VARCHAR(765),
--   LEAD_HANDLING_FEE_C                        numeric,
--   LEAD_GENERATION_FEE_C                      numeric,
--   SUB_OFFICE_LOCATIONS_C                     VARCHAR(4099),
--   STAGE_C                                    VARCHAR(765),
--   PROBABILITY_C                              VARCHAR(765),
--   REFERRED_BY_C                              VARCHAR(765),
--   OFFICE_LOCATION_C                          VARCHAR(4099),
--   WEB_SITE_C                                 VARCHAR(765),
--   CONTACT_TITLE_C                            VARCHAR(150),
--   TIER_C                                     VARCHAR(765),
--   SME_C                                      VARCHAR(18),
--   LAUNCH_DATE_C                              DATE,
--   THEATER_C                                  VARCHAR(765),
--   STATUS_UPDATE_C                            VARCHAR(15000),
--   TOTAL_NO_LEADS_C                           numeric,
--   REBATE_FORM_URL_C                          VARCHAR(765),
--   ELOQUA_FORM_NAME_C                         VARCHAR(765),
--   SLA_TYPE_C                                 VARCHAR(765),
--   SHORT_DESCRIPTION_C                        VARCHAR(765),
--   REQUIRES_LEAD_PRE_QUALIFICATION_C          BOOLEAN,
--   PUBLISH_C                                  BOOLEAN,
--   RETAILER_C                                 VARCHAR(765),
--   IS_EXCLUSIVE_C                             BOOLEAN,
--   SALES_STATUS_C                             VARCHAR(765),
--   ASSIGN_TO_TCPA_DIALER_C                    BOOLEAN,
--   REBATE_CODE_C                              VARCHAR(240),
--   TFN_C                                      VARCHAR(120),
--   RINGDNA_100_CALL_ATTEMPTS_C                numeric,
--   RINGDNA_100_EMAIL_ATTEMPTS_C               numeric,
--   RINGDNA_100_FIRST_INBOUND_CALL_C           TIMESTAMPTZ,
--   RINGDNA_100_FIRST_OUTBOUND_CALL_C          TIMESTAMPTZ,
--   RINGDNA_100_LAST_EMAIL_ATTEMPT_C           TIMESTAMPTZ,
--   RINGDNA_100_LAST_INBOUND_CALL_C            TIMESTAMPTZ,
--   RINGDNA_100_LAST_OUTBOUND_CALL_C           TIMESTAMPTZ,
--   RINGDNA_100_RESPONSE_TYPE_C                VARCHAR(765),
--   RINGDNA_100_RING_DNA_CONTEXT_C             BOOLEAN,
--   RINGDNA_100_TIME_TO_FIRST_DIAL_MINUTES_C   numeric,
--   RINGDNA_100_TIME_TO_FIRST_RESPONSE_C       numeric,
--   _FIVETRAN_SYNCED                           TIMESTAMPTZ,
--   _FIVETRAN_DELETED                          BOOLEAN,
--   HQ_PRIMARY_ADDRESS_C                       VARCHAR(297),
--   NH_COMMUNITY_C                             VARCHAR(18),
--   I_PLOT_REQUIRED_C                          BOOLEAN,
--   SPECIAL_OFFER_C                            BOOLEAN,
--   ALLIANCE_OFFER_C                           VARCHAR(7500),
--   ACCOUNT_C                                  VARCHAR(18),
--   ACTIVE_MY_SUN_POWER_REFERRAL_CAMPAIGN_C    BOOLEAN,
--   CHECK_AGAINST_DNC_LIST_C                   BOOLEAN,
--   LAST_COMMUNITY_VISIT_C                     VARCHAR(765),
--   SOLAR_CUT_OFF_C                            VARCHAR(765),
--   CHANNELS_C                                 VARCHAR(4099),
--   ASSIGN_RANDOM_PARTNER_C                    BOOLEAN,
--   SERVICE_AGREEMENT_SIGNED_C                 DATE,
--   CONTACT_CELL_PHONE_C                       VARCHAR(75),
--   FIVE_9_FIVE_9_LIST_C                       VARCHAR(150),
--   COLLATERAL_FLYERS_REBATE_FORMS_ETC_C       DATE,
--   HQ_PRIMARY_ADDRESS_2_C                     VARCHAR(297),
--   ALLIANCE_NOTES_C                           VARCHAR(98304),
--   MEETING_PROGRAM_OVERVIEW_CONDUCTED_C       DATE,
--   CONTACT_FIRST_NAME_C                       VARCHAR(297),
--   FIVE_9_FIVE_9_USER_C                       VARCHAR(150),
--   FIVE_9_FIVE_9_REPORT_EMAIL_C               VARCHAR(240),
--   GROUP_NAME_C                               VARCHAR(297),
--   REWARD_AMOUNT_C                            numeric(18, 2),
--   LANDING_PAGE_LIVE_C                        DATE,
--   OF_EMPLOYEES_MEMBERS_TOTAL_C               VARCHAR(297),
--   FIVE_9_FIVE_9_PASSWORD_C                   VARCHAR(150),
--   PROGRAM_TYPE_C                             VARCHAR(4099),
--   CONTACT_FAX_C                              VARCHAR(45),
--   SERVICE_AGREEMENT_PROVIDED_C               DATE,
--   CAMPAIGN_LANDING_PAGE_C                    VARCHAR(765),
--   PROGRAM_COMMUNICATED_TO_EMPLOYEE_MEMBERS_C DATE,
--   FIVE_9_FIVE_9_CALL_NOW_C                   BOOLEAN,
--   SKIP_LEAD_ASSIGNMENT_C                     BOOLEAN,
--   FIVE_9_FIVE_9_ENDPOINT_C                   VARCHAR(765),
--   CONTACT_LAST_NAME_C                        VARCHAR(297),
--   HQ_PRIMARY_CITY_C                          VARCHAR(297),
--   CONTACT_EMAIL_C                            VARCHAR(297),
--   HQ_PRIMARY_STATE_C                         VARCHAR(765),
--   HQ_COUNTRY_C                               VARCHAR(765),
--   ATTENDED_BY_C                              VARCHAR(765),
--   CONTACT_OFFICE_PHONE_C                     VARCHAR(297),
--   HQ_PRIMARY_ZIP_CODE_C                      VARCHAR(30),
--   TWILIO_SF_DELIVERABLE_C                    numeric,
--   TWILIO_SF_UNDELIVERED_C                    numeric,
--   TWILIO_SF_NO_MOBILE_C                      numeric,
--   TWILIO_SF_OPT_IN_KEYWORD_C                 VARCHAR(18),
--   TWILIO_SF_NOT_OPTED_IN_C                   numeric,
--   TWILIO_SF_DELIVERABILITY_STATUS_C          VARCHAR(765),
--   TWILIO_SF_TOTAL_DELIVERABILITY_COUNT_C     numeric,
--   TWILIO_SF_FAILED_C                         numeric,
--   TWILIO_SF_UNKNOWN_C                        numeric,
--   TWILIO_SF_BLOCKED_C                        numeric
-- );
--
--
-- drop table if exists brs.NH_COMMUNITY_C;
-- create table if not exists brs.NH_COMMUNITY_C
-- (
--   ID                                         VARCHAR(18),
--   OWNER_ID                                   VARCHAR(18),
--   IS_DELETED                                 BOOLEAN,
--   NAME                                       VARCHAR(240),
--   CURRENCY_ISO_CODE                          VARCHAR(9),
--   CREATED_DATE                               TIMESTAMPTZ,
--   CREATED_BY_ID                              VARCHAR(18),
--   LAST_MODIFIED_DATE                         TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                        VARCHAR(18),
--   SYSTEM_MODSTAMP                            TIMESTAMPTZ,
--   LAST_VIEWED_DATE                           TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                       TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID                     VARCHAR(18),
--   CONNECTION_SENT_ID                         VARCHAR(18),
--   BUILDER_NAME_C                             VARCHAR(765),
--   COMMUNITY_NAME_C                           VARCHAR(765),
--   INSTALLER_C                                VARCHAR(18),
--   REGION_C                                   VARCHAR(765),
--   COMMUNITY_NAME_TEXT_C                      VARCHAR(150),
--   FINANCIAL_OFFERING_C                       VARCHAR(4099),
--   PRIMARY_ENERGY_CONSULTANT_C                VARCHAR(18),
--   SOLAR_ADD_ON_C                             VARCHAR(765),
--   AHJ_C                                      VARCHAR(300),
--   ACCOUNT_MANAGER_C                          VARCHAR(18),
--   BASE_SQUARE_FOOTAGE_N_C                    numeric,
--   BUILDER_PREFERRED_ROOFER_C                 VARCHAR(765),
--   BUILDER_C                                  VARCHAR(18),
--   BUILDING_TYPE_C                            VARCHAR(765),
--   BUSINESS_UNIT_C                            VARCHAR(765),
--   CAL_CERTS_READY_C                          VARCHAR(765),
--   CASH_PV_MODULE_QTY_C                       VARCHAR(120),
--   CITY_LOCATION_C                            VARCHAR(180),
--   CLIMATE_ZONE_C                             VARCHAR(150),
--   COMMUNITY_ADDER_C                          VARCHAR(4099),
--   COMMUNITY_ID_C                             VARCHAR(90),
--   COMMUNITY_STATUS_C                         VARCHAR(765),
--   COMMUNITY_SUPERINTENDENT_EMAIL_C           VARCHAR(240),
--   COMMUNITY_SUPERINTENDENT_NAME_C            VARCHAR(150),
--   COMMUNITY_SUPERINTENDENT_PHONE_NUMBER_C    VARCHAR(120),
--   COMMUNITY_TYPE_C                           VARCHAR(765),
--   DISTRIBUTION_TYPE_C                        VARCHAR(765),
--   EE_PLAN_CHECK_TYPE_C                       VARCHAR(765),
--   EXPECTED_COMMUNITY_CONSTRUCTION_START_C    DATE,
--   INSPECTION_CONTRACT_TYPE_C                 VARCHAR(765),
--   INVERTER_TYPE_C                            VARCHAR(765),
--   IPLOT_DESIGN_NOTES_C                       VARCHAR(765),
--   MASTER_DEVELOPMENT_PERMITTING_NAME_C       VARCHAR(180),
--   MOUNTING_TYPE_C                            VARCHAR(765),
--   NUMBER_OF_HOMES_RESERVED_C                 numeric,
--   NUMBER_OF_HOMES_IN_COMMUNITY_C             numeric,
--   PV_HERS_PROVIDER_C                         VARCHAR(765),
--   PV_MODULE_MODEL_C                          VARCHAR(765),
--   PANEL_ORIENTATION_C                        VARCHAR(765),
--   PERMIT_PACK_TYPE_C                         VARCHAR(765),
--   PERMITTING_NOTES_C                         VARCHAR(98304),
--   PRE_PLUMB_C                                VARCHAR(765),
--   REBATE_PAYABLE_TO_C                        VARCHAR(765),
--   REBATE_PROGRAM_C                           VARCHAR(765),
--   REBATE_RESERVATION_CONFIRMATION_NUMBER_C   VARCHAR(765),
--   REBATE_RESERVATION_EXPIRY_DATE_C           DATE,
--   REBATE_RESERVATION_TYPE_C                  VARCHAR(765),
--   REGISTRY_NOTES_C                           VARCHAR(765),
--   RESERVATION_AMOUNT_PER_PROJECT_C           numeric(18, 2),
--   RESERVATION_NOTES_C                        VARCHAR(765),
--   RESERVED_INCENTIVE_LEVEL_C                 VARCHAR(75),
--   RESERVED_KW_C                              numeric,
--   ROUGH_WIRE_C                               VARCHAR(765),
--   SPWR_HERS_RATER_NAME_C                     VARCHAR(90),
--   T_24_CODE_RESERVED_C                       VARCHAR(75),
--   TIER_LEVEL_C                               VARCHAR(765),
--   TRACKING_NUMBER_C                          VARCHAR(150),
--   TRACT_NUMBER_C                             VARCHAR(180),
--   TYPE_OF_RELEASE_C                          VARCHAR(765),
--   UTILITY_C                                  VARCHAR(180),
--   ZIP_CODE_C                                 VARCHAR(15),
--   BUILDER_DELIVERY_INFO_C                    VARCHAR(765),
--   BUILDER_HERS_RATER_C                       VARCHAR(150),
--   SHEET_SIZE_C                               VARCHAR(765),
--   STATE_C                                    VARCHAR(150),
--   TOTAL_NUMBER_OF_SETS_C                     numeric,
--   MASTER_PERMIT_C                            VARCHAR(45),
--   MONITORING_INCLUDED_C                      VARCHAR(765),
--   BUILDER_ARCHITECT_C                        VARCHAR(18),
--   WEEKS_PRIOR_TO_ROUGH_INSTALL_FOR_CUT_OFF_C VARCHAR(765),
--   MODULE_CONFIGURATION_C                     VARCHAR(18),
--   ROOF_ATTACHMENT_C                          VARCHAR(4099),
--   BUILDER_CIVIL_ENGINEER_C                   VARCHAR(18),
--   BUILDER_PROJECT_MANAGER_C                  VARCHAR(18),
--   BUILDER_PURCHASING_CONTACT_C               VARCHAR(18),
--   BUILDER_SPECIFIC_REQUIREMENTS_C            VARCHAR(98304),
--   PERMITTING_RESPONSIBILITY_C                VARCHAR(765),
--   UTILITY_CONSIDERATIONS_C                   VARCHAR(98304),
--   MULTI_FAMILY_ARRAY_C                       VARCHAR(765),
--   MULTI_FAMILY_INTERCONNECTION_C             VARCHAR(765),
--   MULTI_FAMILY_STEEP_ROOF_C                  BOOLEAN,
--   MODEL_DISCOUNT_C                           VARCHAR(765),
--   COMPETITOR_C                               VARCHAR(765),
--   GRAND_OPENING_DATE_C                       DATE,
--   PROBABILITY_C                              VARCHAR(765),
--   REASON_WON_LOST_C                          VARCHAR(765),
--   STAGE_C                                    VARCHAR(765),
--   ADDRESS_LIST_INFO_COMPLETE_C               BOOLEAN,
--   ADDRESS_LIST_C                             VARCHAR(765),
--   ARCHITECTURE_FILES_INFO_COMPLETE_C         BOOLEAN,
--   ARCHITECTURE_FILES_C                       VARCHAR(765),
--   CAMPAIGN_C                                 VARCHAR(18),
--   DOCUMENT_NOTES_C                           VARCHAR(765),
--   SEQUENCE_SHEET_INFO_COMPLETE_C             BOOLEAN,
--   SEQUENCE_SHEET_C                           VARCHAR(765),
--   SITE_PLAN_INFO_COMPLETE_C                  BOOLEAN,
--   SITE_PLAN_C                                VARCHAR(765),
--   BUILDER_PERMITTING_COMPLETE_C              BOOLEAN,
--   PERMIT_AHJ_FEES_C                          numeric(18, 2),
--   PERMIT_EXECUTION_FEES_C                    numeric(18, 2),
--   BUILDER_FILE_VALIDATION_C                  VARCHAR(765),
--   ARCHITECTURE_FILES_TEXT_C                  VARCHAR(765),
--   LAT_LONG_LATITUDE_S                        numeric,
--   LAT_LONG_LONGITUDE_S                       numeric,
--   STORAGE_ALLOWED_C                          BOOLEAN,
--   BUILDER_INITIAL_SUBMITTER_C                DATE,
--   LEASE_TERM_C                               VARCHAR(765),
--   MY_SUN_POWER_C                             BOOLEAN,
--   AHJNAME_C                                  VARCHAR(18),
--   FIELD_MANAGER_C                            VARCHAR(18),
--   LEASE_ESCALATOR_C                          VARCHAR(765),
--   SR_BUILDER_OPERATION_MANAGER_C             VARCHAR(18),
--   ACTIVATION_COORDINATOR_C                   VARCHAR(765),
--   STRUCTURAL_OPTIONS_ENHANCEMENTS_C          VARCHAR(765),
--   BULK_RP_CREATION_C                         BOOLEAN,
--   STAGE_MODIFIED_DATE_C                      DATE,
--   CUSTOM_ADDER_DESCRIPTION_C                 VARCHAR(765),
--   CUSTOM_COMMUNITY_ADDER_C                   numeric(18, 2),
--   ESS_PERMIT_PACK_TYPE_C                     VARCHAR(765),
--   ESS_PERMITTING_RESPONSIBILITY_C            VARCHAR(765),
--   HOME_ENERGY_SOURCE_C                       VARCHAR(765),
--   OWNERSHIP_TYPE_C                           VARCHAR(765),
--   BUILDER_UTILITY_REP_C                      VARCHAR(18),
--   EVSE_OFFERING_C                            VARCHAR(765),
--   PREVAILING_WAGE_DETAILS_C                  VARCHAR(765),
--   PREVAILING_WAGE_C                          BOOLEAN,
--   PROPOSAL_LINK_C                            VARCHAR(98304),
--   UTILITY_RELATIONSHIP_C                     VARCHAR(18),
--   AHJ_UTILITY_C                              VARCHAR(18),
--   _FIVETRAN_SYNCED                           TIMESTAMPTZ,
--   PHASE_CUTOVER_C                            VARCHAR(765),
--   TRANSITION_NOTES_C                         VARCHAR(98304),
--   SSP_REQUIRED_C                             VARCHAR(765),
--   _FIVETRAN_DELETED                          BOOLEAN,
--   DISTANCE_ADDER_C                           BOOLEAN,
--   ELECTRICAL_DIAGRAM_C                       BOOLEAN,
--   STORAGE_TYPE_C                             VARCHAR(765),
--   INSTALLATION_TYPE_C                        VARCHAR(765),
--   RIGHT_SIZED_C                              BOOLEAN,
--   ROOF_TYPE_C                                VARCHAR(765),
--   SR_COMMUNITY_ACCOUNT_MANAGER_C             VARCHAR(765),
--   STORAGE_C                                  VARCHAR(765),
--   STORAGE_BACKUP_TYPE_C                      VARCHAR(765),
--   CUSTOM_PRICING_NOTES_C                     VARCHAR(393216),
--   LOAD_APPLICATION_C                         VARCHAR(765),
--   LOAD_APPLICATION_RECEIVED_C                BOOLEAN,
--   PREFERRED_PV_PARTNER_C                     VARCHAR(765),
--   PREFERRED_STORAGE_PARTNER_C                VARCHAR(765),
--   COMMUNITY_DOCUMENTS_FOLDER_C               VARCHAR(765),
--   FLAT_LEASE_COMMUNITY_C                     BOOLEAN
-- );
--
--
--
-- drop table if exists brs.NH_COMMUNITY_VISIT_C;
-- create table if not exists brs.NH_COMMUNITY_VISIT_C
-- (
--   ID                     VARCHAR(18),
--   IS_DELETED             BOOLEAN,
--   NAME                   VARCHAR(240),
--   CURRENCY_ISO_CODE      VARCHAR(9),
--   CREATED_DATE           TIMESTAMPTZ,
--   CREATED_BY_ID          VARCHAR(18),
--   LAST_MODIFIED_DATE     TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID    VARCHAR(18),
--   SYSTEM_MODSTAMP        TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID VARCHAR(18),
--   CONNECTION_SENT_ID     VARCHAR(18),
--   NH_COMMUNITY_C         VARCHAR(18),
--   RECENT_VISIT_DATE_C    DATE,
--   ROLE_C                 VARCHAR(765),
--   VISIT_NOTES_C          VARCHAR(98304),
--   _FIVETRAN_DELETED      BOOLEAN,
--   _FIVETRAN_SYNCED       TIMESTAMPTZ
-- );
--
--
--
-- drop table if exists brs.NH_CONTRACTS_C;
-- create table if not exists brs.NH_CONTRACTS_C
-- (
--   ID                     VARCHAR(18),
--   OWNER_ID               VARCHAR(18),
--   IS_DELETED             BOOLEAN,
--   NAME                   VARCHAR(240),
--   CURRENCY_ISO_CODE      VARCHAR(9),
--   CREATED_DATE           TIMESTAMPTZ,
--   CREATED_BY_ID          VARCHAR(18),
--   LAST_MODIFIED_DATE     TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID    VARCHAR(18),
--   SYSTEM_MODSTAMP        TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID VARCHAR(18),
--   CONNECTION_SENT_ID     VARCHAR(18),
--   ATTACHMENT_ID_C        VARCHAR(54),
--   ATTACHMENT_TITLE_C     VARCHAR(765),
--   DOCUMENT_TYPE_C        VARCHAR(765),
--   NH_COMMUNITY_C         VARCHAR(18),
--   URL_TRACKABLE_C        VARCHAR(765),
--   _FIVETRAN_DELETED      BOOLEAN,
--   _FIVETRAN_SYNCED       TIMESTAMPTZ
-- );
--
--
-- drop table if exists brs.PLAN_TYPE_C;
-- create table if not exists brs.PLAN_TYPE_C
-- (
--   ID                            VARCHAR(18),
--   IS_DELETED                    BOOLEAN,
--   NAME                          VARCHAR(240),
--   CURRENCY_ISO_CODE             VARCHAR(9),
--   CREATED_DATE                  TIMESTAMPTZ,
--   CREATED_BY_ID                 VARCHAR(18),
--   LAST_MODIFIED_DATE            TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID           VARCHAR(18),
--   SYSTEM_MODSTAMP               TIMESTAMPTZ,
--   LAST_VIEWED_DATE              TIMESTAMPTZ,
--   LAST_REFERENCED_DATE          TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID        VARCHAR(18),
--   CONNECTION_SENT_ID            VARCHAR(18),
--   COMMUNITY_C                   VARCHAR(18),
--   BASE_SQUARE_FOOTAGE_C         numeric,
--   MODULES_C                     numeric,
--   CODE_LEVEL_C                  VARCHAR(765),
--   CFI_C                         VARCHAR(765),
--   MIN_SYSTEM_SIZE_WATTS_C       numeric,
--   SOLAR_ACCESS_C                numeric,
--   RETAIL_VALUE_C                numeric(18),
--   SUN_VAULT_RETAIL_VALUE_C      numeric(18),
--   MODULE_CONFIGURATION_1_C      VARCHAR(18),
--   MODULE_CONFIGURATION_2_C      VARCHAR(18),
--   ADDITIONAL_COST_FOR_STORAGE_C numeric(18),
--   FLAT_MONTHLY_TPO_RATE_C       numeric(18),
--   _FIVETRAN_DELETED             BOOLEAN,
--   _FIVETRAN_SYNCED              TIMESTAMPTZ
-- );
--
--
-- drop table if exists brs.MODULE_CONFIGURATION_C;
-- create table if not exists brs.MODULE_CONFIGURATION_C
-- (
--   ID                     VARCHAR(18),
--   OWNER_ID               VARCHAR(18),
--   IS_DELETED             BOOLEAN,
--   NAME                   VARCHAR(240),
--   CURRENCY_ISO_CODE      VARCHAR(9),
--   CREATED_DATE           TIMESTAMPTZ,
--   CREATED_BY_ID          VARCHAR(18),
--   LAST_MODIFIED_DATE     TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID    VARCHAR(18),
--   SYSTEM_MODSTAMP        TIMESTAMPTZ,
--   LAST_VIEWED_DATE       TIMESTAMPTZ,
--   LAST_REFERENCED_DATE   TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID VARCHAR(18),
--   CONNECTION_SENT_ID     VARCHAR(18),
--   CURRENT_TYPE_C         VARCHAR(765),
--   ITEM_C                 VARCHAR(18),
--   DEFAULT_MODULE_ORDER_C numeric,
--   _FIVETRAN_SYNCED       TIMESTAMPTZ,
--   _FIVETRAN_DELETED      BOOLEAN,
--   SERIES_NUM_C           VARCHAR(765),
--   DIMENSIONS_WIDTH_C     numeric,
--   DESCRIPTION_C          VARCHAR(3000),
--   WATTAGE_C              numeric,
--   DIMENSIONS_LENGTH_C    numeric,
--   DIMENSIONS_SCALE_C     VARCHAR(765),
--   SERIES_ALPHA_C         VARCHAR(765),
--   EFFICIENCY_C           numeric,
--   AVAILABILITY_SCALE_C   VARCHAR(765),
--   DIMENSIONS_HEIGHT_C    numeric,
--   AVAILABILITY_C         numeric,
--   BACKSHEET_COLOR_C      VARCHAR(765)
-- );
--
-- drop table if exists brs.DESIGN_C;
-- create table if not exists  brs.DESIGN_C
-- (
--   ID                                         VARCHAR(18),
--   OWNER_ID                                   VARCHAR(18),
--   IS_DELETED                                 BOOLEAN,
--   NAME                                       VARCHAR(240),
--   CURRENCY_ISO_CODE                          VARCHAR(9),
--   RECORD_TYPE_ID                             VARCHAR(18),
--   CREATED_DATE                               TIMESTAMPTZ,
--   CREATED_BY_ID                              VARCHAR(18),
--   LAST_MODIFIED_DATE                         TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                        VARCHAR(18),
--   SYSTEM_MODSTAMP                            TIMESTAMPTZ,
--   LAST_ACTIVITY_DATE                         DATE,
--   LAST_VIEWED_DATE                           TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                       TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID                     VARCHAR(18),
--   CONNECTION_SENT_ID                         VARCHAR(18),
--   AC_DISCONNECT_REQUIRED_C                   VARCHAR(765),
--   ACTIVE_C                                   BOOLEAN,
--   ACTUAL_SYSTEM_SIZE_C                       numeric,
--   ELECTRICAL_AUDIT_NOTES_C                   VARCHAR(765),
--   ACTUAL_TIME_HOURS_C                        VARCHAR(9),
--   ARCHITECT_CONTACT_PHONE_C                  VARCHAR(120),
--   ARCHITECT_DESIGN_EMAIL_C                   VARCHAR(240),
--   ARCHITECT_DESIGN_NAME_C                    VARCHAR(150),
--   BUILDER_DESIGN_EMAIL_C                     VARCHAR(240),
--   BUILDER_DESIGN_NAME_C                      VARCHAR(150),
--   BUILDER_DESIGN_PHONE_C                     VARCHAR(120),
--   CHECKBOX_DESIGNER_NEEDS_INFORMATION_C      BOOLEAN,
--   CITY_C                                     VARCHAR(150),
--   CLIENT_APPROVE_PACKAGE_C                   DATE,
--   CLIENT_COMMENTS_FINAL_RESPONSE_C           DATE,
--   CLIENT_COMMENTS_FIRST_RECEIPT_C            DATE,
--   CLIENT_REVIEW_ACTUAL_SUBMIT_C              DATE,
--   SPWR_SCADA_ENGINEER_C                      VARCHAR(18),
--   CLIENT_REVIEW_FORECAST_SUBMIT_C            DATE,
--   CLIENT_REVIEW_PLANNED_SUBMIT_C             DATE,
--   COMMENTS_C                                 VARCHAR(96000),
--   COMMERCIAL_OPERATION_DATE_C                DATE,
--   CONDUIT_C                                  VARCHAR(765),
--   CONSTRUCTION_MANAGER_C                     VARCHAR(18),
--   CONTRACT_TYPE_C                            VARCHAR(765),
--   COUNTY_C                                   VARCHAR(150),
--   CYCLE_TIME_HOURS_C                         numeric,
--   DC_AC_RATIO_C                              numeric,
--   DC_DISCONNECT_REQUIRED_C                   VARCHAR(765),
--   DWG_ELEVATIONS_C                           VARCHAR(765),
--   DWG_FLOOR_ELEVATIONS_C                     VARCHAR(765),
--   DWG_ROOF_LAYOUT_C                          VARCHAR(765),
--   DATE_ANTICIPATED_DELIVERY_C                DATE,
--   DATE_COMPLETED_DESIGN_REVIEWED_C           DATE,
--   DATE_DELIVERY_REQUESTED_C                  DATE,
--   DATE_DESIGN_COMPLETED_C                    DATE,
--   DATE_DESIGN_REQUEST_VERIFIED_C             DATE,
--   DATE_DESIGN_SHIPPED_C                      DATE,
--   DATE_DESIGN_SIGNED_C                       DATE,
--   DATE_DESIGN_MUST_BE_COMPLETED_C            DATE,
--   DATE_RECIEVED_FROM_PRINTERS_C              DATE,
--   ELECTRICAL_AUDIT_C                         VARCHAR(765),
--   DATE_OF_AGREED_DELIVERY_C                  DATE,
--   POINT_OF_INTERCONNECTION_NOTES_C           VARCHAR(765),
--   DATE_OF_EXPECTED_COMPLETION_C              DATE,
--   DEAL_STATUS_C                              VARCHAR(765),
--   DELIVER_COMPLETED_PAPER_DESIGN_TO_C        VARCHAR(765),
--   DELIVERY_CARRIER_C                         VARCHAR(765),
--   DELIVERY_CITY_C                            VARCHAR(150),
--   DELIVERY_NAME_C                            VARCHAR(90),
--   DELIVERY_STATE_C                           VARCHAR(6),
--   DELIVERY_STREET_C                          VARCHAR(300),
--   DELIVERY_TRACKING_NUMBER_C                 VARCHAR(150),
--   DELIVERY_ZIP_C                             numeric,
--   DESCRIPTION_C                              VARCHAR(300),
--   DESIGN_FILES_LOCATED_IN_C                  VARCHAR(765),
--   INTERCONNECT_STUDY_C                       VARCHAR(765),
--   DESIGN_REVIEW_MEETING_CLIENT_C             DATE,
--   DESIGN_REVIEW_MEETING_PLAN_CHECK_C         DATE,
--   DESIGN_TRACKING_C                          DATE,
--   DESIGN_WORK_COMPLETED_ON_C                 DATE,
--   DESIGN_WORK_CONFIRMED_BY_C                 DATE,
--   DESIGN_WORK_LOCATED_IN_C                   VARCHAR(765),
--   DESIGN_WORK_REQUESTED_BY_C                 DATE,
--   DESIGN_REQUEST_REVIEWED_BY_C               VARCHAR(18),
--   DESIGNER_1_C                               VARCHAR(18),
--   DESIGNER_2_C                               VARCHAR(18),
--   DESIGNER_2_PERCENTAGE_C                    numeric,
--   DESIGNER_C                                 VARCHAR(765),
--   DRAFTER_C                                  VARCHAR(18),
--   DWG_FILES_C                                BOOLEAN,
--   ELECTRIC_UTILITY_C                         VARCHAR(765),
--   DESIGN_PACKAGE_TYPE_C                      VARCHAR(765),
--   ELECTRICAL_NOTES_C                         VARCHAR(765),
--   ELECTRICAL_PE_SIGNATURE_C                  VARCHAR(765),
--   EMAIL_COMPLETED_PDF_DESIGN_TO_C            VARCHAR(4099),
--   ESTIMATED_COMPLETION_DATE_C                DATE,
--   EXTERNAL_DESIGN_ERRORS_C                   VARCHAR(4099),
--   FED_EX_COST_C                              numeric(6, 2),
--   FORMAT_2_C                                 VARCHAR(765),
--   FORMAT_C                                   VARCHAR(765),
--   GCR_C                                      numeric,
--   GEOTECH_STRUCTURAL_LETTER_ACTUAL_C         DATE,
--   HERS_DATA_C                                BOOLEAN,
--   INCOMING_REQUEST_HAD_ALL_INFORMATION_C     VARCHAR(765),
--   INFORMATION_ABOUT_SYSTEM_SIZE_C            VARCHAR(150),
--   INTERNAL_DESIGN_ERRORS_C                   VARCHAR(4099),
--   ISSUE_ELECTRICAL_BOM_ACTUAL_C              DATE,
--   ISSUE_ELECTRICAL_BOM_PLANNED_C             DATE,
--   ISSUE_MECHANICAL_BOM_ACTUAL_C              DATE,
--   ISSUE_MECHANICAL_BOM_PLANNED_C             DATE,
--   LAYOUT_2_C                                 VARCHAR(765),
--   LAYOUT_C                                   VARCHAR(765),
--   LOCATION_OF_REVISION_DOCUMENTS_C           VARCHAR(765),
--   LOT_PERMITS_C                              VARCHAR(4099),
--   LOT_S_FOR_THIS_DESIGN_C                    VARCHAR(60),
--   MASTER_PERMIT_PACKAGE_LAYOUT_C             VARCHAR(4099),
--   MISSING_INFORMATION_C                      VARCHAR(765),
--   NECESSARY_ARCHITECT_BUILDER_INFO_FILED_C   VARCHAR(765),
--   NOTES_FROM_DESIGNER_C                      VARCHAR(765),
--   NOTES_FROM_REQUESTER_C                     VARCHAR(60000),
--   NOTES_ON_PV_FAST_C                         VARCHAR(765),
--   NUMBER_OF_CLIENT_COMMENTS_C                numeric,
--   NUMBER_OF_DESIGN_ERRORS_C                  numeric,
--   NUMBER_OF_ELEVATIONS_C                     numeric,
--   NUMBER_OF_LOT_PERMIT_C                     VARCHAR(765),
--   NUMBER_OF_MASTER_PERMIT_SETS_C             VARCHAR(765),
--   NUMBER_OF_PERMIT_AGENCY_COMMENTS_C         numeric,
--   NUMBER_OF_PLAN_TYPES_C                     numeric,
--   NUMBER_OF_SETS_C                           numeric,
--   OPEN_RFIS_C                                numeric,
--   OPPORTUNITY_C                              VARCHAR(18),
--   OTHER_EMAIL_C                              VARCHAR(240),
--   PE_SIGNATURE_C                             VARCHAR(765),
--   PSR_C                                      VARCHAR(18),
--   PERCENT_OF_DESIGN_COMPLETE_C               numeric,
--   PERMIT_AWARD_ACTUAL_C                      DATE,
--   PERMIT_AWARD_PLANNED_C                     DATE,
--   PERMIT_COMMENTS_FINAL_RESPONSE_C           DATE,
--   PERMIT_COMMENTS_FIRST_RECIEPT_C            DATE,
--   PERMIT_JURISDICTION_C                      VARCHAR(150),
--   PERMIT_PACKAGE_FORMAT_C                    VARCHAR(765),
--   PERMIT_PACKAGE_SETS_REQUIRED_C             VARCHAR(765),
--   PHASE_MAP_SEQUENCE_SHEETS_C                VARCHAR(765),
--   PHASE_C                                    VARCHAR(765),
--   PHASE_S_FOR_THIS_DESGN_C                   VARCHAR(60),
--   PHASES_IN_PROJECT_C                        VARCHAR(765),
--   PHONE_DELIVERY_C                           VARCHAR(120),
--   PLAN_CHECK_ACTUAL_SUBMIT_C                 DATE,
--   PLAN_CHECK_PLANNED_SUBMIT_C                DATE,
--   PLAN_TYPE_DETAILS_C                        VARCHAR(765),
--   PLOT_PLANS_C                               VARCHAR(765),
--   PRICE_BOOK_C                               VARCHAR(765),
--   PRIMARY_PSR_DESIGN_C                       BOOLEAN,
--   PRODUCT_TYPE_C                             VARCHAR(765),
--   PROJECT_DESIGNER_C                         VARCHAR(18),
--   PROJECT_MANAGER_CONTACT_C                  VARCHAR(18),
--   PROJECT_MANAGER_C                          VARCHAR(18),
--   PROJECT_NUMBER_C                           VARCHAR(15),
--   PROPOSAL_DESIGNER_C                        VARCHAR(18),
--   QUOTE_C                                    VARCHAR(18),
--   REASON_FOR_REVISION_C                      VARCHAR(765),
--   REASON_FOR_LATE_DELIVERY_C                 VARCHAR(96000),
--   RECORD_DRAWINGS_ACTUAL_SUBMIT_C            DATE,
--   RECORD_DRAWINGS_RED_LINES_RECEIVED_C       DATE,
--   REFRESH_COUNT_C                            numeric,
--   REQUESTED_SYSTEM_SIZE_C                    numeric,
--   REVISION_LETTER_C                          VARCHAR(765),
--   REVISION_TYPE_C                            VARCHAR(765),
--   ROOF_PITCH_S_ARE_KNOWN_C                   VARCHAR(765),
--   ROOF_TYPE_NOTES_C                          VARCHAR(765),
--   ROOF_TYPE_C                                VARCHAR(765),
--   SALES_ANALYST_C                            VARCHAR(18),
--   SALESPERSON_C                              VARCHAR(765),
--   SHEET_SIZE_2_C                             VARCHAR(765),
--   SHEET_SIZE_C                               VARCHAR(765),
--   SIGNAGE_C                                  VARCHAR(765),
--   SINGLE_LINE_COMPLETED_C                    DATE,
--   SINGLE_LINE_STATUS_C                       VARCHAR(765),
--   SITE_MAP_C                                 VARCHAR(765),
--   SITE_MAXIMIZED_C                           VARCHAR(765),
--   SITE_C                                     VARCHAR(18),
--   SOLAR_STARTS_IN_PHASE_C                    VARCHAR(765),
--   SOURCE_C                                   VARCHAR(765),
--   SPECIAL_PERMIT_REQUIREMENTS_C              VARCHAR(765),
--   STANDARD_TIME_HOURS_C                      numeric,
--   STATUS_2_0_C                               VARCHAR(765),
--   STATUS_C                                   VARCHAR(765),
--   STRUCTURAL_ENGINEER_C                      VARCHAR(18),
--   STRUCTURAL_PE_SIGNATURE_C                  VARCHAR(765),
--   SYSTEM_SIZE_NOTES_C                        VARCHAR(300),
--   SYSTEM_SIZE_C                              VARCHAR(75),
--   TASK_ID_C                                  VARCHAR(54),
--   TOPO_GPS_SURVEY_ACTUAL_C                   DATE,
--   SPWR_ELECTRICAL_ENGINEER_1_C               VARCHAR(18),
--   TOTAL_NUMBER_OF_SETS_2_C                   numeric,
--   TOTAL_PHASES_IN_PROJECT_C                  numeric,
--   TOTAL_RFIS_C                               numeric,
--   TYPE_OF_DESIGN_WORK_REQUIRED_C             VARCHAR(765),
--   TYPE_OF_DESIGN_C                           VARCHAR(765),
--   TYPE_OF_PROJECT_C                          VARCHAR(765),
--   URL_OF_DESIGN_NEEDING_REVISION_C           VARCHAR(765),
--   INTERCONNECT_STUDY_NOTES_C                 VARCHAR(765),
--   URGENT_REQUEST_C                           BOOLEAN,
--   UTILITY_C                                  VARCHAR(765),
--   VDC_C                                      VARCHAR(765),
--   WAS_PV_FAST_HELPFUL_C                      VARCHAR(765),
--   WAS_PV_FAST_USED_C                         VARCHAR(765),
--   WEIGHT_C                                   VARCHAR(9),
--   X_75_PERCENT_BRIEFING_MEETING_C            DATE,
--   OF_SHEETS_PRINTED_C                        numeric,
--   ACTUAL_SYSTEM_SIZE_PV_C                    numeric,
--   ACTUAL_SYSTEM_SIZE_BOS_C                   numeric,
--   RECEIVED_INFORMATION_TO_DESIGN_C           DATE,
--   ELECTRICAL_ENGINEER_OF_RECORD_C            VARCHAR(18),
--   OPPORTUNITY_NAME_HIDDEN_C                  VARCHAR(297),
--   DESIGN_START_DATE_C                        DATE,
--   PSR_OWNER_C                                VARCHAR(18),
--   ORIGINAL_SUBMIT_DATE_C                     DATE,
--   SR_PROJECT_DESIGN_ENGINEER_C               VARCHAR(18),
--   DEVELOPMENT_ENGINEER_C                     VARCHAR(18),
--   PROJECT_ENGINEER_C                         VARCHAR(18),
--   PV_POWER_RATING_C                          numeric,
--   SCHEDULE_APPROVAL_PLANNED_DATE_C           DATE,
--   BUDGET_APPROVAL_PLANNED_DATE_C             DATE,
--   CONSTRAINTS_MAP_RECEIVED_C                 VARCHAR(765),
--   PRELIMINARY_BOM_PLANNED_DATE_C             DATE,
--   REASON_FOR_CANCELLATION_REJECTION_C        VARCHAR(4099),
--   X_75_SALES_HANDOFF_MEETING_DATE_C          DATE,
--   X_75_DESIGN_KICKOFF_MEETING_DATE_C         DATE,
--   DESIGN_START_DATE_PLANNED_C                DATE,
--   DESIGN_START_DATE_ACTUAL_C                 DATE,
--   PROJECT_BOM_PLANNED_DATE_C                 DATE,
--   X_25_SCHEMATIC_DOCUMENTS_PLANNED_DATE_C    DATE,
--   X_50_DESIGN_DOCUMENTS_PLANNED_DATE_C       DATE,
--   X_90_DESIGN_REVIEW_PLANNED_DATE_C          DATE,
--   X_90_DESIGN_DOCUMENTS_PLANNED_DATE_C       DATE,
--   CLIENT_REVIEW_SUBMITTAL_PLANNED_DATE_C     DATE,
--   DESIGN_COMPLETED_PLANNED_DATE_C            DATE,
--   CLIENT_APPROVAL_PLANNED_DATE_C             DATE,
--   CONSTRAINTS_MAP_NOTES_C                    VARCHAR(765),
--   TIME_IN_QUEUE_C                            numeric,
--   APPLIED_FOR_PERMIT_C                       DATE,
--   STRUCTURAL_ENGINEER_OF_RECORD_C            VARCHAR(18),
--   ESTIMATED_TIME_HRS_C                       numeric,
--   REV_A_ESTIMATED_TIMES_C                    numeric,
--   ALL_OTHER_REVS_ESTIMATED_TIMES_C           numeric,
--   SITE_AUDIT_NOTES_C                         VARCHAR(765),
--   STRUCTURAL_QUALIFICATION_NOTES_C           VARCHAR(765),
--   ROOF_REPORT_NOTES_C                        VARCHAR(765),
--   TOPO_GPS_NOTES_C                           VARCHAR(765),
--   INVERTER_NOTES_C                           VARCHAR(765),
--   GEOTECH_NOTES_C                            VARCHAR(765),
--   PACKAGE_TYPE_C                             VARCHAR(765),
--   TECHNOLOGY_SYSTEM_C                        VARCHAR(765),
--   REVISION_C                                 VARCHAR(765),
--   STRUCTURAL_AS_BUILT_DRAWING_C              VARCHAR(765),
--   SUN_POWER_SITE_AUDIT_C                     VARCHAR(765),
--   GEOTECH_REPORT_RECEIVED_C                  VARCHAR(765),
--   TOPO_GPS_SURVEY_RECEIVED_C                 VARCHAR(765),
--   ROOF_REPORT_RECEIVED_C                     VARCHAR(765),
--   STRUCTURAL_QUALIFICATION_RECEIVED_C        VARCHAR(765),
--   ELECTRICAL_AS_BUILT_DRAWINGS_C             VARCHAR(765),
--   CIVIL_AS_BUILT_DRAWINGS_C                  VARCHAR(765),
--   ARCHITECTURAL_AS_BUILT_DRAWINGS_C          VARCHAR(765),
--   TITLE_REPORT_RECEIVED_C                    VARCHAR(765),
--   TITLE_REPORT_NOTES_C                       VARCHAR(765),
--   ALTA_NOTES_C                               VARCHAR(765),
--   HYDROLOGY_REPORT_RECEIVED_C                VARCHAR(765),
--   HYDROLOGY_REPORT_NOTES_C                   VARCHAR(765),
--   MODULE_TYPE_C                              VARCHAR(765),
--   BOM_ENTERED_INTO_ORACLE_C                  DATE,
--   INVERTER_MANUFACTURER_C                    VARCHAR(765),
--   TASKS_GENERATED_C                          BOOLEAN,
--   DELIVER_TO_C                               VARCHAR(4099),
--   DESIGN_ERROR_TYPE_C                        VARCHAR(4099),
--   FOR_EOR_REJECTION_DATE_C                   DATE,
--   FOR_EOR_REVIEW_DATE_C                      DATE,
--   NH_URGENT_REQUEST_TYPE_C                   VARCHAR(765),
--   NEW_HOMES_COMMUNITY_C                      VARCHAR(18),
--   PDF_COPY_ONLY_C                            BOOLEAN,
--   PURE_DESIGN_TIME_C                         numeric,
--   REASON_LEVEL_1_C                           VARCHAR(765),
--   REASON_LEVEL_2_C                           VARCHAR(765),
--   REASON_FOR_CANCELLATION_REJECTION_2_C      VARCHAR(765),
--   SHARED_WITH_BUILDER_C                      DATE,
--   DESIGN_NOT_STARTED_DATE_C                  DATE,
--   DESIGN_NOT_STARTED_C                       TIMESTAMPTZ,
--   COLUMN_COUNT_C                             numeric,
--   CONFIGURATION_CONCERN_DESCRIPTION_C        VARCHAR(98304),
--   DESIGN_TEAM_NOTES_C                        VARCHAR(98304),
--   DUE_DILIGENCE_REPORTS_C                    VARCHAR(98304),
--   ROOF_MATERIAL_MANUFACTURER_C               VARCHAR(765),
--   X_3_RD_PARTY_ARCHITECT_C                   VARCHAR(18),
--   X_3_RD_PARTY_CARPORT_CANOPY_DESIGNER_C     VARCHAR(18),
--   X_3_RD_PARTY_DESIGNER_C                    VARCHAR(18),
--   X_3_RD_PARTY_ELECTRICAL_ENG_C              VARCHAR(18),
--   DESIGN_APPLICATIONS_C                      VARCHAR(4099),
--   _FIVETRAN_SYNCED                           TIMESTAMPTZ,
--   MPPP_REVISION_NEEDED_C                     VARCHAR(765),
--   _FIVETRAN_DELETED                          BOOLEAN,
--   ROW_GAP_C                                  VARCHAR(765),
--   ASCE_CODE_C                                VARCHAR(765),
--   ACCESS_PATHWAY_SKYLIGHT_C                  numeric,
--   STORAGE_QUANTITY_1_C                       numeric,
--   DEALER_STATUS_C                            VARCHAR(765),
--   RAPID_SHUTDOWN_GUIDELINES_C                VARCHAR(765),
--   EXCESSIVE_UNDOCUMENTED_FILL_C              BOOLEAN,
--   PARTNER_COMMENTS_C                         VARCHAR(393216),
--   SITE_LOCATED_IN_A_FLOOD_PLAIN_C            BOOLEAN,
--   X_7_5_DEGREE_TILT_C                        BOOLEAN,
--   SNOW_GUARD_REQUIRED_PICKLIST_C             VARCHAR(765),
--   DECKING_C                                  BOOLEAN,
--   ID_JSON_C                                  VARCHAR(393216),
--   ID_RADIUS_C                                numeric,
--   PROJECT_CONTACT_PERSON_C                   VARCHAR(18),
--   LIGHT_FIXTURES_C                           VARCHAR(765),
--   PAUSE_COUNTER_C                            numeric,
--   VERTICAL_UPLIFT_RESISTANCE_SKIN_FRICTION_C numeric,
--   VERTICAL_DOWNWARD_LOAD_SKIN_FRICTION_C     numeric,
--   MULTI_SITE_C                               VARCHAR(765),
--   STORAGE_OPTION_2_C                         VARCHAR(765),
--   ACCESS_PATHWAY_SERVICEABLE_VENT_C          numeric,
--   SETBACK_DISTANCE_HVAC_C                    numeric,
--   MODULE_QUANTITY_C                          numeric,
--   MIN_CLEARANCE_LOWER_EDGE_C                 numeric,
--   COMMERCIAL_PSR_C                           VARCHAR(18),
--   TOPO_GRADE_CHANGE_SPECIFY_C                numeric,
--   AC_RUN_C                                   VARCHAR(765),
--   DESIGN_AWAITING_APPROVAL_C                 TIMESTAMPTZ,
--   IS_SITE_IN_SPECIAL_SNOW_REGION_C           VARCHAR(765),
--   HELIX_DESIGN_TYPE_C                        VARCHAR(765),
--   STEP_NUMBER_C                              numeric,
--   FALL_PROTECTION_C                          VARCHAR(765),
--   SNOW_LOAD_C                                VARCHAR(765),
--   ALLOWABLE_PASSIVE_PRESSURE_C               numeric,
--   INVERTER_TYPE_C                            VARCHAR(765),
--   WIND_SPEED_C                               VARCHAR(765),
--   DESIGN_COMPLETED_DATE_C                    TIMESTAMPTZ,
--   WIND_SPEED_MRI_C                           VARCHAR(765),
--   SHALLOW_BEDROCK_C                          BOOLEAN,
--   FINAL_DESIGN_C                             BOOLEAN,
--   SOIL_SUBJECT_TO_LIQUEFACTION_C             BOOLEAN,
--   SETBACK_DISTANCE_SERVICEABLE_VENT_C        numeric,
--   MIN_CLEARANCE_HEIGHT_REQUIRED_IS_GREATER_C VARCHAR(765),
--   FLUSH_MOUNTED_PIERS_PICKLIST_C             VARCHAR(765),
--   REMOVE_TREES_C                             BOOLEAN,
--   WATER_MANAGEMENT_C                         VARCHAR(765),
--   DESIGN_APPROVED_C                          TIMESTAMPTZ,
--   DESIGN_STARTED_DATE_C                      TIMESTAMPTZ,
--   STORAGE_OPTION_1_C                         VARCHAR(765),
--   CRSM_C                                     VARCHAR(18),
--   DEALER_REQUESTED_SYSTEM_SIZE_AC_C          numeric,
--   STORAGE_QUANTITY_2_C                       numeric,
--   TARGET_ANNUAL_PRODUCTION_C                 numeric,
--   DEALER_NAME_C                              VARCHAR(18),
--   IS_SITE_IN_SPECIAL_WIND_REGION_C           VARCHAR(765),
--   SUBMITTED_C                                BOOLEAN,
--   SEPARATE_DC_SWITCH_REQUIRED_C              BOOLEAN,
--   TOPO_GRADE_CHANGE_C                        BOOLEAN,
--   FLUSH_MOUNTED_PIERS_C                      BOOLEAN,
--   DESIGN_AWAITING_APPROVAL_DATE_C            DATE,
--   INCREASED_CORROSION_PROTECTION_C           VARCHAR(765),
--   CONTRACT_DESIGN_C                          BOOLEAN,
--   LABOR_C                                    VARCHAR(765),
--   SNOW_GUARD_REQUIRED_C                      BOOLEAN,
--   REVISION_OF_C                              VARCHAR(18),
--   GCR_REQUIREMENT_C                          VARCHAR(765),
--   BALLAST_BLOCK_WEIGHT_C                     numeric,
--   PRIMARY_SIMULATION_C                       VARCHAR(18),
--   EMAIL_C                                    VARCHAR(240),
--   DESIGN_COMPLEXITY_C                        VARCHAR(765),
--   CALIFORNIA_DSA_REQUIRED_C                  VARCHAR(765),
--   ADDITIONAL_37_WATT_EDGE_LIGHTING_C         BOOLEAN,
--   EXPECTED_INSTALLATION_DATE_C               DATE,
--   SETBACK_DISTANCE_SKYLIGHT_C                numeric,
--   REROUTE_CONDUIT_C                          BOOLEAN,
--   NO_OF_DAS_MONITOR_BOX_C                    numeric,
--   APPROVAL_SUBMITTED_C                       TIMESTAMPTZ,
--   BRANDING_C                                 BOOLEAN,
--   ACTUAL_ANNUAL_PRODUCTION_C                 numeric,
--   ACCESS_PATHWAY_HVAC_C                      numeric,
--   DESIGN_SUBMITTED_DATE_C                    TIMESTAMPTZ,
--   DESIGN_ORIGINATED_BY_C                     VARCHAR(765),
--   MAX_OUTTHE_ROOF_SPACE_C                    BOOLEAN,
--   UNDERGROUND_UTILITY_LINES_C                BOOLEAN,
--   TILT_OPTION_C                              VARCHAR(765),
--   TIME_IN_REVIEW_C                           numeric,
--   MODULE_TYPEAND_WATTAGE_C                   VARCHAR(765),
--   METER_INTERCONNECTION_APPLICATION_C        VARCHAR(18),
--   PLAN_CHECK_FORECAST_SUBMIT_C               DATE,
--   AZIMUTH_C                                  numeric,
--   OLD_SYS_DESIGN_NAME_C                      VARCHAR(150),
--   DATE_TIME_PAUSED_C                         TIMESTAMPTZ,
--   QUOTE_ESTIMATE_C                           VARCHAR(18),
--   SUBMITTED_DATE_C                           DATE,
--   TILT_C                                     numeric,
--   QA_REVIEWED_BY_C                           VARCHAR(18),
--   PERMIT_AWARD_FORECAST_C                    DATE,
--   SCOPE_C                                    VARCHAR(765),
--   ADD_AC_SPLICE_BOX_C                        BOOLEAN,
--   ROOF_DESIGN_C                              VARCHAR(18),
--   ACTUAL_SYSTEM_SIZE_DC_K_WP_C               numeric,
--   CUSTOMER_DOCUMENTS_C                       VARCHAR(98304),
--   BUILDING_HEIGHT_NOTES_C                    VARCHAR(98304),
--   VALID_UNTIL_C                              DATE,
--   TITLE_24_DOCUMENTS_C                       VARCHAR(98304),
--   TOTAL_ITEM_COST_C                          numeric(18, 2),
--   TITLE_24_GUIDANCE_C                        VARCHAR(98304),
--   PV_COST_C                                  numeric(18, 4),
--   BOS_COST_C                                 numeric(18, 4),
--   MODULE_LEVEL_SHUT_DOWN_DEVICE_C            VARCHAR(765),
--   DATE_PAUSED_C                              DATE,
--   MODULE_WATTAGE_AND_TYPE_C                  VARCHAR(765),
--   TIER_1_DESIGN_C                            VARCHAR(18),
--   ATTACHMENT_TYPE_C                          VARCHAR(765),
--   YIELD_C                                    numeric,
--   ROOF_MATERIAL_C                            VARCHAR(765),
--   SYSTEM_SIZE_AC_C                           numeric,
--   POWER_AUXILIARY_FROM_HELIX_AC_COMBINER_C   BOOLEAN,
--   ANNUAL_SHADING_C                           numeric,
--   AURORA_DOCUMENTS_C                         VARCHAR(98304),
--   TARGET_SYSTEM_SIZE_DC_K_WP_C               numeric,
--   PVSIM_MODULE_NO_C                          VARCHAR(30),
--   DEGRADATION_RATE_C                         numeric,
--   ADD_AUXILIARY_BOX_FOR_MONITORING_UNIT_C    BOOLEAN,
--   POINTS_OF_INTERCONNECTION_C                numeric
-- );
--
-- drop table if exists brs.PROJECT_TASK_C;
-- create table if not exists brs.PROJECT_TASK_C
-- (
--   ID                                 VARCHAR(18),
--   IS_DELETED                         BOOLEAN,
--   NAME                               VARCHAR(240),
--   CURRENCY_ISO_CODE                  VARCHAR(9),
--   RECORD_TYPE_ID                     VARCHAR(18),
--   CREATED_DATE                       TIMESTAMPTZ,
--   CREATED_BY_ID                      VARCHAR(18),
--   LAST_MODIFIED_DATE                 TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                VARCHAR(18),
--   SYSTEM_MODSTAMP                    TIMESTAMPTZ,
--   LAST_ACTIVITY_DATE                 DATE,
--   LAST_VIEWED_DATE                   TIMESTAMPTZ,
--   LAST_REFERENCED_DATE               TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID             VARCHAR(18),
--   CONNECTION_SENT_ID                 VARCHAR(18),
--   RESIDENTIAL_PROJECT_C              VARCHAR(18),
--   ASSIGNED_TO_C                      VARCHAR(18),
--   CRITICAL_PATH_C                    BOOLEAN,
--   DESCRIPTION_C                      VARCHAR(765),
--   DOCUMENT_REQUIRED_C                BOOLEAN,
--   DUE_DATE_C                         DATE,
--   ELAPSED_DATE_TIME_C                TIMESTAMPTZ,
--   END_DATE_TIME_C                    TIMESTAMPTZ,
--   MILESTONE_C                        VARCHAR(765),
--   ORDER_C                            numeric,
--   PROJECT_PRIORITY_C                 VARCHAR(765),
--   PROJECT_TASK_C                     VARCHAR(18),
--   ROLE_ASSIGNMENT_C                  VARCHAR(765),
--   SLA_DAYS_C                         numeric,
--   START_DATE_TIME_C                  TIMESTAMPTZ,
--   STATUS_C                           VARCHAR(765),
--   TASK_TYPE_NAME_C                   VARCHAR(765),
--   TEMPLATE_TASK_C                    VARCHAR(18),
--   TIME_DIFFERENTIAL_C                numeric,
--   TIMES_REPEATED_C                   numeric,
--   COMMENT_C                          VARCHAR(98304),
--   ESCALATION_CATEGORY_C              VARCHAR(765),
--   ESCALATION_SUB_CATEGORY_C          VARCHAR(765),
--   PARENT_TASK_C                      VARCHAR(18),
--   REWORK_CATEGORY_C                  VARCHAR(765),
--   TASK_TYPE_C                        VARCHAR(765),
--   REQUIRED_PROJECT_FIELDS_C          VARCHAR(4099),
--   APEX_UPDATED_C                     numeric,
--   APEX_NAME_C                        VARCHAR(384),
--   NOTIFICATION_SENT_C                BOOLEAN,
--   FIRST_COMPLETE_END_DATE_TIME_C     TIMESTAMPTZ,
--   BLOCKING_C                         VARCHAR(18),
--   BLOCKS_C                           VARCHAR(765),
--   PATH_TYPE_C                        VARCHAR(765),
--   PATH_TO_BLOCK_C                    VARCHAR(765),
--   EXCEPTION_WORKFLOW_TEMPLATE_C      VARCHAR(18),
--   APPOINTMENT_CANCELLATION_NOTES_C   VARCHAR(765),
--   APPOINTMENT_CANCELLATION_C         BOOLEAN,
--   CANCELLATION_REASONS_C             VARCHAR(765),
--   RESCHEDULED_APPOINTMENT_DATE_C     TIMESTAMPTZ,
--   TASK_PATH_TYPE_C                   VARCHAR(18),
--   MAIN_PANEL_UPGRADE_REASON_C        VARCHAR(765),
--   COMPLETED_BY_C                     VARCHAR(18),
--   _FIVETRAN_SYNCED                   TIMESTAMPTZ,
--   COMMENT_INITIAL_MODIFIED_DATE_C    VARCHAR(765),
--   EXCEPTION_WORKFLOW_TEMPLATE_TEXT_C VARCHAR(765),
--   RESUBMISSION_FEE_C                 BOOLEAN,
--   _FIVETRAN_DELETED                  BOOLEAN,
--   ASSIGNED_TO_TEXT_C                 VARCHAR(240),
--   FIRST_COMPLETE_TIME_DIFFERENTIAL_C numeric,
--   REASON_LEVELS_C                    VARCHAR(765),
--   BLOCKED_BY_SUBTASKS_C              VARCHAR(98304),
--   LAST_TASK_REWORK_CHECK_C           BOOLEAN,
--   PRIORITY_C                         numeric,
--   IP_OWNER_C                         VARCHAR(18),
--   LAST_MODIFIED_BY_C                 VARCHAR(18),
--   LAST_MODIFIED_C                    TIMESTAMPTZ,
--   BYPASS_LAST_MODIFIED_C             BOOLEAN,
--   REWORK_TIME_DIFFERENTIAL_C         numeric,
--   LAST_STATUS_C                      VARCHAR(384),
--   REWORK_START_DATE_TIME_C           TIMESTAMPTZ
-- );

-- drop table if exists brs.ALLIANCE_PARTNER_C;
-- create table if not exists brs.ALLIANCE_PARTNER_C
-- (
--   ID                            VARCHAR(18),
--   OWNER_ID                      VARCHAR(18),
--   IS_DELETED                    BOOLEAN,
--   NAME                          VARCHAR(240),
--   CURRENCY_ISO_CODE             VARCHAR(9),
--   RECORD_TYPE_ID                VARCHAR(18),
--   CREATED_DATE                  TIMESTAMPTZ,
--   CREATED_BY_ID                 VARCHAR(18),
--   LAST_MODIFIED_DATE            TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID           VARCHAR(18),
--   SYSTEM_MODSTAMP               TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID        VARCHAR(18),
--   CONNECTION_SENT_ID            VARCHAR(18),
--   RESIDENTIAL_PROJECT_C         VARCHAR(18),
--   PARTNER_ACCOUNT_C             VARCHAR(18),
--   ROLE_C                        VARCHAR(765),
--   COMMUNITY_C                   VARCHAR(18),
--   UPDATE_RPON_ICD_C             BOOLEAN,
--   LOAN_PAYMENT_CLASSIFICATION_C VARCHAR(150),
--   _FIVETRAN_SYNCED              TIMESTAMPTZ,
--   _FIVETRAN_DELETED             BOOLEAN,
--   CUSTOMER_ACCOUNT_C            VARCHAR(18)
-- );

-- drop table if exists brs.CREDIT_CHECK_REQUEST_C;
-- create table if not exists  brs.CREDIT_CHECK_REQUEST_C
-- (
--   ID                                         VARCHAR(18),
--   IS_DELETED                                 BOOLEAN,
--   NAME                                       VARCHAR(240),
--   CURRENCY_ISO_CODE                          VARCHAR(9),
--   CREATED_DATE                               TIMESTAMPTZ,
--   CREATED_BY_ID                              VARCHAR(18),
--   LAST_MODIFIED_DATE                         TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                        VARCHAR(18),
--   SYSTEM_MODSTAMP                            TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID                     VARCHAR(18),
--   CONNECTION_SENT_ID                         VARCHAR(18),
--   ACCOUNT_C                                  VARCHAR(18),
--   CONTACT_C                                  VARCHAR(18),
--   EMAIL_C                                    VARCHAR(240),
--   FIRST_NAME_C                               VARCHAR(300),
--   LAST_NAME_C                                VARCHAR(300),
--   STATUS_C                                   VARCHAR(300),
--   SUCCESSFUL_INVITE_C                        BOOLEAN,
--   ERROR_MESSAGE_C                            VARCHAR(765),
--   APPLICATION_ID_C                           VARCHAR(765),
--   APPLICATION_TYPE_C                         VARCHAR(765),
--   CREDIT_BEUREU_C                            VARCHAR(765),
--   CREDIT_CHECK_APPROVAL_DATE_C               DATE,
--   CREDIT_CHECK_EXPIRATION_DATE_C             DATE,
--   CREDIT_CHECK_MESSAGE_C                     VARCHAR(390000),
--   CREDIT_CHECK_SUBMISSION_DATE_C             DATE,
--   OPPORTUNITY_C                              VARCHAR(18),
--   CITY_C                                     VARCHAR(765),
--   PHONE_C                                    VARCHAR(120),
--   STATE_C                                    VARCHAR(765),
--   STREET_2_C                                 VARCHAR(765),
--   STREET_C                                   VARCHAR(765),
--   ZIP_C                                      VARCHAR(30),
--   SEND_LEASE_CREDIT_CHECK_FAILURE_EMAIL_C    BOOLEAN,
--   BUREAU_C                                   VARCHAR(765),
--   DECISION_REASON_C                          VARCHAR(765),
--   CREDIT_APPLICATION_URL_C                   VARCHAR(765),
--   MORTGAGE_PRE_APPROVAL_LETTER_URL_C         VARCHAR(765),
--   LENDER_C                                   VARCHAR(765),
--   SELF_SERVICE_USER_C                        VARCHAR(18),
--   AUTH_TOKEN_C                               VARCHAR(765),
--   COMMENTS_C                                 VARCHAR(96000),
--   CREDIT_CHECK_DECISION_DATE_C               DATE,
--   GOVT_ID_UPLOAD_TIME_C                      TIMESTAMPTZ,
--   MORTGAGE_PRE_APPROVAL_LETTER_UPLOAD_TIME_C TIMESTAMPTZ,
--   EXTERNAL_ID_C                              VARCHAR(765),
--   _FIVETRAN_SYNCED                           TIMESTAMPTZ,
--   _FIVETRAN_DELETED                          BOOLEAN,
--   PROJECT_ID_C                               VARCHAR(765),
--   OFFER_ID_C                                 VARCHAR(765),
--   SHARE_ID_C                                 VARCHAR(765),
--   EMAIL_COUNTER_C                            numeric
-- );
-- drop table if exists brs.TITLE_CHECK_C;
-- create table if not exists brs.TITLE_CHECK_C
-- (
--   ID                       VARCHAR(18),
--   IS_DELETED               BOOLEAN,
--   NAME                     VARCHAR(240),
--   CURRENCY_ISO_CODE        VARCHAR(9),
--   CREATED_DATE             TIMESTAMPTZ,
--   CREATED_BY_ID            VARCHAR(18),
--   LAST_MODIFIED_DATE       TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID      VARCHAR(18),
--   SYSTEM_MODSTAMP          TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID   VARCHAR(18),
--   CONNECTION_SENT_ID       VARCHAR(18),
--   ACCOUNT_C                VARCHAR(18),
--   APN_C                    VARCHAR(765),
--   ALTERNATE_APN_C          VARCHAR(765),
--   CENSUS_BLOCK_GROUP_C     VARCHAR(765),
--   CENSUS_BLOCK_C           VARCHAR(765),
--   CENSUS_TRACT_C           VARCHAR(765),
--   COMMENTS_C               VARCHAR(98304),
--   COUNTY_USE_C             VARCHAR(765),
--   COUNTY_C                 VARCHAR(765),
--   SECONDARY_OWNER_C        VARCHAR(765),
--   EXTERNAL_PROPERTY_ID_C   VARCHAR(765),
--   LAND_USE_C               VARCHAR(765),
--   LEGAL_BLOCK_C            VARCHAR(765),
--   LEGAL_DESCRIPTION_C      VARCHAR(98304),
--   LEGAL_LOT_C              VARCHAR(765),
--   MAILING_CITY_STATE_C     VARCHAR(765),
--   MAILING_STREET_C         VARCHAR(765),
--   MAILING_ZIP_C            VARCHAR(765),
--   MAP_REFERENCE_C          VARCHAR(765),
--   MUNICIPALITY_C           VARCHAR(765),
--   OWNER_NAME_C             VARCHAR(765),
--   PROPERTY_CITY_C          VARCHAR(765),
--   PROPERTY_STATE_C         VARCHAR(765),
--   PROPERTY_STREET_C        VARCHAR(765),
--   PROPERTY_ZIP_C           VARCHAR(765),
--   RECORDING_DATE_C         VARCHAR(765),
--   SALE_DATE_C              VARCHAR(765),
--   SELLER_NAME_C            VARCHAR(765),
--   STATE_USE_C              VARCHAR(765),
--   SUBDIVISION_C            VARCHAR(765),
--   TOWNSHIP_RANGE_SECTION_C VARCHAR(765),
--   TOWNSHIP_C               VARCHAR(765),
--   ACTION_TAKEN_C           VARCHAR(765),
--   COUNTY_USE_CODE_C        VARCHAR(765),
--   LAND_USE_CODE_C          VARCHAR(765),
--   MAP_REFERENCE_2_C        VARCHAR(765),
--   STATE_USE_CODE_C         VARCHAR(765),
--   VESTING_CODE_C           VARCHAR(765),
--   _FIVETRAN_DELETED        BOOLEAN,
--   _FIVETRAN_SYNCED         TIMESTAMPTZ,
--   OWNER_LAST_NAME_C        VARCHAR(765),
--   OWNER_FIRST_NAME_C       VARCHAR(765)
-- );
-- drop table if exists brs.OPPORTUNITY;
-- create table if not exists brs.OPPORTUNITY
-- (
--   ID                                          VARCHAR(18),
--   IS_DELETED                                  BOOLEAN,
--   ACCOUNT_ID                                  VARCHAR(18),
--   RECORD_TYPE_ID                              VARCHAR(18),
--   NAME                                        VARCHAR(360),
--   DESCRIPTION                                 VARCHAR(96000),
--   STAGE_NAME                                  VARCHAR(765),
--   AMOUNT                                      numeric(18, 2),
--   PROBABILITY                                 numeric,
--   EXPECTED_REVENUE                            numeric(18, 2),
--   TOTAL_OPPORTUNITY_QUANTITY                  numeric,
--   CLOSE_DATE                                  DATE,
--   TYPE                                        VARCHAR(765),
--   NEXT_STEP                                   VARCHAR(765),
--   LEAD_SOURCE                                 VARCHAR(765),
--   IS_CLOSED                                   BOOLEAN,
--   IS_WON                                      BOOLEAN,
--   FORECAST_CATEGORY                           VARCHAR(120),
--   FORECAST_CATEGORY_NAME                      VARCHAR(765),
--   CURRENCY_ISO_CODE                           VARCHAR(9),
--   CAMPAIGN_ID                                 VARCHAR(18),
--   HAS_OPPORTUNITY_LINE_ITEM                   BOOLEAN,
--   IS_SPLIT                                    BOOLEAN,
--   PRICEBOOK_2_ID                              VARCHAR(18),
--   OWNER_ID                                    VARCHAR(18),
--   CREATED_DATE                                TIMESTAMPTZ,
--   CREATED_BY_ID                               VARCHAR(18),
--   LAST_MODIFIED_DATE                          TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                         VARCHAR(18),
--   SYSTEM_MODSTAMP                             TIMESTAMPTZ,
--   LAST_ACTIVITY_DATE                          DATE,
--   PUSH_COUNT                                  numeric,
--   LAST_STAGE_CHANGE_DATE                      TIMESTAMPTZ,
--   CONTACT_ID                                  VARCHAR(18),
--   LAST_VIEWED_DATE                            TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                        TIMESTAMPTZ,
--   PARTNER_ACCOUNT_ID                          VARCHAR(18),
--   CONNECTION_RECEIVED_ID                      VARCHAR(18),
--   CONNECTION_SENT_ID                          VARCHAR(18),
--   SYNCED_QUOTE_ID                             VARCHAR(18),
--   HAS_OPEN_ACTIVITY                           BOOLEAN,
--   HAS_OVERDUE_TASK                            BOOLEAN,
--   LAST_AMOUNT_CHANGED_HISTORY_ID              VARCHAR(18),
--   LAST_CLOSE_DATE_CHANGED_HISTORY_ID          VARCHAR(18),
--   AGE_OF_ROOF_C                               VARCHAR(765),
--   ALLIANCE_PROGRAM_LEAD_C                     BOOLEAN,
--   AUTO_ASSIGNMENT_C                           BOOLEAN,
--   FINANCIAL_CLOSE_DATE_C                      DATE,
--   BEST_LEASE_PROPOSAL_C                       VARCHAR(450),
--   BEST_PPA_PROPOSAL_C                         VARCHAR(450),
--   BEST_TIME_TO_CALL_C                         VARCHAR(450),
--   CLICK_SHIFT_ID_C                            VARCHAR(765),
--   RELATED_PARTY_TRANSACTION_C                 BOOLEAN,
--   PR_2_APPROVAL_DATE_C                        DATE,
--   CLOSURE_DEAL_RISK_LEVEL_C                   VARCHAR(765),
--   FINAL_INSPECTION_SCHEDULE_DATE_C            DATE,
--   FACILITY_ADDRESS_1_C                        VARCHAR(765),
--   FACILITY_ADDRESS_2_C                        VARCHAR(765),
--   FINANCING_C                                 VARCHAR(675),
--   FACILITY_CITY_1_C                           VARCHAR(765),
--   QUALITY_INSPECTION_OPT_IN_C                 BOOLEAN,
--   INSPECTION_DATE_C                           DATE,
--   INSTALLATION_DATE_C                         DATE,
--   INTERNAL_COMMENTS_C                         VARCHAR(96000),
--   CUSTOMER_SATISFACTION_SURVEY_OPT_IN_C       BOOLEAN,
--   LEAD_WEB_FORM_DETAILS_C                     VARCHAR(765),
--   MONTHLY_ELECTRICITY_BILL_C                  numeric,
--   MARKETING_OPT_IN_C                          BOOLEAN,
--   OPPORTUNITY_STATUS_C                        VARCHAR(765),
--   AMENDMENT_REQUESTED_DATE_C                  DATE,
--   REASON_WON_LOST_C                           VARCHAR(765),
--   REGION_C                                    VARCHAR(765),
--   WARRANTY_SIGNED_ITALY_C                     BOOLEAN,
--   SYSTEM_SIZE_KW_P_C                          numeric,
--   HEAR_ABOUT_US_C                             VARCHAR(765),
--   UNSHADED_ROOF_C                             BOOLEAN,
--   GROUND_OR_ROOF_SPACE_C                      VARCHAR(300),
--   HOMES_BUILT_PER_YEAR_C                      VARCHAR(765),
--   FACILITY_STATE_1_C                          VARCHAR(765),
--   LEAD_REFERRAL_NAME_C                        VARCHAR(240),
--   LOCATION_OF_INSTALLATION_C                  VARCHAR(765),
--   MOUNTING_SYSTEM_C                           VARCHAR(765),
--   NUMBER_OF_SITES_TO_INSTALL_SOLAR_C          VARCHAR(765),
--   NUMBER_OF_STATES_C                          VARCHAR(765),
--   OWNERSHIP_C                                 VARCHAR(765),
--   FACILITY_ZIP_1_C                            VARCHAR(765),
--   ROOF_MATERIAL_C                             VARCHAR(765),
--   ROOF_TYPE_C                                 VARCHAR(765),
--   PARTNER_ACCOUNT_ID_C                        VARCHAR(18),
--   FIRST_CONTACT_C                             numeric,
--   HOW_DO_YOU_BUY_YOUR_MODULES_C               VARCHAR(75),
--   INITIAL_SITE_AUDIT_RESPONSE_DATE_C          DATE,
--   SSO_FIRST_CONTACT_DATE_TIME_LEAD_C          VARCHAR(297),
--   INTEGRATION_ID_C                            VARCHAR(60),
--   INVERTOR_C                                  VARCHAR(765),
--   PRIMARY_CONTACT_C                           VARCHAR(18),
--   RSM_EMAIL_C                                 VARCHAR(240),
--   ROOF_HEIGHT_C                               numeric,
--   ROOF_SLOPE_C                                numeric,
--   THEATER_C                                   VARCHAR(765),
--   QUANTITY_1_C                                VARCHAR(765),
--   MOTIVATION_FOR_SOLAR_C                      VARCHAR(765),
--   FIRST_CONTACTED_DATE_TIME_C                 TIMESTAMPTZ,
--   UPP_MARKET_TYPE_C                           VARCHAR(765),
--   TRANSFERRED_BY_C                            VARCHAR(765),
--   DE_BOOKED_C                                 BOOLEAN,
--   EPA_GENERATED_C                             DATE,
--   LEAD_MANUFACTURER_C                         VARCHAR(765),
--   PO_RECEIPT_DATE_C                           DATE,
--   GSA_SCHEDULE_CONTRACT_C                     BOOLEAN,
--   PV_TYPE_C                                   VARCHAR(765),
--   RSMNAME_C                                   VARCHAR(18),
--   HOW_LONG_HAVE_YOU_OWNED_YOUR_HOME_C         VARCHAR(765),
--   CLOSED_TEXT_C                               numeric,
--   WARRANTY_CARD_RECEIVED_C                    BOOLEAN,
--   CURRENTLY_LOOKING_AT_OTHER_SOLAR_PROVIDE_C  VARCHAR(765),
--   AVERAGE_MONTHLY_ELECTRICITY_BILL_C          VARCHAR(765),
--   LEGACY_LAST_MODIFIED_DATE_C                 TIMESTAMPTZ,
--   LEGACY_CREATED_DATE_C                       TIMESTAMPTZ,
--   BUSINESS_UNIT_C                             VARCHAR(765),
--   PROJECTED_DELIVERY_DATE_C                   DATE,
--   QUALIFIED_DATE_C                            DATE,
--   VISIT_COMPLETED_DATE_C                      DATE,
--   FUTURE_FOLLOW_UP_DATE_C                     DATE,
--   OPPORTUNITY_CONTACTED_DATE_C                DATE,
--   LEAD_TYPE_C                                 VARCHAR(765),
--   BALANCE_INVOICE_NUMBER_C                    VARCHAR(150),
--   DOWN_PAYMENT_INVOICE_NUMBER_C               VARCHAR(765),
--   QUOTE_NUMBER_C                              VARCHAR(150),
--   SALES_ORDER_NUMBER_C                        VARCHAR(765),
--   DELIVERY_DATE_C                             DATE,
--   WEB_COMMENTS_C                              VARCHAR(96000),
--   SP_WEEK_C                                   numeric,
--   LEAD_SP_WEEK_C                              numeric,
--   OPPORTUNITY_CREATED_DATE_TEXT_C             VARCHAR(24),
--   REFERRAL_PROGRAM_STATUS_C                   VARCHAR(765),
--   PROJECT_STAGE_C                             VARCHAR(765),
--   CLOSED_WON_DATE_C                           DATE,
--   OPPORTUNITY_PASSED_VIA_C                    VARCHAR(765),
--   REGISTRY_PRESENCE_C                         VARCHAR(765),
--   QUOTE_NUMBER_SUFFIX_C                       VARCHAR(90),
--   ROOF_ORIENTATION_C                          VARCHAR(765),
--   EU_PARTNER_ACCOUNT_C                        VARCHAR(18),
--   COMMERCIAL_PROJECT_NUM_C                    VARCHAR(90),
--   CRSM_C                                      VARCHAR(18),
--   INVERTER_2_C                                VARCHAR(765),
--   INVERTER_3_C                                VARCHAR(765),
--   FINANCING_STATUS_C                          VARCHAR(765),
--   FINANCING_APPLICATION_SUBMITTED_DATE_C      DATE,
--   FINANCING_OPTIONS_PROVIDED_DATE_C           DATE,
--   FINANCING_IN_PLACE_DATE_C                   DATE,
--   SITE_AUDIT_REVIEW_STATUS_C                  VARCHAR(765),
--   SITE_AUDIT_FORM_RECEIVED_C                  DATE,
--   SSO_START_DATE_C                            DATE,
--   SA_TIER_2_REVIEW_C                          DATE,
--   PROJECT_ENGINEERING_REVIEW_C                BOOLEAN,
--   SUBMITTER_C                                 VARCHAR(18),
--   REVIEWER_C                                  VARCHAR(108),
--   COMMENTS_C                                  VARCHAR(300),
--   REVISION_C                                  numeric,
--   PV_FAST_PV_SIM_C                            BOOLEAN,
--   BOM_SENT_DATE_C                             DATE,
--   AMENDMENT_RECEIVED_DATE_C                   DATE,
--   SEND_FINANCING_ALERT_C                      BOOLEAN,
--   INSPECTION_REPORT_SENT_C                    DATE,
--   SI_INSPECTOR_C                              VARCHAR(18),
--   SI_COMMENTS_C                               VARCHAR(12000),
--   FINAL_INSP_REPORT_SENT_C                    DATE,
--   EPA_REQUESTED_C                             DATE,
--   DEPOSIT_RECEIVED_C                          DATE,
--   MAP_URL_C                                   VARCHAR(765),
--   SATELLITE_URL_C                             VARCHAR(765),
--   REBATE_CONFIRMED_DATE_C                     DATE,
--   SITE_AUDIT_COMPLETE_C                       DATE,
--   SPECIAL_HANDLING_C                          VARCHAR(765),
--   TIME_OF_INSTALLATION_C                      VARCHAR(120),
--   PROJECT_MARGIN_RISK_LEVEL_C                 VARCHAR(765),
--   ACTIONS_REMAINING_TO_CLOSE_DEAL_C           VARCHAR(96000),
--   ELOQUA_CONTACT_ID_C                         VARCHAR(765),
--   GOOGLE_CLICK_ID_C                           VARCHAR(765),
--   REFERRED_BY_1_C                             VARCHAR(18),
--   REFERRED_BY_EMAIL_C                         VARCHAR(11700),
--   REFERRED_BY_FIRST_NAME_C                    VARCHAR(120),
--   REFERRED_BY_LAST_NAME_C                     VARCHAR(240),
--   PRICE_CONCESSION_C                          numeric(18, 2),
--   BINDING_OFFER_ACCEPTED_DATE_C               DATE,
--   BOND_AMOUNT_C                               numeric(14, 2),
--   BUDGETARY_PRICING_AGREED_ON_DATE_C          DATE,
--   COD_PAC_DATE_REASON_C                       VARCHAR(765),
--   CENTS_K_WH_C                                numeric(18, 2),
--   CLOSURE_DEAL_RISKS_C                        VARCHAR(96000),
--   CONSTRUCTION_COMPLETION_DATE_CONSTRUCTION_C DATE,
--   CONTRACT_CLOSED_DATE_C                      DATE,
--   CONTRACT_TYPE_C                             VARCHAR(765),
--   CONTRIBUTION_MARGIN_PER_C                   numeric,
--   CONTRIBUTION_MARGIN_C                       numeric(18, 2),
--   CONVERTED_C                                 BOOLEAN,
--   COUNT_OF_SITES_C                            numeric,
--   COUNTRY_MANAGER_SIGNATURE_DATE_C            DATE,
--   PRICING_EXCEPTION_COMMENTS_C                VARCHAR(98304),
--   CUSTOMER_FUNDING_TYPE_C                     VARCHAR(765),
--   CUSTOMER_PROJECT_BUDGET_C                   numeric(11, 2),
--   DATE_MUST_BE_COMPLETED_BY_C                 DATE,
--   SALESPERSON_COMMITMENT_C                    VARCHAR(765),
--   DEADLINE_DATE_C                             DATE,
--   DEADLINE_REASON_C                           VARCHAR(765),
--   EE_POTENTIAL_C                              VARCHAR(765),
--   ESCALATOR_C                                 VARCHAR(765),
--   ESTIMATE_PARK_SALES_TRANSFER_DATE_C         DATE,
--   ESTIMATED_COMPLETION_DATE_C                 DATE,
--   ENTITY_NAME_C                               VARCHAR(765),
--   ENTITY_TYPE_C                               VARCHAR(750),
--   EXPECTED_COMMERCIAL_OPERATION_DATE_C        DATE,
--   EXPECTED_PROJECT_START_DATE_C               DATE,
--   EXPECTING_DATE_INCO_TERM_DATE_C             DATE,
--   FINANCIER_CONTRACT_CLOSED_DATE_C            DATE,
--   REFERRAL_PROGRAM_C                          VARCHAR(765),
--   FINANCING_IN_PLACE_C                        BOOLEAN,
--   HOW_DID_YOU_HEAR_ABOUT_US_C                 VARCHAR(300),
--   INCENTIVE_REBATE_RESERVATION_C              VARCHAR(765),
--   INDUSTRY_C                                  VARCHAR(765),
--   DEALER_SELECTION_C                          VARCHAR(18),
--   INSTALLATION_BY_C                           VARCHAR(765),
--   INTERCONNECTION_APPLICATION_SUBMITTED_C     DATE,
--   INTERCONNECTION_APPROVED_C                  DATE,
--   LEAD_QUALIFICATION_NOTES_C                  VARCHAR(96000),
--   LEAD_SOURCE_C                               VARCHAR(765),
--   LETTER_OF_CREDIT_C                          VARCHAR(765),
--   MAIN_COMPETITOR_OTHER_C                     VARCHAR(765),
--   OWNER_EMAIL_C                               VARCHAR(240),
--   DEVELOPMENT_MILESTONES_C                    VARCHAR(15000),
--   MY_POSITION_VS_COMPETITION_C                VARCHAR(96000),
--   NAME_C                                      VARCHAR(60),
--   O_M_SERVICE_AGREEMENT_LENGTH_YRS_C          numeric,
--   OPPORTUNITY_DESCRIPTION_C                   VARCHAR(765),
--   OPPORTUNITY_NUMBER_SYS_C                    VARCHAR(36),
--   OPPORTUNITY_NUMBER_C                        VARCHAR(90),
--   OPPORTUNITY_TYPE_C                          VARCHAR(765),
--   ORACLE_ORDER_NUMBER_C                       VARCHAR(150),
--   ORACLE_PROJECT_NUMBER_C                     VARCHAR(54),
--   ORDER_SUBMITTED_FOR_BOOKING_DATE_C          DATE,
--   CUSTOMER_TYPE_C                             VARCHAR(765),
--   MAIN_COMPETITOR_C                           VARCHAR(765),
--   PROJECT_ABANDONED_C                         VARCHAR(765),
--   ANALYSIS_PROVIDED_C                         DATE,
--   ANALYST_LEVEL_OF_EFFORT_C                   VARCHAR(765),
--   FINANCING_NOTES_C                           VARCHAR(98304),
--   PERMIT_APPROVED_C                           DATE,
--   PERMIT_SUBMITTED_C                          DATE,
--   PERMITTING_C                                VARCHAR(765),
--   PRODUCT_INTEREST_C                          VARCHAR(765),
--   PROJECT_MANAGER_C                           VARCHAR(765),
--   PROJECT_MARGIN_RISKS_C                      VARCHAR(96000),
--   PROPOSAL_KICK_OFF_MEETING_DATE_C            DATE,
--   PRIMARY_CONTACT_SURVEY_OPT_IN_FLAG_C        BOOLEAN,
--   REASON_WON_LOST_COMMENTS_C                  VARCHAR(765),
--   LOST_TO_COMPETITOR_C                        VARCHAR(765),
--   RED_FLAGS_C                                 VARCHAR(96000),
--   REFERRED_BY_C                               VARCHAR(765),
--   RESERVATION_TARGET_DATE_C                   DATE,
--   SPIFF_C                                     numeric(5, 2),
--   SPWR_POWER_DENSITY_VALUED_C                 VARCHAR(765),
--   SALES_ANALYST_C                             VARCHAR(18),
--   INTAKE_FORM_RECEIVED_C                      DATE,
--   SALES_STEPS_C                               VARCHAR(765),
--   DEALERSHIP_REP_C                            VARCHAR(765),
--   SELLING_STRATEGY_C                          VARCHAR(96000),
--   SHIPPING_INCO_TERM_DATE_C                   DATE,
--   SHIPPING_INCO_TERMS_C                       VARCHAR(765),
--   REFERRAL_PAYMENT_STATUS_C                   VARCHAR(765),
--   SITE_AUDIT_STATUS_C                         VARCHAR(765),
--   OFF_GRID_C                                  BOOLEAN,
--   SITE_CONTROL_C                              DATE,
--   INTAKE_FORM_SENT_C                          DATE,
--   STRENGTHS_C                                 VARCHAR(96000),
--   SUN_POWER_ROLE_C                            VARCHAR(765),
--   REASON_CODES_C                              VARCHAR(765),
--   PRICING_EXCEPTION_TABLE_C                   VARCHAR(98304),
--   SYSTEM_SIZE_K_WAC_C                         numeric,
--   COMMERCIAL_OPERATION_DATE_C                 DATE,
--   TECHNICAL_QUESTIONNAIRE_RECEIVED_DATE_C     DATE,
--   TECHNICAL_QUESTIONNAIRE_REQUIRED_C          BOOLEAN,
--   TERM_YRS_C                                  numeric,
--   THIRD_PARTY_ACCEPTABLE_C                    VARCHAR(765),
--   PORTFOLIO_DOCUMENTS_C                       VARCHAR(765),
--   PROJECT_DOCUMENTS_C                         VARCHAR(765),
--   TYPE_OF_INSTALLATION_C                      VARCHAR(765),
--   UNIDENTIFIED_C                              DATE,
--   UNIT_PRICE_K_W_C                            numeric,
--   LEASE_PLACED_IN_SERVICE_C                   BOOLEAN,
--   LEASE_C                                     BOOLEAN,
--   WAGE_REQUIREMENTS_C                         VARCHAR(765),
--   WEB_LEAD_SOURCE_C                           VARCHAR(765),
--   X_75_MEETING_DATE_C                         DATE,
--   DATE_BUILDING_PERMIT_RECEIVED_PROMISED_C    numeric(18, 2),
--   REVENUE_QTR_C                               DATE,
--   OLD_SYS_OPPORTUNITY_NUMBER_C                VARCHAR(150),
--   RLC_TYPE_C                                  VARCHAR(765),
--   OPPORTUNITY_NUMBER_1_C                      VARCHAR(90),
--   REQUEST_FOR_INFORMATION_C                   VARCHAR(765),
--   ALREADY_RECEIVING_QUOTES_C                  VARCHAR(765),
--   REQUEST_DEALER_QUOTE_C                      VARCHAR(765),
--   OPT_OUT_C                                   BOOLEAN,
--   INSTALLATION_COMPLETED_DATE_C               DATE,
--   INTERNAL_NTP_DATE_C                         DATE,
--   CONTRACT_STATUS_C                           VARCHAR(300),
--   MOUNTING_SYSTEM_1_C                         VARCHAR(765),
--   COUNTRY_C                                   VARCHAR(765),
--   WARRANTY_C                                  VARCHAR(765),
--   GROUNDING_C                                 VARCHAR(765),
--   ZONE_MONITORING_C                           VARCHAR(765),
--   UTILITY_VOLTAGE_C                           VARCHAR(765),
--   QUANTITY_2_C                                VARCHAR(765),
--   QUANTITY_3_C                                VARCHAR(765),
--   ARRA_COMPLIANCE_C                           VARCHAR(765),
--   SEND_MAIL_C                                 BOOLEAN,
--   ENVIRONMENTAL_REQUEST_FILED_C               DATE,
--   ENVIRONMENTAL_REQUEST_APPROVED_C            DATE,
--   NEXT_MEETING_WITH_AUTHORITIES_C             DATE,
--   APPEAL_PERIOD_START_DATE_C                  DATE,
--   PHASE_II_STUDY_FILED_1_C                    DATE,
--   PHASE_II_STUDY_RECEIVED_1_C                 DATE,
--   PHASE_II_STUDY_ACCEPTED_1_C                 DATE,
--   ORIGINATION_C                               VARCHAR(765),
--   REGION_1_C                                  VARCHAR(765),
--   SUB_REGION_C                                VARCHAR(765),
--   ENTERED_DATE_IN_ORACLE_C                    DATE,
--   GEOLOGICAL_REPORT_PROVIDED_C                VARCHAR(765),
--   ENVIRONMENTAL_STUDY_PROVIDED_C              VARCHAR(765),
--   ELECTRICAL_SCHEME_PROVIDED_C                VARCHAR(765),
--   EXPIRY_DATE_FOR_PHASE_II_ACCEPTANCE_C       DATE,
--   CLOSING_PERMITTING_PERIOD_C                 DATE,
--   GCLID_C                                     VARCHAR(765),
--   DEALER_SHARE_C                              numeric(18, 2),
--   REBATE_ADMINISTERED_C                       DATE,
--   BASIS_OF_REBATE_C                           VARCHAR(765),
--   SUN_POWER_SHARE_C                           numeric(18, 2),
--   POINT_OF_CONNECTION_EXISTS_C                VARCHAR(765),
--   PRICE_PER_ACRE_HA_C                         numeric,
--   ENVIRONMENTAL_REQUEST_FILED_FORECASTED_C    BOOLEAN,
--   ENVIRONMENTAL_REQUEST_APPROVED_FORECSTD_C   BOOLEAN,
--   APPEAL_PERIOD_START_DATE_FORECASTED_C       BOOLEAN,
--   PHASE_II_STUDY_FILED_FORECASTED_C           BOOLEAN,
--   PHASE_II_STUDY_RECEIVED_FORECASTED_C        BOOLEAN,
--   PHASE_II_STUDY_ACCEPTED_FORECASTED_C        BOOLEAN,
--   TOTAL_LAND_SIZE_C                           numeric,
--   AVERAGE_USABLE_LAND_PERCENTAGE_C            numeric,
--   PRICING_EXCEPTION_STATUS_C                  VARCHAR(765),
--   APPEAL_PERIOD_END_DATE_1_C                  DATE,
--   CONVERTED_LEAD_RECORD_TYPE_C                VARCHAR(150),
--   OPPORTUNITY_OWNER_S_MANAGER_C               VARCHAR(240),
--   COST_PRICING_QUARTER_C                      VARCHAR(765),
--   PV_COST_PRICING_C                           numeric(18, 4),
--   PACKAGE_C                                   VARCHAR(765),
--   ROOF_SQ_FT_C                                numeric,
--   NET_COST_C                                  numeric(11, 2),
--   DOWN_PAYMENT_C                              numeric(11, 2),
--   MONTHLY_COST_C                              numeric(11, 2),
--   MONTHLY_SAVINGS_C                           numeric(11, 2),
--   TOTAL_SAVINGS_C                             numeric(11, 2),
--   NOT_DRIVING_C                               numeric,
--   ACRES_OF_TREES_C                            numeric,
--   O_M_PAYMENT_TERMS_C                         VARCHAR(765),
--   X_3_RD_PARTY_OPTION_C                       VARCHAR(765),
--   CONVERTED_LEAD_OPP_OWNER_C                  VARCHAR(18),
--   DEAL_LOST_DATE_C                            DATE,
--   SALES_AE_APPROVED_DATE_C                    DATE,
--   ADDRESS_URL_C                               VARCHAR(765),
--   PARTNER_PORTAL_REGISTRATION_C               BOOLEAN,
--   REGIONAL_COMMITMENT_C                       VARCHAR(765),
--   WEB_CONTENT_DOWNLOADED_C                    VARCHAR(6000),
--   APPOINTMENT_DATE_TIME_C                     TIMESTAMPTZ,
--   FLASH_TEST_DATA_REQUEST_C                   BOOLEAN,
--   FLASH_TEST_DATA_REQUEST_DATE_C              DATE,
--   PSR_EMAIL_C                                 VARCHAR(240),
--   CAMPAIGN_SOURCE_DATE_C                      TIMESTAMPTZ,
--   ACTUAL_CLOSE_DATE_C                         TIMESTAMPTZ,
--   SSO_REQUESTED_DATE_C                        TIMESTAMPTZ,
--   INSTALLER_C                                 VARCHAR(18),
--   REVENUE_TREATMENT_C                         VARCHAR(765),
--   CONFIDENCE_LEVEL_C                          VARCHAR(765),
--   PO_C                                        VARCHAR(150),
--   PO_AMOUNT_C                                 numeric(18, 2),
--   INSTALLATION_INVOICE_C                      numeric(18, 2),
--   INTERCONNECTION_INVOICE_C                   numeric(18, 2),
--   PARTNER_SITE_AUDIT_DATE_C                   DATE,
--   PARTNER_SITE_AUDIT_DATE_PROMISED_C          DATE,
--   MODULE_MODEL_NUMBER_C                       VARCHAR(150),
--   INVERTER_MODEL_ACTUAL_C                     VARCHAR(150),
--   INVERTER_MANUFACTURER_ACTUAL_C              VARCHAR(96000),
--   INSTALLATION_DATE_PROMISED_C                DATE,
--   SCM_PV_PROMISED_C                           DATE,
--   DATE_PV_SHIPPED_C                           DATE,
--   DATE_SYSTEM_OPERATING_C                     DATE,
--   SOLAR_PERMIT_NUMBER_C                       VARCHAR(150),
--   STATE_LOCAL_INCENTIVES_REQUIRED_ON_DEAL_C   VARCHAR(765),
--   DATE_PTO_LETTER_RECEIVED_PROMISED_C         DATE,
--   DATE_ON_PTO_LETTER_C                        DATE,
--   SALES_ORDER_DATE_C                          DATE,
--   INVOICE_AMOUNT_C                            numeric(18, 2),
--   CONTRACT_NUMBER_C                           VARCHAR(150),
--   MODULE_QUANTITY_C                           numeric,
--   DATE_SYSTEM_OPERATING_PROMISED_C            numeric(18, 2),
--   INSTALLER_CONTACT_C                         VARCHAR(18),
--   DESIGN_SERVICE_C                            BOOLEAN,
--   CHECK_PARTNER_C                             BOOLEAN,
--   EXPECTED_PO_DATE_C                          DATE,
--   OPPORTUNITY_CONTACTED_DATE_TIME_C           TIMESTAMPTZ,
--   CONSULTATION_TYPE_C                         VARCHAR(765),
--   APPROVED_TO_SEND_PSR_C                      VARCHAR(765),
--   NET_PRESENT_VALUE_C                         numeric(18, 2),
--   CREDIT_APPLICATION_ID_C                     VARCHAR(108),
--   CREDIT_APPLICATION_NUMBER_C                 VARCHAR(108),
--   CREDIT_APPLICATION_STATUS_MESSAGE_C         VARCHAR(765),
--   CREDIT_APPLICATION_STATUS_C                 VARCHAR(750),
--   DEGRADATION_RATE_C                          numeric,
--   IS_AUTO_ASSIGN_C                            BOOLEAN,
--   PASS_SLA_C                                  VARCHAR(765),
--   REQUIRES_MANUAL_ASSIGNMENT_C                BOOLEAN,
--   SFDC_TIMELY_UPDATE_STAGES_C                 VARCHAR(4099),
--   SFDC_TIMELY_UPDATES_C                       numeric,
--   DEALER_ASSIGNMENT_STATUS_C                  VARCHAR(765),
--   DID_YOU_APPLY_FOR_FINANCING_C               BOOLEAN,
--   DEALER_ASSIGNMENT_DATE_C                    TIMESTAMPTZ,
--   RES_OPP_RECIPIENT_CC_EMAIL_C                VARCHAR(240),
--   FINANCING_2_C                               VARCHAR(765),
--   REASON_WON_LOST_FR_C                        VARCHAR(765),
--   DECLINE_REASON_C                            VARCHAR(765),
--   SHADING_C                                   VARCHAR(765),
--   MEETING_LINK_C                              VARCHAR(765),
--   APPOINTMENT_TIME_C                          VARCHAR(765),
--   APPOINTMENT_DATE_C                          DATE,
--   SENT_WELCOME_EMAIL_C                        BOOLEAN,
--   NON_STANDARD_TERMS_CONDITIONS_C             VARCHAR(15000),
--   SENT_ENERGY_PRODUCING_EMAIL_C               BOOLEAN,
--   APPROVED_CREDIT_AMOUNT_C                    numeric(18),
--   NMI_C                                       VARCHAR(54),
--   DESIGN_PHOTO_C                              VARCHAR(393216),
--   DESIGN_STATUS_C                             VARCHAR(765),
--   CONSTRUCTION_TYPE_C                         VARCHAR(765),
--   NUMBER_OF_METERS_C                          numeric,
--   CUSTOMER_RESPONSE_COMMENTS_C                VARCHAR(393216),
--   FRIEND_ID_C                                 VARCHAR(60),
--   SEND_SOCIAL_ANNEX_UPDATE_C                  BOOLEAN,
--   SHARER_ID_C                                 VARCHAR(60),
--   STAT_ID_C                                   VARCHAR(765),
--   IS_CORRECT_DESIGN_INCLUDED_C                BOOLEAN,
--   PROJECT_COORDINATOR_C                       VARCHAR(18),
--   ALL_PERMITS_APPROVED_C                      DATE,
--   PERMIT_APPROVED_FROM_LEAD_AGENCY_C          DATE,
--   PERMIT_APPLICATION_SUBMITTED_TO_LEAD_AGE_C  DATE,
--   SOLAR_CUT_OFF_DATE_C                        DATE,
--   POWER_PLANT_LAND_EXCLUSIVITY_C              DATE,
--   PROJECT_DEVELOPMENT_AGREEMENT_SIGNED_C      DATE,
--   PROJECT_DEVELOPMENT_MOU_SIGNED_C            DATE,
--   PPA_FIT_BID_C                               DATE,
--   PPA_FIT_SIGNED_C                            DATE,
--   FINANCING_TYPE_C                            VARCHAR(765),
--   SPWR_EQUITY_POISTION_C                      VARCHAR(765),
--   DEVELOPER_C                                 VARCHAR(765),
--   DEVELOPMENT_MODEL_C                         VARCHAR(765),
--   APICREATED_DATE_C                           DATE,
--   APICREATED_VERSION_C                        VARCHAR(30),
--   APIID_C                                     VARCHAR(90),
--   APILAST_MODIFIED_NAME_C                     VARCHAR(75),
--   APILAST_UPDATED_DATE_C                      DATE,
--   APILAST_UPDATED_VERSION_C                   VARCHAR(30),
--   AUTHORITY_C                                 VARCHAR(765),
--   SYNC_WITH_SPECTRUM_C                        VARCHAR(765),
--   NOT_SENT_TO_FIVE_9_C                        BOOLEAN,
--   API_ID_C                                    VARCHAR(90),
--   SYSTEM_TYPE_C                               VARCHAR(765),
--   SYSTEM_WARRANTY_C                           VARCHAR(765),
--   INVERTER_WARRANTY_C                         VARCHAR(765),
--   O_M_BUILDING_C                              VARCHAR(765),
--   ALR_ASSIGNMENT_AUDIT_TRAIL_C                VARCHAR(393216),
--   IS_EXCLUDED_FROM_SLA_SCORE_C                BOOLEAN,
--   SOLAR_ADVISOR_NOTES_FOR_EC_C                VARCHAR(98304),
--   NEW_RESIDENTIAL_OPPS_NOTIFICATION_C         BOOLEAN,
--   PRIMARY_RES_OPP_RECIP_EMAIL_C               VARCHAR(240),
--   IS_THIS_AN_INVESTMENT_PROPERTY_C            BOOLEAN,
--   ARE_THERE_OTHER_DECISION_MAKERS_C           VARCHAR(765),
--   CUSTOMER_FINANCIAL_PREFERENCE_C             VARCHAR(765),
--   CREDIT_SCORE_C                              VARCHAR(765),
--   CONFIRM_LEGAL_NAME_C_C                      BOOLEAN,
--   DISCOUNTS_FROM_UTILITY_C                    BOOLEAN,
--   EC_OWNER_EMAIL_C                            VARCHAR(240),
--   OWN_LEASE_C                                 VARCHAR(765),
--   LOCATION_OF_INSTALL_C                       VARCHAR(765),
--   FIVE_9_REMINDER_CALL_SENT_C                 BOOLEAN,
--   MANUALLY_REASSIGNED_C                       BOOLEAN,
--   UTILITY_ELECTRIC_PROVIDER_C                 VARCHAR(765),
--   REMINDER_SENT_TO_FIVE_9_C                   TIMESTAMPTZ,
--   CUSTOMER_SELECTION_PROCESS_C                VARCHAR(765),
--   PR_0_NOTES_C                                VARCHAR(393216),
--   PROPOSAL_DUE_DATE_C                         DATE,
--   UTILITY_PROVIDER_C                          VARCHAR(18),
--   PLAN_TYPE_C                                 VARCHAR(765),
--   LOT_NUMBER_C                                VARCHAR(765),
--   QUALIFIED_BY_C                              VARCHAR(18),
--   EXECUTIVE_STAFF_SPONSOR_C                   VARCHAR(765),
--   SUB_STAGE_DATE_C                            DATE,
--   SUB_STAGE_C                                 VARCHAR(765),
--   EPC_REGION_C                                VARCHAR(765),
--   EXPECTED_CLOSE_OF_ESCROW_C                  DATE,
--   PRR_CONTACT_INFO_C                          VARCHAR(765),
--   PRR_DATE_C                                  DATE,
--   DSA_COMPLETION_DATE_C                       DATE,
--   NOTICE_OF_AWARD_DATE_C                      DATE,
--   PRR_STATUS_C                                VARCHAR(765),
--   AVOIDED_COST_OF_POWER_C                     numeric,
--   CUSTOMER_SELECTION_C                        VARCHAR(765),
--   BUDGET_C                                    VARCHAR(765),
--   NEED_C                                      VARCHAR(765),
--   OWNER_CHANGED_DATE_C                        TIMESTAMPTZ,
--   PROJECT_TIMING_C                            VARCHAR(765),
--   TIME_FRAME_C                                VARCHAR(765),
--   K_WH_MONTHLY_AVERAGE_C                      numeric,
--   DISCOUNT_C                                  numeric(18, 2),
--   DISCOUNT_VALID_UNTIL_C                      DATE,
--   COMPETITORS_SELECT_MULTIPLE_C               VARCHAR(4099),
--   RESIDENTIAL_PROJECT_C                       VARCHAR(18),
--   COLLECTED_UTILITY_BILLS_C                   VARCHAR(765),
--   REFUND_C                                    VARCHAR(765),
--   INCENTIVE_STRATEGY_C                        VARCHAR(765),
--   INTERCONNECTION_SECURED_C                   VARCHAR(765),
--   INTERCONNECTION_STRATEGY_C                  VARCHAR(765),
--   PERMIT_STRATEGY_C                           VARCHAR(150),
--   EXTERNAL_ID_C                               VARCHAR(765),
--   APPOINTMENT_NOTIFICATION_DATE_TIME_C        TIMESTAMPTZ,
--   NH_LEASE_CONFIRMATION_EMAIL_SENT_C          BOOLEAN,
--   SPD_ECEMAIL_C                               VARCHAR(240),
--   AHJ_C                                       VARCHAR(18),
--   CODE_YEAR_C                                 VARCHAR(765),
--   FINANCING_STRATEGY_C                        VARCHAR(765),
--   INTERCONNECTION_TYPE_C                      VARCHAR(765),
--   NUMBER_OF_BUILDINGS_C                       VARCHAR(765),
--   NUMBER_OF_CARPORT_CANOPIES_C                VARCHAR(765),
--   NUMBER_OF_UNITS_C                           VARCHAR(765),
--   NUMBER_OF_COVERED_PARKING_SPACES_C          VARCHAR(765),
--   PROBABILITY_OF_WINNING_THE_BID_C            numeric,
--   PRODUCT_TYPE_C                              VARCHAR(4099),
--   RINGDNA_HAS_OPTED_OUT_OF_SMS_2_C            BOOLEAN,
--   REQUIRED_T_24_PRICE_C                       VARCHAR(765),
--   REQUIRED_T_24_K_W_C                         VARCHAR(765),
--   ROOF_TYPE_NOTES_C                           VARCHAR(98304),
--   SERVICE_VOLTAGE_C                           VARCHAR(765),
--   T_24_INFORMATION_C                          VARCHAR(765),
--   THIRD_PARTY_BILL_MANAGEMENT_C               VARCHAR(765),
--   EST_MARGIN_C                                numeric,
--   PUBLIC_FUNDING_C                            VARCHAR(765),
--   RINGDNA_100_APP_OWNER_EMAIL_C               VARCHAR(240),
--   RINGDNA_100_CALL_ATTEMPTS_C                 numeric,
--   RINGDNA_100_CURRENT_GENERATORS_C            VARCHAR(300),
--   RINGDNA_100_DELIVERY_INSTALLATION_STATUS_C  VARCHAR(765),
--   RINGDNA_100_EMAIL_ATTEMPTS_C                numeric,
--   RINGDNA_100_FIRST_INBOUND_CALL_C            TIMESTAMPTZ,
--   RINGDNA_100_FIRST_OUTBOUND_CALL_C           TIMESTAMPTZ,
--   RINGDNA_100_LAST_EMAIL_ATTEMPT_C            TIMESTAMPTZ,
--   RINGDNA_100_LAST_INBOUND_CALL_C             TIMESTAMPTZ,
--   RINGDNA_100_LAST_OUTBOUND_CALL_C            TIMESTAMPTZ,
--   RINGDNA_100_LEAD_SOURCE_DETAIL_C            VARCHAR(765),
--   RINGDNA_100_LENDING_TREE_EMAIL_FIRST_TIME_C BOOLEAN,
--   RINGDNA_100_MAIN_COMPETITORS_C              VARCHAR(300),
--   RINGDNA_100_ORDER_NUMBER_C                  VARCHAR(24),
--   RINGDNA_100_PREVIOUS_STAGE_C                VARCHAR(765),
--   RINGDNA_100_RESPONSE_TYPE_C                 VARCHAR(765),
--   RINGDNA_100_RING_DNA_CONTEXT_C              BOOLEAN,
--   RINGDNA_100_TIME_TO_FIRST_DIAL_MINUTES_C    numeric,
--   RINGDNA_100_TIME_TO_FIRST_RESPONSE_C        numeric,
--   RINGDNA_100_TRACKING_NUMBER_C               VARCHAR(36),
--   RINGDNA_100_STAGE_OPEN_FIRST_TIME_C         BOOLEAN,
--   LEAD_SOURCE_NOTES_C                         VARCHAR(765),
--   NUMBER_OF_SITES_TO_INSTALL_SOLAR_NUMBER_C   numeric,
--   PROBABILITY_C                               VARCHAR(765),
--   REASON_C                                    VARCHAR(765),
--   SECONDARY_CONTACT_C                         VARCHAR(18),
--   TOTAL_SYSTEM_PRICE_C                        numeric(18),
--   TOTAL_K_W_C                                 numeric,
--   IS_ID_CASH_OPPORTUNITY_C                    BOOLEAN,
--   DSA_SIGNATURE_DATE_C                        DATE,
--   EPC_CONTRACT_BOOKED_DATE_C                  DATE,
--   PROPOSAL_EXPIRATION_DATE_C                  DATE,
--   INCOME_BASED_SOLAR_PROGRAM_C                VARCHAR(765),
--   PLAN_TYPE_LOOKUP_C                          VARCHAR(18),
--   _FIVETRAN_SYNCED                            TIMESTAMPTZ,
--   REFUND_REASON_C                             VARCHAR(765),
--   REQUEST_REFUND_C                            BOOLEAN,
--   _FIVETRAN_DELETED                           BOOLEAN,
--   PROPERTY_USE_CASE_C                         VARCHAR(765),
--   EXPECTED_SITE_LOAD_C                        numeric,
--   NUMBER_OF_STORIES_C                         numeric,
--   BUILDER_INITIAL_SUBMITTAL_DATE_C            DATE,
--   RFI_DUE_DATE_C                              DATE,
--   EXPECTED_TENANT_LOAD_C                      numeric,
--   PREVAILING_WAGE_C                           VARCHAR(765),
--   GRAND_OPENING_DATE_C                        DATE,
--   EXPECTED_COMMON_LOAD_C                      numeric,
--   CARPORTS_1_C                                VARCHAR(4099),
--   UTILITY_CONSIDERATIONS_C                    VARCHAR(765),
--   STORAGE_C                                   VARCHAR(765),
--   OTHER_UTILITY_PROVIDER_C                    VARCHAR(765),
--   PROPOSAL_SENT_DATE_C                        DATE,
--   ELEVATION_C                                 VARCHAR(765),
--   ORTOO_QRA_Q_ASSIGN_LAST_ASSIGNED_DATE_C     TIMESTAMPTZ,
--   ORTOO_QRA_ASSIGNED_FROM_QUEUE_C             VARCHAR(54),
--   ORTOO_QRA_ASSIGNED_FROM_GROUP_C             VARCHAR(54),
--   ACTIVITY_METRIC_ID                          VARCHAR(18),
--   ACTIVITY_METRIC_ROLLUP_ID                   VARCHAR(18),
--   IS_PRIVATE                                  BOOLEAN,
--   IS_ABANDONDED_C                             BOOLEAN,
--   PARTNER_INTRO_EMAIL_CHECK_C                 BOOLEAN,
--   CUSTOMER_LOCAL_END_DATE_TIME_C              VARCHAR(300),
--   CONTRACT_ID                                 VARCHAR(18),
--   REBATE_CONFIRMED_C                          BOOLEAN,
--   COMPETITOR_NAME_C                           VARCHAR(765),
--   APPOINTMENT_EMAIL_NOTIFICATION_RESCHED_C    BOOLEAN,
--   GROSS_MARGIN_C                              numeric(18, 2),
--   PV_COST_SYS_C                               numeric(14, 2),
--   PARTNER_INTRO_EMAIL_SENT_C                  TIMESTAMPTZ,
--   OVERRIDE_SYSTEM_SIZE_C                      BOOLEAN,
--   CALL_OUTCOME_C                              VARCHAR(765),
--   SYSTEM_SIZE_PV_REPORT_C                     numeric,
--   CALL_TRIGGER_C                              BOOLEAN,
--   DUMMY_UPDATE_ON_OPPORTUNITY_C               BOOLEAN,
--   NUMBER_OF_DAYS_TO_THE_CLOSE_DATE_C          numeric,
--   IS_APPROVED_C                               BOOLEAN,
--   SALES_CHANNEL_C                             VARCHAR(765),
--   GROSS_MARGIN_PERCENT_C                      numeric,
--   IS_ASSIGNED_TO_RSM_C                        BOOLEAN,
--   SPD_TERRITORY_C                             VARCHAR(765),
--   SERENGETI_COST_PRICING_C                    numeric(18, 4),
--   APPOINTMENT_NOTIFICATION_RESCHEDULE_C       BOOLEAN,
--   NOT_MANUALLY_UPDATED_C                      BOOLEAN,
--   COMPETITIVE_OFFER_C                         VARCHAR(765),
--   NUMBER_OF_HOMES_IN_COMMUNITY_C              numeric,
--   HD_CREATED_DATE_PLUS_2_MIN_C                TIMESTAMPTZ,
--   PRICE_PER_HA_C                              numeric,
--   TYPE_OF_BUILDING_C                          VARCHAR(765),
--   CHALLENGING_ROOF_C                          VARCHAR(765),
--   TOTAL_PRICE_C                               numeric(18, 2),
--   CUSTOMER_LOCAL_START_DATE_TIME_C            VARCHAR(300),
--   LEAD_ANALYST_C                              VARCHAR(765),
--   FINANCING_APPLICATION_SUBMITTED_C           BOOLEAN
-- );
--  drop table if exists brs.case;
-- create table if not exists brs.CASE
-- (
--   ID                                        VARCHAR(18),
--   IS_DELETED                                BOOLEAN,
--   MASTER_RECORD_ID                          VARCHAR(18),
--   CASE_NUMBER                               VARCHAR(90),
--   ACCOUNT_ID                                VARCHAR(18),
--   SOURCE_ID                                 VARCHAR(18),
--   PARENT_ID                                 VARCHAR(18),
--   SUPPLIED_NAME                             VARCHAR(240),
--   SUPPLIED_EMAIL                            VARCHAR(240),
--   SUPPLIED_PHONE                            VARCHAR(120),
--   SUPPLIED_COMPANY                          VARCHAR(240),
--   TYPE                                      VARCHAR(765),
--   RECORD_TYPE_ID                            VARCHAR(18),
--   STATUS                                    VARCHAR(765),
--   REASON                                    VARCHAR(765),
--   ORIGIN                                    VARCHAR(765),
--   LANGUAGE                                  VARCHAR(120),
--   SUBJECT                                   VARCHAR(765),
--   PRIORITY                                  VARCHAR(765),
--   DESCRIPTION                               VARCHAR(96000),
--   IS_CLOSED                                 BOOLEAN,
--   CLOSED_DATE                               TIMESTAMPTZ,
--   IS_ESCALATED                              BOOLEAN,
--   HAS_COMMENTS_UNREAD_BY_OWNER              BOOLEAN,
--   HAS_SELF_SERVICE_COMMENTS                 BOOLEAN,
--   CURRENCY_ISO_CODE                         VARCHAR(9),
--   OWNER_ID                                  VARCHAR(18),
--   CREATED_DATE                              TIMESTAMPTZ,
--   CREATED_BY_ID                             VARCHAR(18),
--   LAST_MODIFIED_DATE                        TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                       VARCHAR(18),
--   SYSTEM_MODSTAMP                           TIMESTAMPTZ,
--   CONTACT_PHONE                             VARCHAR(120),
--   CONTACT_MOBILE                            VARCHAR(120),
--   CONTACT_EMAIL                             VARCHAR(240),
--   CONTACT_FAX                               VARCHAR(120),
--   COMMENTS                                  VARCHAR(4000),
--   LAST_VIEWED_DATE                          TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                      TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID                    VARCHAR(18),
--   CONNECTION_SENT_ID                        VARCHAR(18),
--   ACTIONS_TAKEN_BY_CLIENT_OR_O_M_C          VARCHAR(765),
--   PARTNER_NAME_C                            VARCHAR(18),
--   BUSINESS_UNIT_C                           VARCHAR(765),
--   CAPANUMBER_C                              VARCHAR(54),
--   CAPA_C                                    BOOLEAN,
--   CATEGORY_C                                VARCHAR(765),
--   COMPLAINT_TOWARDS_C                       VARCHAR(765),
--   CREDIT_MEMO_NUM_C                         VARCHAR(60),
--   CUSTOMER_COMPLAINT_NUM_C                  VARCHAR(54),
--   DEBIT_MEMO_NUM_C                          VARCHAR(60),
--   DISPOSITION_C                             VARCHAR(765),
--   ENERGY_OUTPUT_AFFECTED_C                  BOOLEAN,
--   ENGINEERING_REQ_NUM_C                     VARCHAR(36),
--   FFR_DATE_C                                DATE,
--   FFR_LOCATION_C                            VARCHAR(240),
--   FFR_SEVERITY_C                            VARCHAR(765),
--   FFR_SHORT_DESCRIPTION_C                   VARCHAR(240),
--   FAILURE_ANALYSIS_ANALYST_C                VARCHAR(18),
--   FAILURE_ANALYSIS_C                        BOOLEAN,
--   FAILURE_TYPE_DETAILS_C                    VARCHAR(765),
--   FAILURE_TYPE_NAME_C                       VARCHAR(240),
--   FIELD_RETURN_C                            BOOLEAN,
--   FREIGHT_PAYMENT_C                         VARCHAR(765),
--   HOMEOWNER_NAME_C                          VARCHAR(300),
--   ACTION_TYPE_C                             VARCHAR(765),
--   DESCRIPTION_ENGLISH_TRANSLATION_C         VARCHAR(96000),
--   RSM_C                                     VARCHAR(18),
--   HUMAN_SAFETY_AT_RISK_C                    BOOLEAN,
--   INCIDENT_COMPENSATION_C                   numeric(18, 2),
--   INSTALLATION_DATE_C                       DATE,
--   INVOICE_C                                 VARCHAR(60),
--   JOB_SUPERVISOR_EMAIL_C                    VARCHAR(240),
--   LINK_TO_CAPA_C                            VARCHAR(765),
--   PRODUCT_SUB_CATEGORY_C                    VARCHAR(765),
--   NEXT_COMMITTED_CUSTOMER_UPDATE_C          DATE,
--   NO_FAULT_FORMAL_REPORT_C                  BOOLEAN,
--   OPPORTUNITY_C                             VARCHAR(18),
--   PE_REMARKS_C                              VARCHAR(765),
--   PE_STATUS_C                               VARCHAR(765),
--   PE_C                                      BOOLEAN,
--   PART_C                                    VARCHAR(765),
--   PARTNER_SERVICE_COMPENSATION_C            BOOLEAN,
--   POSSIBLE_REASON_FOR_FAILURE_C             VARCHAR(765),
--   POTENTIAL_LIABILITY_C                     VARCHAR(765),
--   PRODUCT_CATEGORY_C                        VARCHAR(765),
--   PRODUCT_C                                 VARCHAR(765),
--   RMA_DATE_C                                TIMESTAMPTZ,
--   RMA_NUM_C                                 VARCHAR(765),
--   RMA_QUANTITY_C                            numeric,
--   RMA_STATUS_C                              VARCHAR(765),
--   RMA_TYPE_C                                VARCHAR(765),
--   RMA_C                                     BOOLEAN,
--   REGION_C                                  VARCHAR(765),
--   REPLACE_WITH_PART_C                       VARCHAR(765),
--   RETURN_VISIT_REQUIRED_C                   BOOLEAN,
--   SLA_VIOLATION_C                           VARCHAR(765),
--   SERIAL_NUM_C                              VARCHAR(765),
--   SHIPMENT_STATUS_C                         VARCHAR(765),
--   SOLUTION_CUSTOMER_REQUESTING_OR_EXPECTS_C VARCHAR(765),
--   SUB_CATEGORY_C                            VARCHAR(765),
--   SUN_POWER_ACTIONS_TO_CLOSE_C              VARCHAR(765),
--   SUPPLIER_COMMENTS_C                       VARCHAR(765),
--   SUPPLIER_FAILURE_TYPE_C                   VARCHAR(765),
--   TECH_SUPPORT_ISSUE_TYPE_C                 VARCHAR(765),
--   TECH_SUPPORT_QUESTION_CATEGORY_C          VARCHAR(765),
--   TECH_SUPPORT_SUB_ISSUE_C                  VARCHAR(765),
--   TOTAL_VALUE_OF_RETURN_C                   numeric(18, 2),
--   TYPE_OF_FAULT_C                           VARCHAR(765),
--   VAR_DEPT_OWNER_C                          VARCHAR(765),
--   VENDOR_COMMENT_C                          VARCHAR(765),
--   VENDOR_CREDIT_MEMO_NUM_C                  VARCHAR(60),
--   VENDOR_RMA_NUM_C                          VARCHAR(765),
--   VENDOR_RMA_STATUS_C                       VARCHAR(765),
--   VENDOR_C                                  VARCHAR(765),
--   WAREHOUSE_RECEIPT_DATE_C                  TIMESTAMPTZ,
--   WARRANTY_C                                BOOLEAN,
--   X_8_D_REPORT_C                            BOOLEAN,
--   INTEGRATION_ID_C                          VARCHAR(60),
--   RESIDENTIAL_AUTHORIZATION_RECEIVED_C      BOOLEAN,
--   SAF_STATUS_C                              VARCHAR(765),
--   REVISION_NO_C                             VARCHAR(765),
--   PARTNER_ACCOUNT_C                         VARCHAR(18),
--   SPOTS_CASE_NUMBER_C                       VARCHAR(60),
--   APPIRIO_CASE_NUMBER_C                     VARCHAR(90),
--   GLOBAL_HELPDESK_ID_C                      VARCHAR(60),
--   REQUESTED_DATE_C                          DATE,
--   ORIGINATOR_C                              VARCHAR(765),
--   SEVERITY_C                                VARCHAR(765),
--   REQUESTED_DUE_DATE_C                      DATE,
--   DATE_ASSIGNED_TO_APPIRIO_C                TIMESTAMPTZ,
--   DATE_WORK_STARTED_W_APPIRIO_C             TIMESTAMPTZ,
--   DATE_COMPLETED_BY_APPIRIO_C               TIMESTAMPTZ,
--   SP_WEEK_C                                 numeric,
--   LEGACY_CREATED_DATE_C                     TIMESTAMPTZ,
--   CASE_CREATED_DATE_TEXT_C                  VARCHAR(24),
--   HAS_ATTACHMENT_FOR_APPIRIO_C              BOOLEAN,
--   BUG_NUMBER_C                              VARCHAR(765),
--   TARGET_FIX_C                              VARCHAR(765),
--   SMS_VERSION_C                             VARCHAR(765),
--   SERIAL_NUMBERS_OF_REPLACEMENT_C           VARCHAR(765),
--   SMS_TYPE_OF_FAULT_C                       VARCHAR(765),
--   WHEN_C                                    VARCHAR(765),
--   WHERE_C                                   VARCHAR(765),
--   WHAT_C                                    VARCHAR(765),
--   SMS_OTHER_C                               VARCHAR(120),
--   RLC_TYPE_C                                VARCHAR(765),
--   TRACKING_DATE_C                           DATE,
--   DATE_ACKNOWLEDGED_C                       TIMESTAMPTZ,
--   DATE_RECEIVED_C                           TIMESTAMPTZ,
--   STARTED_DATE_C                            DATE,
--   RESOLUTION_C                              VARCHAR(765),
--   IS_COMMISSIONING_C                        BOOLEAN,
--   ACTUAL_TIME_HRS_C                         numeric,
--   INTERNAL_CONTACT_NAME_C                   VARCHAR(18),
--   TARGET_COMPLETION_DATE_C                  DATE,
--   PICK_UP_ADDRESS_OF_FAULTY_UNIT_C          VARCHAR(300),
--   PICK_UP_DATE_C                            DATE,
--   PALLETIZED_C                              VARCHAR(765),
--   CONTACT_PERSON_C                          VARCHAR(300),
--   CONTACT_NUMBER_C                          VARCHAR(120),
--   RETURN_ADDRESS_OF_REPLACEMENT_UNIT_C      VARCHAR(765),
--   RMA_REPLACEMENT_C                         VARCHAR(54),
--   RMA_RETURN_C                              VARCHAR(54),
--   RETURNED_QUANTITY_REPLACEMENT_C           numeric,
--   RETURNED_QUANTITY_RETURN_C                numeric,
--   TYPE_OF_RMA_EXCHANGE_C                    VARCHAR(765),
--   LOCATION_C                                VARCHAR(765),
--   AREA_SALES_MANAGER_C                      VARCHAR(18),
--   DEALER_INSTALLER_EMAIL_C                  VARCHAR(240),
--   MRB_C                                     VARCHAR(54),
--   STAGE_C                                   VARCHAR(765),
--   NEXT_MILESTONE_DATE_C                     DATE,
--   RELEASE_NOTES_C                           VARCHAR(96000),
--   SOLUTION_PLAN_C                           VARCHAR(96000),
--   NON_WARRANTY_C                            BOOLEAN,
--   SUB_INVENTORY_IN_ORACLE_C                 VARCHAR(765),
--   SERIAL_CONTINUED_C                        VARCHAR(96000),
--   TECHNICAL_REVIEW_NOTES_C                  VARCHAR(30000),
--   CRB_REQUIRED_C                            BOOLEAN,
--   TECHNICAL_REVIEW_REQUIRED_C               BOOLEAN,
--   NUMBER_OF_IMPACTED_USERS_C                numeric,
--   IMPACTED_USER_TYPE_C                      VARCHAR(4099),
--   IMPACTED_ENVIRONMENT_C                    VARCHAR(4099),
--   STEPS_TO_RECREATE_C                       VARCHAR(3000),
--   EXPECTED_OUTCOME_C                        VARCHAR(3000),
--   TECHNICAL_OWNER_C                         VARCHAR(18),
--   DEALER_INSTALLER_NOTIFICATION_C           BOOLEAN,
--   CHANGE_TYPE_C                             VARCHAR(4099),
--   SUN_POWER_REVIEWER_C                      VARCHAR(18),
--   P_1_NOTIFICATION_EMAIL_C                  BOOLEAN,
--   P_1_ACKNOWLEDGEMENT_C                     BOOLEAN,
--   P_5_MATURITY_DATE_C                       DATE,
--   P_30_MATURITY_DATE_C                      DATE,
--   P_5_ACKNOWLEDGEMENT_C                     BOOLEAN,
--   P_30_ACKNOWLEDGEMENT_C                    BOOLEAN,
--   P_5_REMINDER_DATE_C                       DATE,
--   P_30_REMINDER_DATE_C                      DATE,
--   RENEGOTIATED_DATE_C                       DATE,
--   P_5_REMINDER_C                            BOOLEAN,
--   P_30_REMINDER_C                           BOOLEAN,
--   P_1_MATURITY_DATE_C                       DATE,
--   COMPLAINT_ACKNOWLEDGEMENT_INFO_C          VARCHAR(96000),
--   REASON_FOR_RENEGOTIATED_DATE_C            VARCHAR(96000),
--   CHANGE_ORDER_REQUIRED_C                   BOOLEAN,
--   ORIGINAL_S_O_C                            VARCHAR(600),
--   PACKING_LIST_C                            VARCHAR(600),
--   CARRIER_C                                 VARCHAR(600),
--   SYSTEM_C                                  VARCHAR(4099),
--   FUNCTIONAL_AREA_C                         VARCHAR(4099),
--   INSTALLATION_DATE_ESTIMATED_C             VARCHAR(150),
--   NOTIFICATION_FOR_UPDATE_C                 BOOLEAN,
--   FIRST_REMINDER_DATE_C                     TIMESTAMPTZ,
--   INVERTER_MODEL_C                          VARCHAR(765),
--   SECOND_REMINDER_DATE_C                    TIMESTAMPTZ,
--   AUDITED_BY_C                              VARCHAR(18),
--   BOM_REQUEST_DATE_TO_UNIRAC_C              DATE,
--   CANCELLED_BY_C                            VARCHAR(765),
--   COMMENTS_C                                VARCHAR(15000),
--   COMMISSIONING_DATE_C                      DATE,
--   DATE_EMAIL_ACKNOWLEDGED_C                 DATE,
--   DATE_EMAIL_RECEIVED_C                     DATE,
--   DATE_SENT_TO_DEALER_C                     DATE,
--   DATE_UNIRAC_QUOTE_RECEIVED_C              DATE,
--   DEPARTMENT_OWNER_C                        VARCHAR(765),
--   ENGINEERING_REVIEW_C                      VARCHAR(765),
--   INSPECTION_DATE_C                         DATE,
--   INVERTER_1_C                              VARCHAR(765),
--   INVERTER_2_C                              VARCHAR(765),
--   INVERTER_3_C                              VARCHAR(765),
--   NON_TECHNICAL_REASONS_C                   VARCHAR(765),
--   ON_HOLD_DATE_2_C                          DATE,
--   ON_HOLD_DATE_3_C                          DATE,
--   ON_HOLD_DATE_4_C                          DATE,
--   ON_HOLD_DATE_5_C                          DATE,
--   ON_HOLD_DATE_C                            DATE,
--   ON_HOLD_REASON_2_C                        VARCHAR(765),
--   ON_HOLD_REASON_3_C                        VARCHAR(765),
--   ON_HOLD_REASON_4_C                        VARCHAR(765),
--   ON_HOLD_REASON_C                          VARCHAR(765),
--   ORIGINAL_REQUEST_DATE_C                   DATE,
--   PV_TYPE_C                                 VARCHAR(765),
--   PROJECT_HOMEOWNER_S_NAME_C                VARCHAR(297),
--   QUANTITY_1_C                              numeric,
--   QUANTITY_2_C                              numeric,
--   QUANTITY_3_C                              numeric,
--   REASON_FOR_CANCELLATION_C                 VARCHAR(765),
--   REASON_FOR_ESCALATION_C                   VARCHAR(765),
--   REVIEW_DATE_C                             DATE,
--   REVIEWED_BY_C                             VARCHAR(18),
--   ROOF_TILE_C                               VARCHAR(765),
--   SYSTEM_SIZE_K_W_C                         numeric,
--   TECHNICAL_REASONS_C                       VARCHAR(765),
--   TIER_2_APPROVAL_DATE_C                    DATE,
--   PE_ACTION_C                               VARCHAR(765),
--   RMA_1_C                                   VARCHAR(765),
--   INITIAL_RESPONSE_TIME_FOR_BIRLASOFT_C     VARCHAR(90),
--   TIME_WITH_CUSTOMER_C                      double precision,
--   RETURN_TAG_ISSUED_NA_C                    BOOLEAN,
--   BOL_ISSUED_C                              BOOLEAN,
--   RETURN_TAG_ISSUED_AU_C                    BOOLEAN,
--   TRACKING_NO_C                             VARCHAR(150),
--   PICK_UP_REQUEST_NO_C                      VARCHAR(150),
--   RMA_CASE_OPEN_ALERT_C                     VARCHAR(765),
--   LOC_OF_DAMAGED_UNIT_IN_THE_PALLET_C       VARCHAR(765),
--   LOC_OF_PALLET_WHERE_THE_BOX_IS_PLACED_C   VARCHAR(765),
--   IS_DAMAGE_DESCRIBED_IN_THE_POD_C          VARCHAR(765),
--   IS_PICTURE_OF_DAMAGED_BOX_ATTACHED_C      VARCHAR(765),
--   IS_PICTURE_OF_DAMAGED_PANEL_ATTACHED_C    VARCHAR(765),
--   ESCALATED_TO_C                            VARCHAR(765),
--   REVISION_TYPE_C                           VARCHAR(765),
--   WARRANTY_SIGN_REQUEST_SENT_TO_SATCON_C    DATE,
--   WARRANTY_SIGN_RECEIVED_FROM_SATCON_C      DATE,
--   INSPECTION_RESULT_C                       VARCHAR(765),
--   REASON_FOR_FAIL_C                         VARCHAR(3000),
--   INSPECTION_SCORE_C                        numeric,
--   DEVICE_DISCOVERY_TIME_MINS_C              numeric,
--   ACPV_SUPERVISOR_SN_C                      numeric,
--   PV_POWER_RATING_C                         numeric,
--   ACPV_MODULES_C                            numeric,
--   INSPECTION_COMPLETED_C                    DATE,
--   GIFT_CARD_NUMBER_C                        VARCHAR(297),
--   SHIPPER_TRACKING_NUMBER_C                 VARCHAR(297),
--   SHIPPING_DATE_C                           DATE,
--   REPLACEMENT_PRODUCT_CATEGORY_C            VARCHAR(765),
--   UNIT_COST_C                               numeric(18, 2),
--   PRODUCT_COST_OPPORTUNITY_COST_C           numeric(18, 2),
--   RMA_MRB_LABOR_COST_C                      numeric(18, 2),
--   FREIGHT_AND_HANDLING_COST_C               numeric(18, 2),
--   REWORK_INSPECTION_NFF_COST_C              numeric(18, 2),
--   SERVICE_CREDIT_C                          numeric(18, 2),
--   SPECIAL_CREDIT_C                          numeric(18, 2),
--   RESTOCKING_FEE_C                          numeric(18, 2),
--   OTHER_CLAIMS_C                            numeric(18, 2),
--   OTHERS_SPECIFY_TYPE_OF_COST_C             VARCHAR(765),
--   SUN_POWER_PART_NO_RECEIVED_C              VARCHAR(297),
--   INSPECTION_COMPENSATION_C                 numeric(18, 2),
--   ESTIMATED_DELIVERY_DATE_OF_REPLACEMENT_C  DATE,
--   IS_ASSIGNED_TO_APPIRIO_C                  BOOLEAN,
--   RETURN_TAG_OR_PICK_UP_REQUEST_ISSUED_C    VARCHAR(765),
--   NUMBER_OF_MODULES_ON_SITE_C               numeric,
--   Z_PVP_FILE_2012_C                         VARCHAR(765),
--   LEASE_RMA_C                               VARCHAR(765),
--   TYPE_OF_FAULT_SUB_CATEGORIES_C            VARCHAR(765),
--   SHIPPING_ADDRESS_C                        VARCHAR(765),
--   SHIPPING_ADDRESS_2_C                      VARCHAR(765),
--   SHIPPING_CITY_C                           VARCHAR(765),
--   SHIPPING_COUNTRY_C                        VARCHAR(765),
--   SHIPPING_STATE_PROVINCE_C                 VARCHAR(765),
--   SHIPPING_ZIP_POSTAL_CODE_C                VARCHAR(765),
--   MODULE_QTY_C                              VARCHAR(18),
--   CANCELLATION_DATE_C                       DATE,
--   COMPLETED_DATE_C                          DATE,
--   ESTIMATED_TIME_HRS_C                      numeric,
--   PROMISED_DATE_C                           DATE,
--   REASON_FOR_REVISION_C                     VARCHAR(765),
--   REPLACEMENT_PRODUCT_SUB_CATEGORY_C        VARCHAR(765),
--   P_1_TIME_LIMIT_C                          VARCHAR(765),
--   DEALER_INSTALLER_NAME_C                   VARCHAR(765),
--   LEASE_PAYMENT_C                           VARCHAR(18),
--   RESIDENTIAL_FIELD_SUPERVISOR_C            VARCHAR(18),
--   SPVT_CASE_C                               BOOLEAN,
--   INSPECTION_TYPE_C                         VARCHAR(765),
--   ARRAY_TYPE_C                              VARCHAR(765),
--   AS_BUILT_EXPECTATION_YEAR_1_C             VARCHAR(765),
--   INSTALL_MATCHES_PROPOSAL_C                VARCHAR(765),
--   INSTALLED_ORIENTATION_C                   VARCHAR(765),
--   INSTALLED_ROOF_PITCH_C                    VARCHAR(765),
--   PROPOSAL_ORIENTATION_C                    VARCHAR(765),
--   PROPOSAL_ROOF_PITCH_C                     VARCHAR(765),
--   PROPOSAL_SHADE_C                          VARCHAR(765),
--   REPAIR_REQUIRED_C                         BOOLEAN,
--   COMMERCIAL_PROJECT_NUM_C                  VARCHAR(75),
--   THIRD_PARTY_EMAIL_C                       VARCHAR(240),
--   CATEGORIES_C                              VARCHAR(765),
--   CAUSE_C                                   VARCHAR(765),
--   ERROR_STATE_C                             VARCHAR(765),
--   ISSUE_NOTES_C                             VARCHAR(98304),
--   ISSUE_RESOLUTION_C                        VARCHAR(765),
--   PROBLEM_C                                 VARCHAR(765),
--   PROBLEM_PART_C                            VARCHAR(765),
--   SUB_CATEGORIES_C                          VARCHAR(765),
--   IF_OTHER_CAUSE_C                          VARCHAR(3000),
--   IF_OTHER_PROBLEM_PART_C                   VARCHAR(3000),
--   IF_OTHER_PROBLEM_C                        VARCHAR(3000),
--   IF_OTHER_PRODUCT_SUB_CATEGORY_C           VARCHAR(3000),
--   IF_OTHER_RESOLUTION_C                     VARCHAR(3000),
--   SURVEY_SENT_C                             BOOLEAN,
--   CANCELLATION_TYPE_C                       VARCHAR(765),
--   T_SHIRT_SIZE_C                            VARCHAR(765),
--   SIZING_NOTES_C                            VARCHAR(765),
--   PRODUCT_SELECTION_C                       VARCHAR(18),
--   DATE_SENT_TO_CSR_C                        DATE,
--   RESIDENTIAL_PROJECT_C                     VARCHAR(18),
--   ISSUE_TYPE_C                              VARCHAR(765),
--   LEASE_OPPORTUNITY_NUMBER_C                VARCHAR(75),
--   RSE_OUTCOME_C                             VARCHAR(765),
--   PEER_REVIEW_USER_C                        VARCHAR(18),
--   COMMITMENT_DATE_C                         DATE,
--   PRODUCT_SELECTION_NEW_C                   VARCHAR(18),
--   RESOLUTION_COMMENT_C                      VARCHAR(765),
--   ACCURACY_C                                VARCHAR(15),
--   LEASE_C                                   VARCHAR(75),
--   SOLUTION_DESIGN_C                         BOOLEAN,
--   CODE_WALKTHROUGH_C                        BOOLEAN,
--   DATE_SENT_TO_THE_INSPECTOR_C              DATE,
--   LAST_30_DAYS_C                            VARCHAR(54),
--   REVIEW_FIN_C                              VARCHAR(4099),
--   TYPICAL_YTD_C                             VARCHAR(54),
--   INSPECTION_REQUEST_DATE_RECEIVED_C        DATE,
--   DATE_LEASE_DESIGN_SERVICE_REQUEST_SENT_C  DATE,
--   RESERVE_REPAIR_INVOICE_AMOUNT_C           VARCHAR(48),
--   CASE_DIFFERENTIATOR_C                     VARCHAR(765),
--   RESOLUTION_OWNER_TYPE_C                   VARCHAR(765),
--   STATUS_CHANGED_TIME_STAMP_C               TIMESTAMPTZ,
--   STANDARDS_REVIEW_C                        TIMESTAMPTZ,
--   ACTUAL_DELIVERY_DATE_C                    TIMESTAMPTZ,
--   DEPLOYED_TO_INTEGRATE_C                   TIMESTAMPTZ,
--   DEPLOYED_TO_PRODUCTION_C                  TIMESTAMPTZ,
--   DEPLOYED_TO_STAGE_C                       TIMESTAMPTZ,
--   DEPLOYED_TO_UAT_C                         TIMESTAMPTZ,
--   NEXT_STEPS_C                              VARCHAR(765),
--   INITIAL_SITE_VISIT_COMPLETE_C             DATE,
--   SN_TICKET_NUMBER_C                        VARCHAR(762),
--   IMPACTED_PROCESS_AREA_C                   VARCHAR(765),
--   BUSINESS_AREA_C                           VARCHAR(765),
--   RESOLUTION_AND_CLOSURE_SLA_C              VARCHAR(765),
--   CHANGE_ORDER_C                            VARCHAR(765),
--   DESIGN_REVISION_C                         VARCHAR(765),
--   WHO_S_AT_FAULT_C                          VARCHAR(765),
--   ISSUES_C                                  VARCHAR(4099),
--   ERROR_CODE_C                              VARCHAR(18),
--   REVIEW_TYPE_C                             VARCHAR(4099),
--   ANCHORING_C                               VARCHAR(765),
--   JIRA_TICKET_NUMBER_C                      VARCHAR(762),
--   DIFFERENT_DEALERS_C                       BOOLEAN,
--   ECPART_C                                  VARCHAR(765),
--   PARTNER_ACCT_SHARING_REF_C                VARCHAR(18),
--   SCEMAIL_C                                 VARCHAR(240),
--   SERVICING_CONTACT_C                       VARCHAR(18),
--   CHAT_OUT_OF_BUSINESS_HOURS_C              BOOLEAN,
--   REQUESTOR_EMAIL_C                         VARCHAR(240),
--   COMPENSATION_AMOUNT_C                     VARCHAR(765),
--   COMPENSATION_TYPE_C                       VARCHAR(765),
--   FIRST_CALL_RESOLUTION_C                   VARCHAR(765),
--   GROUP_C                                   VARCHAR(765),
--   SUB_GROUP_C                               VARCHAR(765),
--   MOST_RECENT_QUEUE_C                       VARCHAR(135),
--   COST_ALLOCATION_C                         VARCHAR(765),
--   WARRANTY_COVERAGE_C                       VARCHAR(765),
--   COST_ALLOCATION_REASON_C                  VARCHAR(765),
--   COST_ALLOCATION_SUB_REASON_C              VARCHAR(765),
--   COST_ALLOCATION_SUB_SUB_REASON_C          VARCHAR(765),
--   WARRANTY_COVERAGE_REASON_C                VARCHAR(765),
--   ADDITIONAL_DETAILS_C                      VARCHAR(150),
--   _FIVETRAN_SYNCED                          TIMESTAMPTZ,
--   COMPLAINT_TYPE_C                          VARCHAR(765),
--   COMPLAINT_SOURCE_C                        VARCHAR(4099),
--   COMPLAINT_REASON_C                        VARCHAR(4099),
--   REOPEN_DATE_C                             TIMESTAMPTZ,
--   REOPEN_C                                  numeric,
--   _FIVETRAN_DELETED                         BOOLEAN,
--   DEVELOPER_NOTES_C                         VARCHAR(96000),
--   PARTNER_ACCOUNT_TYPE_C                    VARCHAR(150),
--   REVIEW_BY_C                               VARCHAR(18),
--   DEVELOPER_INSTRUCTIONS_C                  VARCHAR(96000),
--   BUSINESS_HOURS_ID                         VARCHAR(18),
--   DEVELOPMENT_STATUS_C                      VARCHAR(765),
--   DEFECT_ORIGIN_C                           VARCHAR(765),
--   INITIAL_RESPONSE_TIME_BUS_HOURS_C         numeric,
--   COMPONENT_CONDITION_C                     VARCHAR(765),
--   FAILURE_TYPE_C                            VARCHAR(765),
--   QA_RESPONSIBLE_C                          VARCHAR(765),
--   CLAIM_STATUS_C                            VARCHAR(765),
--   COMMISSIONING_STATUS_C                    VARCHAR(765),
--   INITIAL_RESPONSE_TIMESTAMP_C              TIMESTAMPTZ,
--   SUN_POWER_EMPLOYEE_C                      VARCHAR(18),
--   COMPONENT_CATEGORY_C                      VARCHAR(765),
--   JOB_SUPERVISOR_NAME_C                     VARCHAR(18),
--   CUSTOMER_FACING_CATEGORY_C                VARCHAR(765),
--   CUSTOMER_FACING_STATUS_C                  VARCHAR(765),
--   CUSTOMER_FACING_SUBJECT_C                 VARCHAR(765),
--   CUSTOMER_FACING_DESCRIPTION_C             VARCHAR(98304),
--   ORTOO_QRA_ASSIGNMENT_SEQ_C                numeric,
--   ORTOO_QRA_Q_ASSIGN_LAST_ASSIGNED_DATE_C   TIMESTAMPTZ,
--   ORTOO_QRA_Q_ASSIGN_CUSTOM_SEQ_C           VARCHAR(60),
--   ORTOO_QRA_ASSIGNED_FROM_QUEUE_C           VARCHAR(54),
--   ORTOO_QRA_Q_ASSIGN_EXCLUDE_C              BOOLEAN,
--   ORTOO_QRA_ASSIGNED_FROM_GROUP_C           VARCHAR(54),
--   STATUS_CHANGE_TIME_C                      TIMESTAMPTZ,
--   PARTNER_AGENT_PHONE_C                     VARCHAR(120),
--   PARTNER_AGENT_EMAIL_C                     VARCHAR(240),
--   PARTNER_AGENT_NAME_C                      VARCHAR(240),
--   PARTNER_CASE_NUMBER_C                     VARCHAR(150),
--   FPO_RECORD_TYPE_C                         VARCHAR(765),
--   FPO_TYPE_C                                VARCHAR(765),
--   COMPLAINT_ROOT_CAUSE_C                    VARCHAR(765),
--   RMA_REPLACEMENT_COMPLETED_C               DATE,
--   COMPLAINT_SUMMARY_C                       VARCHAR(98304),
--   FORM_STATUS_C                             VARCHAR(765),
--   DATE_COMPLAINT_RECEIVED_C                 DATE,
--   COMPLAINT_CHANNEL_C                       VARCHAR(765),
--   GO_CANVAS_FORM_LINK_C                     VARCHAR(765),
--   REASON_FOR_EXCLUSION_C                    VARCHAR(765),
--   REASON_FOR_REJECTION_C                    VARCHAR(765),
--   COMPLAINT_TAGS_C                          VARCHAR(4099),
--   FORM_SUBMISSION_REVIEW_DATE_C             TIMESTAMPTZ,
--   DATE_COMPLAINT_RESOLVED_C                 DATE,
--   COMPLAINT_TIER_C                          VARCHAR(765),
--   FORM_REVIEWED_BY_C                        VARCHAR(765),
--   COMPLAINT_RESOLUTION_SUMMARY_C            VARCHAR(98304),
--   EXCLUDED_AMOUNT_C                         numeric(18, 2),
--   FORM_RESOLUTION_COMMENTS_C                VARCHAR(98304),
--   COMPLAINT_RESOLUTION_STEPS_C              VARCHAR(4099),
--   PVS_TYPE_C                                VARCHAR(150),
--   FORM_SERIAL_NUMBER_C                      VARCHAR(300),
--   DATE_OF_COMPLAINT_LETTER_C                DATE,
--   RMA_REQUIRED_C                            VARCHAR(765),
--   FORM_PVS_TYPE_C                           VARCHAR(300),
--   FORM_MI_TYPE_C                            VARCHAR(300),
--   PARTY_ID_C                                VARCHAR(150),
--   SITE_VISIT_REQUIRED_C                     BOOLEAN,
--   FIELD_TECHS_SURVEY_RESPONSE_C             VARCHAR(765),
--   WORK_ORDER_SUBMISSION_DATE_C              DATE,
--   FORM_MI_SERIAL_NUMBER_C                   VARCHAR(300),
--   ADDITIONAL_FIELD_TECHS_FEEDBACK_C         VARCHAR(98304),
--   TRUCK_ROLLS_C                             numeric,
--   FORM_NEW_PVS_SERIAL_NUMBER_C              VARCHAR(300),
--   FORM_NEW_MI_SERIAL_NUMBER_C               VARCHAR(300),
--   RMA_STATUS_EMAIL_C                        VARCHAR(240),
--   PRODUCTION_CTS_USED_C                     VARCHAR(765),
--   TRUCK_NUMBER_C                            VARCHAR(765),
--   CREATE_RMA_C                              BOOLEAN,
--   LENDER_CONTACT_EMAIL_C                    VARCHAR(240),
--   X_3_RD_PARTY_CASE_C                       VARCHAR(150),
--   ASSET_ID                                  VARCHAR(18),
--   BUYER_S_EMAIL_C                           VARCHAR(240),
--   RINGDNA_PRODUCT_C                         VARCHAR(765),
--   QA_PASSED_C                               TIMESTAMPTZ,
--   LEASE_NUMBER_C                            VARCHAR(765),
--   PANEL_TYPE_C                              VARCHAR(765),
--   LOAN_CLOSING_DATE_C                       DATE,
--   AMAZONCONNECT_AC_CONTACT_ID_C             VARCHAR(150),
--   PRIMARY_PSR_ON_ACCOUNT_C                  VARCHAR(240),
--   COMPANY_NAME_C                            VARCHAR(765),
--   ZIP_CODE_C                                VARCHAR(765),
--   ON_HOLD_REASON_5_C                        VARCHAR(765),
--   ESTIMATE_LOE_C                            VARCHAR(765),
--   PERCENT_COMPLETED_C                       VARCHAR(765),
--   LESSEE_S_EMAIL_C                          VARCHAR(240),
--   LOAN_AMOUNT_OF_REFINANCE_C                VARCHAR(765),
--   DATE_COMPLETED_BY_BIRLASOFT_C             TIMESTAMPTZ,
--   PLEASE_SPECIFY_C                          VARCHAR(98304),
--   ADDRESS_OF_SOLAR_SYSTEM_C                 VARCHAR(765),
--   IS_SELF_SERVICE_CLOSED                    BOOLEAN,
--   CO_SIGNER_S_EMAIL_C                       VARCHAR(240),
--   UAT_PASSED_C                              TIMESTAMPTZ,
--   ESCROW_CLOSING_DATE_C                     DATE,
--   ANCHORED_C                                BOOLEAN,
--   CUSTOMER_CHAT_PHONE_C                     VARCHAR(120),
--   SPECIFIC_ISSUES_SUN_POWER_NEEDS_TO_KNOW_C VARCHAR(765),
--   REQUESTOR_COMPANY_C                       VARCHAR(765),
--   RINGDNA_SLAVIOLATION_C                    VARCHAR(765),
--   DEVELOPMENT_COMPLETED_C                   TIMESTAMPTZ,
--   RINGDNA_ENGINEERING_REQ_NUMBER_C          VARCHAR(36),
--   COMPLAINT_C                               VARCHAR(765),
--   CONTACT_PHONE_NUMBER_C                    VARCHAR(120),
--   CODE_REVIEW_PASSED_C                      TIMESTAMPTZ,
--   CITY_C                                    VARCHAR(765),
--   COUNTRY_C                                 VARCHAR(765),
--   CO_SIGNER_S_LEGAL_NAME_C                  VARCHAR(765),
--   ESCROW_CONTACT_EMAIL_C                    VARCHAR(240),
--   FIRST_RESPONSE_COMPLETE_C                 TIMESTAMPTZ,
--   NEW_EMAILS_COUNT_C                        numeric,
--   UAT_COMPLETED_C                           TIMESTAMPTZ,
--   CUSTOMER_CHAT_EMAIL_C                     VARCHAR(240),
--   CRB_MEETING_NOTES_C                       VARCHAR(96000),
--   ESCROW_COMPANY_NAME_C                     VARCHAR(765),
--   ESCALATION_COUNTER_C                      numeric,
--   BUYER_S_LEGAL_NAME_C                      VARCHAR(765),
--   RINGDNA_POTENTIAL_LIABILITY_C             VARCHAR(765),
--   REQUIRED_FOR_YOUR_LIFE_EVENT_CHANGE_C     VARCHAR(765),
--   RELATIONSHIP_TO_CURRENT_LESSEE_C          VARCHAR(765),
--   DEED_OF_TRUST_INSTRUMENT_NUMBER_C         VARCHAR(765),
--   ESCROW_NUMBER_C                           VARCHAR(765),
--   IS_VISIBLE_IN_SELF_SERVICE                BOOLEAN,
--   RELEASE_TYPE_C                            VARCHAR(765),
--   DEED_OF_TRUST_SIGNED_DATE_C               DATE,
--   ASSUMPTOR_S_NAME_C                        VARCHAR(765),
--   TRIAGE_COMPLETED_C                        TIMESTAMPTZ,
--   LAST_RESPONSE_TIMESTAMP_C                 TIMESTAMPTZ,
--   LENDER_CONTACT_PHONE_NUMBER_C             VARCHAR(120),
--   ACTUAL_LOE_C                              VARCHAR(765),
--   EMAIL_AFTER_CLOSURE_C                     BOOLEAN,
--   BUYER_S_PHONE_NUMBER_C                    VARCHAR(120),
--   SOLUTION_DESIGN_APPROVED_C                TIMESTAMPTZ,
--   DATE_ASSIGNED_TO_BIRLASOFT_C              TIMESTAMPTZ,
--   NEXT_CRB_MEETING_C                        BOOLEAN,
--   REPLY_TO_EMAIL_C                          VARCHAR(240),
--   APPIRIO_INITIAL_RESPONSE_TIME_HOURS_C     numeric,
--   MISSED_RELEASE_DATE_REASON_C              VARCHAR(765),
--   ESCROW_CONTACT_NAME_C                     VARCHAR(765),
--   ASSET_WARRANTY_ID                         VARCHAR(18),
--   ATTACHMENT_C                              VARCHAR(765),
--   CUSTOMER_CHAT_NAME_C                      VARCHAR(150),
--   COMPLEXITY_C                              VARCHAR(765),
--   CONTACT_ID                                VARCHAR(18),
--   APPIRIO_STATUS_C                          VARCHAR(765),
--   ESCALATED_REASON_C                        VARCHAR(765),
--   LESSEE_S_CONTACT_PHONE_NUMBER_C           VARCHAR(120),
--   UAT_GOVERNOR_C                            VARCHAR(18),
--   RESOURCES_UPDATED_C                       VARCHAR(96000),
--   REQUESTOR_NAME_C                          VARCHAR(765),
--   NO_OF_BUSINESS_DAYS_IN_CASE_SLA_C         numeric,
--   IS_CLOSED_ON_CREATE                       BOOLEAN,
--   LAST_STATUS_CHANGED_C                     TIMESTAMPTZ,
--   ASSUMPTOR_S_EMAIL_C                       VARCHAR(240),
--   STATE_C                                   VARCHAR(765),
--   THEATER_C                                 VARCHAR(765),
--   CO_SIGNER_S_PHONE_NUMBER_C                VARCHAR(120),
--   ASSUMPTOR_S_PHONE_NUMBER_C                VARCHAR(120),
--   OUR_COMPANY_NAME_C                        VARCHAR(765),
--   REQUESTING_FOR_C                          VARCHAR(393216),
--   TITLE_COMPANY_NAME_C                      VARCHAR(765),
--   PRIORITY_GROUP_C                          VARCHAR(765),
--   LENDER_COMPANY_NAME_C                     VARCHAR(765),
--   SERVICE_TYPE_C                            VARCHAR(765),
--   ORG_ID_C                                  VARCHAR(765),
--   ASSIGNMENT_COMPLETE_C                     TIMESTAMPTZ,
--   LENDER_CONTACT_NAME_C                     VARCHAR(765),
--   HAS_ISSUES_C                              BOOLEAN,
--   QUOTE_C                                   VARCHAR(18),
--   CUSTOMER_CHAT_COMMENTS_C                  VARCHAR(765),
--   REQUESTOR_PHONE_NUMBER_C                  VARCHAR(120),
--   LESSEE_S_LEGAL_NAME_SELLER_C              VARCHAR(765),
--   DATE_COMPLETE_FILES_RECEIVED_C            DATE
-- );

-- drop table if exists brs.TASK_REWORK_REQUEST_C;
-- create table if not exists brs.TASK_REWORK_REQUEST_C
-- (
--   ID                     VARCHAR(18),
--   IS_DELETED             BOOLEAN,
--   NAME                   VARCHAR(240),
--   CURRENCY_ISO_CODE      VARCHAR(9),
--   CREATED_DATE           TIMESTAMPTZ,
--   CREATED_BY_ID          VARCHAR(18),
--   LAST_MODIFIED_DATE     TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID    VARCHAR(18),
--   SYSTEM_MODSTAMP        TIMESTAMPTZ,
--   LAST_ACTIVITY_DATE     DATE,
--   CONNECTION_RECEIVED_ID VARCHAR(18),
--   CONNECTION_SENT_ID     VARCHAR(18),
--   INITIATING_TASK_C      VARCHAR(18),
--   END_DATE_TIME_C        TIMESTAMPTZ,
--   EXPLANATION_C          VARCHAR(98304),
--   REWORK_CATEGORY_C      VARCHAR(765),
--   REWORK_TASK_C          VARCHAR(18),
--   START_DATE_TIME_C      TIMESTAMPTZ,
--   STATUS_C               VARCHAR(765),
--   REASON_LEVEL_1_C       VARCHAR(765),
--   REASON_LEVEL_2_C       VARCHAR(765),
--   RESIDENTIAL_PROJECT_C  VARCHAR(18),
--   INVALID_TASK_C         BOOLEAN,
--   RCA_TAG_C              VARCHAR(765),
--   REWORK_ACTION_OWNER_C  VARCHAR(765),
--   REWORK_QUALITY_TAG_C   VARCHAR(765),
--   SEVERITY_C             VARCHAR(765),
--   ACTION_DECRIPTION_C    VARCHAR(765),
--   REQUIRED_FOR_C         VARCHAR(765),
--   _FIVETRAN_SYNCED       TIMESTAMPTZ,
--   _FIVETRAN_DELETED      BOOLEAN,
--   REWORK_REQUESTS_C      VARCHAR(18),
--   NOTES_C                VARCHAR(98304)
-- );

-- drop table if exists brs.WORK_ORDER;
-- create table if not exists brs.WORK_ORDER
-- (
--   ID                                          VARCHAR(18),
--   OWNER_ID                                    VARCHAR(18),
--   IS_DELETED                                  BOOLEAN,
--   WORK_ORDER_NUMBER                           VARCHAR(765),
--   CURRENCY_ISO_CODE                           VARCHAR(9),
--   RECORD_TYPE_ID                              VARCHAR(18),
--   CREATED_DATE                                TIMESTAMPTZ,
--   CREATED_BY_ID                               VARCHAR(18),
--   LAST_MODIFIED_DATE                          TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                         VARCHAR(18),
--   SYSTEM_MODSTAMP                             TIMESTAMPTZ,
--   LAST_VIEWED_DATE                            TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                        TIMESTAMPTZ,
--   ACCOUNT_ID                                  VARCHAR(18),
--   CONTACT_ID                                  VARCHAR(18),
--   CASE_ID                                     VARCHAR(18),
--   ASSET_ID                                    VARCHAR(18),
--   STREET                                      VARCHAR(765),
--   CITY                                        VARCHAR(120),
--   STATE                                       VARCHAR(240),
--   POSTAL_CODE                                 VARCHAR(60),
--   COUNTRY                                     VARCHAR(240),
--   LATITUDE                                    numeric,
--   LONGITUDE                                   numeric,
--   GEOCODE_ACCURACY                            VARCHAR(765),
--   DESCRIPTION                                 VARCHAR(96000),
--   START_DATE                                  TIMESTAMPTZ,
--   END_DATE                                    TIMESTAMPTZ,
--   SUBJECT                                     VARCHAR(765),
--   ROOT_WORK_ORDER_ID                          VARCHAR(18),
--   STATUS                                      VARCHAR(120),
--   PRIORITY                                    VARCHAR(120),
--   TAX                                         numeric(18, 2),
--   PRICEBOOK_2_ID                              VARCHAR(18),
--   DISCOUNT                                    numeric,
--   GRAND_TOTAL                                 numeric(18, 2),
--   PARENT_WORK_ORDER_ID                        VARCHAR(18),
--   IS_CLOSED                                   BOOLEAN,
--   BUSINESS_HOURS_ID                           VARCHAR(18),
--   DURATION                                    numeric,
--   DURATION_TYPE                               VARCHAR(765),
--   DURATION_IN_MINUTES                         numeric,
--   SERVICE_APPOINTMENT_COUNT                   numeric,
--   STATUS_CATEGORY                             VARCHAR(765),
--   LOCATION_ID                                 VARCHAR(18),
--   REQUESTED_DATE_C                            DATE,
--   DATE_ACTION_COMPLETED_C                     DATE,
--   RMA_C                                       VARCHAR(18),
--   REASON_CODE_C                               VARCHAR(4099),
--   RESPONSE_CODE_C                             VARCHAR(765),
--   RESPONSE_COMMENTS_C                         VARCHAR(98304),
--   COMMITMENT_DATE_C                           DATE,
--   SKEDULO_JOB_TYPE_C                          VARCHAR(765),
--   SKEDULO_JOB_C                               BOOLEAN,
--   SERVICE_REQUEST_TYPE_C                      VARCHAR(765),
--   SCHEDULER_C                                 VARCHAR(18),
--   APPOINTMENT_CANCELLATION_NOTES_C            VARCHAR(765),
--   APPOINTMENT_CANCELLATION_C                  BOOLEAN,
--   CANCELLATION_DETAILS_C                      VARCHAR(765),
--   CANCELLATION_REASONS_C                      VARCHAR(765),
--   MOST_RECENT_QUEUE_C                         VARCHAR(135),
--   CLOSED_TIMESTAMP_C                          TIMESTAMPTZ,
--   COMPLETED_DATE_C                            TIMESTAMPTZ,
--   CREATED_TIMESTAMP_C                         TIMESTAMPTZ,
--   _FIVETRAN_SYNCED                            TIMESTAMPTZ,
--   SALES_ORDER_C                               VARCHAR(765),
--   PAYMENT_REFERENCE_C                         VARCHAR(765),
--   _FIVETRAN_DELETED                           BOOLEAN,
--   ASSET_WARRANTY_ID                           VARCHAR(18),
--   INTAKE_NOTES_C                              VARCHAR(98304),
--   FSL_PREVENT_GEOCODING_FOR_CHATTER_ACTIONS_C BOOLEAN,
--   FOLLOW_UP_WORK_C                            BOOLEAN,
--   LEAD_C                                      VARCHAR(18),
--   PRODUCT_SERVICE_CAMPAIGN_ID                 VARCHAR(18),
--   INSPECTION_TYPE_C                           VARCHAR(765),
--   DISPOSITION_REASON_C                        VARCHAR(765),
--   MAINTENANCE_WORK_RULE_ID                    VARCHAR(18),
--   WORK_TYPE_ID                                VARCHAR(18),
--   RETURN_ORDER_LINE_ITEM_ID                   VARCHAR(18),
--   SERVICE_TERRITORY_ID                        VARCHAR(18),
--   PRODUCT_SERVICE_CAMPAIGN_ITEM_ID            VARCHAR(18),
--   FSL_VISITING_HOURS_C                        VARCHAR(18),
--   PARTNER_C                                   VARCHAR(18),
--   FOLLOW_UP_REASON_DETAILS_C                  VARCHAR(98304),
--   FOLLOW_UP_WORK_START_DATE_TIME_C            TIMESTAMPTZ,
--   SERVICE_REPORT_LANGUAGE                     VARCHAR(765),
--   FIRST_CONTACT_DATE_C                        DATE,
--   ORIGINAL_SERVICE_REQUEST_C                  VARCHAR(18),
--   SCHEDULING_POLICY_C                         VARCHAR(18),
--   FOLLOW_UP_REASON_C                          VARCHAR(765),
--   OPPORTUNITY_C                               VARCHAR(18),
--   RECOMMENDED_CREW_SIZE                       numeric,
--   SUGGESTED_MAINTENANCE_DATE                  DATE,
--   SERVICE_TYPE_C                              VARCHAR(765),
--   IS_GENERATED_FROM_MAINTENANCE_PLAN          BOOLEAN,
--   SERVICE_REPORT_TEMPLATE_ID                  VARCHAR(18),
--   FSL_IS_FILL_IN_CANDIDATE_C                  BOOLEAN,
--   ORIGIN_C                                    VARCHAR(765),
--   RETURN_ORDER_ID                             VARCHAR(18),
--   RESIDENTIAL_PROJECT_C                       VARCHAR(18),
--   MAINTENANCE_PLAN_ID                         VARCHAR(18),
--   MINIMUM_CREW_SIZE                           numeric,
--   AUDIT_RESULT_C                              VARCHAR(765),
--   REQUIRES_AUDIT_C                            BOOLEAN,
--   FSL_COMPLETED_DATE_TIME_C                   TIMESTAMPTZ,
--   FSL_IN_JEOPARDY_REASON_C                    VARCHAR(765),
--   FSL_IN_JEOPARDY_C                           BOOLEAN,
--   INSTALLATION_TECHNICIANS_C                  VARCHAR(765),
--   SERVICE_REQUEST_BEING_AUDITED_C             VARCHAR(18),
--   PROCESSED_BY_AUDIT_BATCH_C                  BOOLEAN,
--   AMOUNT_C                                    numeric(18, 2),
--   PAYMENT_DATE_C                              DATE,
--   CUSTOMER_PO_C                               VARCHAR(765),
--   SCOPE_OF_WORK_C                             VARCHAR(4099),
--   ADDITIONAL_COMMENTS_C                       VARCHAR(98304),
--   RELATED_SERVICE_REQUEST_C                   VARCHAR(18),
--   SCHEDULED_WITH_SELF_SERVICE_C               BOOLEAN,
--   CANCELED_BY_SELF_SERVICE_USER_C             BOOLEAN,
--   RESCHEDULED_WITH_SELF_SERVICE_C             BOOLEAN,
--   SSS_SENT_DATE_C                             TIMESTAMPTZ,
--   ERS_INVOICE_NUMBER_C                        VARCHAR(300),
--   ASSIGNED_RESOURCE_C                         VARCHAR(18)
-- );
-- drop table if exists brs.sp_user;
-- create table if not exists brs.sp_USER
-- (
--   ID                                                                       VARCHAR(18),
--   USERNAME                                                                 VARCHAR(240),
--   LAST_NAME                                                                VARCHAR(240),
--   FIRST_NAME                                                               VARCHAR(120),
--   NAME                                                                     VARCHAR(363),
--   COMPANY_NAME                                                             VARCHAR(240),
--   DIVISION                                                                 VARCHAR(240),
--   DEPARTMENT                                                               VARCHAR(240),
--   TITLE                                                                    VARCHAR(240),
--   STREET                                                                   VARCHAR(765),
--   CITY                                                                     VARCHAR(120),
--   STATE                                                                    VARCHAR(240),
--   POSTAL_CODE                                                              VARCHAR(60),
--   COUNTRY                                                                  VARCHAR(240),
--   LATITUDE                                                                 numeric,
--   LONGITUDE                                                                numeric,
--   GEOCODE_ACCURACY                                                         VARCHAR(120),
--   EMAIL                                                                    VARCHAR(384),
--   EMAIL_PREFERENCES_AUTO_BCC                                               BOOLEAN,
--   EMAIL_PREFERENCES_AUTO_BCC_STAY_IN_TOUCH                                 BOOLEAN,
--   EMAIL_PREFERENCES_STAY_IN_TOUCH_REMINDER                                 BOOLEAN,
--   SENDER_EMAIL                                                             VARCHAR(240),
--   SENDER_NAME                                                              VARCHAR(240),
--   SIGNATURE                                                                VARCHAR(3999),
--   STAY_IN_TOUCH_SUBJECT                                                    VARCHAR(240),
--   STAY_IN_TOUCH_SIGNATURE                                                  VARCHAR(1536),
--   STAY_IN_TOUCH_NOTE                                                       VARCHAR(1536),
--   PHONE                                                                    VARCHAR(120),
--   FAX                                                                      VARCHAR(120),
--   MOBILE_PHONE                                                             VARCHAR(120),
--   ALIAS                                                                    VARCHAR(24),
--   COMMUNITY_NICKNAME                                                       VARCHAR(120),
--   BADGE_TEXT                                                               VARCHAR(240),
--   IS_ACTIVE                                                                BOOLEAN,
--   TIME_ZONE_SID_KEY                                                        VARCHAR(120),
--   USER_ROLE_ID                                                             VARCHAR(18),
--   LOCALE_SID_KEY                                                           VARCHAR(120),
--   RECEIVES_INFO_EMAILS                                                     BOOLEAN,
--   RECEIVES_ADMIN_INFO_EMAILS                                               BOOLEAN,
--   EMAIL_ENCODING_KEY                                                       VARCHAR(120),
--   DEFAULT_CURRENCY_ISO_CODE                                                VARCHAR(9),
--   CURRENCY_ISO_CODE                                                        VARCHAR(9),
--   PROFILE_ID                                                               VARCHAR(18),
--   USER_TYPE                                                                VARCHAR(120),
--   LANGUAGE_LOCALE_KEY                                                      VARCHAR(120),
--   EMPLOYEE_NUMBER                                                          VARCHAR(60),
--   DELEGATED_APPROVER_ID                                                    VARCHAR(18),
--   MANAGER_ID                                                               VARCHAR(18),
--   LAST_LOGIN_DATE                                                          TIMESTAMPTZ,
--   CREATED_DATE                                                             TIMESTAMPTZ,
--   CREATED_BY_ID                                                            VARCHAR(18),
--   LAST_MODIFIED_DATE                                                       TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                                                      VARCHAR(18),
--   SYSTEM_MODSTAMP                                                          TIMESTAMPTZ,
--   OFFLINE_TRIAL_EXPIRATION_DATE                                            TIMESTAMPTZ,
--   OFFLINE_PDA_TRIAL_EXPIRATION_DATE                                        TIMESTAMPTZ,
--   USER_PERMISSIONS_MARKETING_USER                                          BOOLEAN,
--   USER_PERMISSIONS_OFFLINE_USER                                            BOOLEAN,
--   USER_PERMISSIONS_AVANTGO_USER                                            BOOLEAN,
--   USER_PERMISSIONS_CALL_CENTER_AUTO_LOGIN                                  BOOLEAN,
--   USER_PERMISSIONS_SFCONTENT_USER                                          BOOLEAN,
--   USER_PERMISSIONS_KNOWLEDGE_USER                                          BOOLEAN,
--   USER_PERMISSIONS_INTERACTION_USER                                        BOOLEAN,
--   USER_PERMISSIONS_SUPPORT_USER                                            BOOLEAN,
--   USER_PERMISSIONS_LIVE_AGENT_USER                                         BOOLEAN,
--   USER_PERMISSIONS_CHATTER_ANSWERS_USER                                    BOOLEAN,
--   USER_PREFERENCES_ACTIVITY_REMINDERS_POPUP                                BOOLEAN,
--   USER_PREFERENCES_EVENT_REMINDERS_CHECKBOX_DEFAULT                        BOOLEAN,
--   USER_PREFERENCES_TASK_REMINDERS_CHECKBOX_DEFAULT                         BOOLEAN,
--   USER_PREFERENCES_REMINDER_SOUND_OFF                                      BOOLEAN,
--   USER_PREFERENCES_DISABLE_ALL_FEEDS_EMAIL                                 BOOLEAN,
--   USER_PREFERENCES_DISABLE_FOLLOWERS_EMAIL                                 BOOLEAN,
--   USER_PREFERENCES_DISABLE_PROFILE_POST_EMAIL                              BOOLEAN,
--   USER_PREFERENCES_DISABLE_CHANGE_COMMENT_EMAIL                            BOOLEAN,
--   USER_PREFERENCES_DISABLE_LATER_COMMENT_EMAIL                             BOOLEAN,
--   USER_PREFERENCES_DIS_PROF_POST_COMMENT_EMAIL                             BOOLEAN,
--   USER_PREFERENCES_CONTENT_NO_EMAIL                                        BOOLEAN,
--   USER_PREFERENCES_CONTENT_EMAIL_AS_AND_WHEN                               BOOLEAN,
--   USER_PREFERENCES_APEX_PAGES_DEVELOPER_MODE                               BOOLEAN,
--   USER_PREFERENCES_RECEIVE_NO_NOTIFICATIONS_AS_APPROVER                    BOOLEAN,
--   USER_PREFERENCES_RECEIVE_NOTIFICATIONS_AS_DELEGATED_APPROVER             BOOLEAN,
--   USER_PREFERENCES_HIDE_CSNGET_CHATTER_MOBILE_TASK                         BOOLEAN,
--   USER_PREFERENCES_DISABLE_MENTIONS_POST_EMAIL                             BOOLEAN,
--   USER_PREFERENCES_DIS_MENTIONS_COMMENT_EMAIL                              BOOLEAN,
--   USER_PREFERENCES_HIDE_CSNDESKTOP_TASK                                    BOOLEAN,
--   USER_PREFERENCES_HIDE_CHATTER_ONBOARDING_SPLASH                          BOOLEAN,
--   USER_PREFERENCES_HIDE_SECOND_CHATTER_ONBOARDING_SPLASH                   BOOLEAN,
--   USER_PREFERENCES_DIS_COMMENT_AFTER_LIKE_EMAIL                            BOOLEAN,
--   USER_PREFERENCES_DISABLE_LIKE_EMAIL                                      BOOLEAN,
--   USER_PREFERENCES_SORT_FEED_BY_COMMENT                                    BOOLEAN,
--   USER_PREFERENCES_DISABLE_MESSAGE_EMAIL                                   BOOLEAN,
--   USER_PREFERENCES_DISABLE_BOOKMARK_EMAIL                                  BOOLEAN,
--   USER_PREFERENCES_DISABLE_SHARE_POST_EMAIL                                BOOLEAN,
--   USER_PREFERENCES_ENABLE_AUTO_SUB_FOR_FEEDS                               BOOLEAN,
--   USER_PREFERENCES_DISABLE_FILE_SHARE_NOTIFICATIONS_FOR_API                BOOLEAN,
--   USER_PREFERENCES_SHOW_TITLE_TO_EXTERNAL_USERS                            BOOLEAN,
--   USER_PREFERENCES_SHOW_MANAGER_TO_EXTERNAL_USERS                          BOOLEAN,
--   USER_PREFERENCES_SHOW_EMAIL_TO_EXTERNAL_USERS                            BOOLEAN,
--   USER_PREFERENCES_SHOW_WORK_PHONE_TO_EXTERNAL_USERS                       BOOLEAN,
--   USER_PREFERENCES_SHOW_MOBILE_PHONE_TO_EXTERNAL_USERS                     BOOLEAN,
--   USER_PREFERENCES_SHOW_FAX_TO_EXTERNAL_USERS                              BOOLEAN,
--   USER_PREFERENCES_SHOW_STREET_ADDRESS_TO_EXTERNAL_USERS                   BOOLEAN,
--   USER_PREFERENCES_SHOW_CITY_TO_EXTERNAL_USERS                             BOOLEAN,
--   USER_PREFERENCES_SHOW_STATE_TO_EXTERNAL_USERS                            BOOLEAN,
--   USER_PREFERENCES_SHOW_POSTAL_CODE_TO_EXTERNAL_USERS                      BOOLEAN,
--   USER_PREFERENCES_SHOW_COUNTRY_TO_EXTERNAL_USERS                          BOOLEAN,
--   USER_PREFERENCES_SHOW_PROFILE_PIC_TO_GUEST_USERS                         BOOLEAN,
--   USER_PREFERENCES_SHOW_TITLE_TO_GUEST_USERS                               BOOLEAN,
--   USER_PREFERENCES_SHOW_CITY_TO_GUEST_USERS                                BOOLEAN,
--   USER_PREFERENCES_SHOW_STATE_TO_GUEST_USERS                               BOOLEAN,
--   USER_PREFERENCES_SHOW_POSTAL_CODE_TO_GUEST_USERS                         BOOLEAN,
--   USER_PREFERENCES_SHOW_COUNTRY_TO_GUEST_USERS                             BOOLEAN,
--   USER_PREFERENCES_SHOW_FORECASTING_CHANGE_SIGNALS                         BOOLEAN,
--   USER_PREFERENCES_HIDE_S_1_BROWSER_UI                                     BOOLEAN,
--   USER_PREFERENCES_DISABLE_ENDORSEMENT_EMAIL                               BOOLEAN,
--   USER_PREFERENCES_PATH_ASSISTANT_COLLAPSED                                BOOLEAN,
--   USER_PREFERENCES_CACHE_DIAGNOSTICS                                       BOOLEAN,
--   USER_PREFERENCES_SHOW_EMAIL_TO_GUEST_USERS                               BOOLEAN,
--   USER_PREFERENCES_SHOW_MANAGER_TO_GUEST_USERS                             BOOLEAN,
--   USER_PREFERENCES_SHOW_WORK_PHONE_TO_GUEST_USERS                          BOOLEAN,
--   USER_PREFERENCES_SHOW_MOBILE_PHONE_TO_GUEST_USERS                        BOOLEAN,
--   USER_PREFERENCES_SHOW_FAX_TO_GUEST_USERS                                 BOOLEAN,
--   USER_PREFERENCES_SHOW_STREET_ADDRESS_TO_GUEST_USERS                      BOOLEAN,
--   USER_PREFERENCES_LIGHTNING_EXPERIENCE_PREFERRED                          BOOLEAN,
--   USER_PREFERENCES_HIDE_END_USER_ONBOARDING_ASSISTANT_MODAL                BOOLEAN,
--   USER_PREFERENCES_HIDE_LIGHTNING_MIGRATION_MODAL                          BOOLEAN,
--   USER_PREFERENCES_HIDE_SFX_WELCOME_MAT                                    BOOLEAN,
--   USER_PREFERENCES_HIDE_BIGGER_PHOTO_CALLOUT                               BOOLEAN,
--   USER_PREFERENCES_GLOBAL_NAV_BAR_WTSHOWN                                  BOOLEAN,
--   USER_PREFERENCES_GLOBAL_NAV_GRID_MENU_WTSHOWN                            BOOLEAN,
--   USER_PREFERENCES_CREATE_LEXAPPS_WTSHOWN                                  BOOLEAN,
--   USER_PREFERENCES_FAVORITES_WTSHOWN                                       BOOLEAN,
--   USER_PREFERENCES_RECORD_HOME_SECTION_COLLAPSE_WTSHOWN                    BOOLEAN,
--   USER_PREFERENCES_RECORD_HOME_RESERVED_WTSHOWN                            BOOLEAN,
--   USER_PREFERENCES_FAVORITES_SHOW_TOP_FAVORITES                            BOOLEAN,
--   USER_PREFERENCES_EXCLUDE_MAIL_APP_ATTACHMENTS                            BOOLEAN,
--   USER_PREFERENCES_SUPPRESS_TASK_SFXREMINDERS                              BOOLEAN,
--   USER_PREFERENCES_SUPPRESS_EVENT_SFXREMINDERS                             BOOLEAN,
--   USER_PREFERENCES_PREVIEW_CUSTOM_THEME                                    BOOLEAN,
--   USER_PREFERENCES_HAS_CELEBRATION_BADGE                                   BOOLEAN,
--   USER_PREFERENCES_USER_DEBUG_MODE_PREF                                    BOOLEAN,
--   USER_PREFERENCES_SRHOVERRIDE_ACTIVITIES                                  BOOLEAN,
--   USER_PREFERENCES_NEW_LIGHTNING_REPORT_RUN_PAGE_ENABLED                   BOOLEAN,
--   USER_PREFERENCES_REVERSE_OPEN_ACTIVITIES_VIEW                            BOOLEAN,
--   USER_PREFERENCES_HAS_SENT_WARNING_EMAIL                                  BOOLEAN,
--   USER_PREFERENCES_HIDE_BROWSE_PRODUCT_REDIRECT_CONFIRMATION               BOOLEAN,
--   USER_PREFERENCES_HIDE_ONLINE_SALES_APP_WELCOME_MAT                       BOOLEAN,
--   CONTACT_ID                                                               VARCHAR(18),
--   ACCOUNT_ID                                                               VARCHAR(18),
--   CALL_CENTER_ID                                                           VARCHAR(18),
--   EXTENSION                                                                VARCHAR(120),
--   PORTAL_ROLE                                                              VARCHAR(120),
--   IS_PORTAL_ENABLED                                                        BOOLEAN,
--   FEDERATION_IDENTIFIER                                                    VARCHAR(1536),
--   ABOUT_ME                                                                 VARCHAR(3000),
--   FULL_PHOTO_URL                                                           VARCHAR(3072),
--   SMALL_PHOTO_URL                                                          VARCHAR(3072),
--   IS_EXT_INDICATOR_VISIBLE                                                 BOOLEAN,
--   OUT_OF_OFFICE_MESSAGE                                                    VARCHAR(120),
--   MEDIUM_PHOTO_URL                                                         VARCHAR(3072),
--   DIGEST_FREQUENCY                                                         VARCHAR(120),
--   DEFAULT_GROUP_NOTIFICATION_FREQUENCY                                     VARCHAR(120),
--   LAST_VIEWED_DATE                                                         TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                                                     TIMESTAMPTZ,
--   BANNER_PHOTO_URL                                                         VARCHAR(3072),
--   SMALL_BANNER_PHOTO_URL                                                   VARCHAR(3072),
--   MEDIUM_BANNER_PHOTO_URL                                                  VARCHAR(3072),
--   IS_PROFILE_PHOTO_ACTIVE                                                  BOOLEAN,
--   INDIVIDUAL_ID                                                            VARCHAR(18),
--   CASE_OWNER_C                                                             VARCHAR(18),
--   COUNTRY_DOMAIN_C                                                         VARCHAR(765),
--   DO_NOT_CALL_C                                                            BOOLEAN,
--   EMAIL_NOTIFICATIONS_C                                                    BOOLEAN,
--   INTEGRATION_ID_C                                                         VARCHAR(60),
--   PARTNER_STORE_VISIBLE_C                                                  BOOLEAN,
--   BUSINESS_UNIT_C                                                          VARCHAR(765),
--   LMS_SUPERVISOR_ID_C                                                      VARCHAR(60),
--   MAIL_OPT_OUT_C                                                           BOOLEAN,
--   PARTNER_ROLE_C                                                           VARCHAR(765),
--   PLATEAU_ID_C                                                             VARCHAR(120),
--   SMART_STORE_ID_C                                                         VARCHAR(240),
--   BY_PASS_VALIDATION_C                                                     BOOLEAN,
--   ALTERNATE_EMAIL_C                                                        VARCHAR(240),
--   TERRITORY_C                                                              VARCHAR(150),
--   FORUM_PASSWORD_C                                                         VARCHAR(60),
--   VIEWABLE_INVERTERS_C                                                     VARCHAR(765),
--   USER_CONTACT_ROLE_C                                                      VARCHAR(765),
--   WEB_USER_C                                                               BOOLEAN,
--   SEND_PDF_NOTIFICATION_C                                                  BOOLEAN,
--   PORTAL_USER_TYPE_C                                                       VARCHAR(765),
--   BYPASS_LEAD_VALIDATION_C                                                 BOOLEAN,
--   LEAD_TEAM_C                                                              VARCHAR(765),
--   ADMIN_NOTES_C                                                            VARCHAR(98304),
--   NAC_MARKETING_C                                                          VARCHAR(765),
--   UPDATE_FORECAST_CATEGORY_ALLOWED_C                                       BOOLEAN,
--   PARTNER_AMBASSADOR_RIGHTS_C                                              BOOLEAN,
--   EDIT_PARTNER_USERS_C                                                     BOOLEAN,
--   UPDATE_CLOSED_OPPORTUNITIES_C                                            BOOLEAN,
--   ALLOW_FINANCIER_UPDATE_C                                                 BOOLEAN,
--   CPR_SALESPERSON_ID_C                                                     VARCHAR(126),
--   LEASE_DOC_CREATION_ALLOWED_C                                             BOOLEAN,
--   PLACE_IN_SERVICE_CHANGE_AUTHORIZE_C                                      BOOLEAN,
--   TEST_C                                                                   BOOLEAN,
--   TENESOL_C                                                                BOOLEAN,
--   VENDOR_C                                                                 VARCHAR(765),
--   VENDOR_SUPPLIER_C                                                        BOOLEAN,
--   PVSIM_ACCESS_KEY_C                                                       VARCHAR(765),
--   ECHOSIGN_DEV_1_ECHO_SIGN_ALLOW_DELEGATED_SENDING_C                       BOOLEAN,
--   ECHOSIGN_DEV_1_ECHO_SIGN_EMAIL_VERIFIED_C                                BOOLEAN,
--   SSO_VALIDATION_C                                                         BOOLEAN,
--   SOLUTIONS_EDITOR_C                                                       VARCHAR(765),
--   BYPASS_LOAN_PATH_VALIDATION_C                                            BOOLEAN,
--   PROJECT_MANAGER_ACCESS_C                                                 VARCHAR(765),
--   QUOTE_CREATION_ALLOWED_C                                                 BOOLEAN,
--   DISPLAY_BUTTON_C                                                         BOOLEAN,
--   SOX_AUDIT_REVIEWED_C                                                     VARCHAR(765),
--   ABOUT_C                                                                  VARCHAR(98304),
--   BUSINESS_FUNCTION_C                                                      VARCHAR(4099),
--   SUPERVISOR_C                                                             VARCHAR(297),
--   SOX_PROFILE_WAS_APPROVAL_RECEIVED_C                                      BOOLEAN,
--   CASE_NUMBER_C                                                            VARCHAR(54),
--   EC_REGIONS_C                                                             VARCHAR(765),
--   HIS_EXPIRATION_DATE_C                                                    DATE,
--   HIS_REGISTRATION_NUMBER_C                                                VARCHAR(150),
--   COUNTER_SIGNATURE_C                                                      VARCHAR(150),
--   BYPASS_WORKFLOW_C                                                        BOOLEAN,
--   SPWR_ADDED_TO_HIS_C                                                      BOOLEAN,
--   LMS_ID_C                                                                 VARCHAR(54),
--   LMS_ACTIVE_C                                                             BOOLEAN,
--   EDIT_ORDER_CONSOLE_RECORD_C                                              BOOLEAN,
--   REGION_S_C                                                               VARCHAR(4099),
--   REGIONAL_DATA_JUSTIFICATION_C                                            VARCHAR(3000),
--   IS_MANAGER_C                                                             BOOLEAN,
--   MANAGER_C                                                                VARCHAR(18),
--   USER_REPORT_PREFERENCE_C                                                 VARCHAR(765),
--   PORTAL_USER_SAVED_REPORTS_C                                              VARCHAR(98304),
--   ADMIN_PORTAL_USER_C                                                      BOOLEAN,
--   DFSLE_CAN_MANAGE_ACCOUNT_C                                               BOOLEAN,
--   DFSLE_PROVISIONED_C                                                      DATE,
--   DFSLE_STATUS_C                                                           VARCHAR(765),
--   DFSLE_USERNAME_C                                                         VARCHAR(300),
--   DEALER_STORE_SSO_ID_C                                                    VARCHAR(75),
--   INTERNAL_USER_C                                                          VARCHAR(18),
--   PARTNER_USER_C                                                           VARCHAR(18),
--   INTRO_MESSAGE_C                                                          VARCHAR(765),
--   _FIVETRAN_DELETED                                                        BOOLEAN,
--   _FIVETRAN_SYNCED                                                         TIMESTAMPTZ,
--   EXTERNAL_ID_C                                                            VARCHAR(90),
--   USER_PREFERENCES_HAS_SENT_WARNING_EMAIL_238                              BOOLEAN,
--   USER_PREFERENCES_HAS_SENT_WARNING_EMAIL_240                              BOOLEAN,
--   USER_PREFERENCES_SHOW_TERRITORY_TIME_ZONE_SHIFTS                         BOOLEAN,
--   NUMBER_OF_FAILED_LOGINS                                                  numeric,
--   LAST_PASSWORD_CHANGE_DATE                                                TIMESTAMPTZ,
--   MOSAIC_ENABLED_C                                                         BOOLEAN,
--   USER_PREFERENCES_NATIVE_EMAIL_CLIENT                                     BOOLEAN,
--   COMPLIANCE_CONTROL_C                                                     BOOLEAN,
--   INTRO_SMS_PHOTO_URL_C                                                    VARCHAR(765),
--   ORTOO_QRA_ASSIGNMENT_GROUP_IS_ACTIVE_C                                   BOOLEAN,
--   TWILIO_SF_TWILIO_PERSONAL_NUMBER_C                                       VARCHAR(120),
--   TWILIO_SF_TWILIO_PERSONAL_NUMBER_IS_VALID_C                              BOOLEAN,
--   USER_PREFERENCES_SHOW_FORECASTING_ROUNDED_AMOUNTS                        BOOLEAN,
--   USER_PREFERENCES_LIVE_AGENT_MIAW_SETUP_DEFLECTION                        BOOLEAN,
--   AMAZONCONNECT_AMAZON_CONNECT_USERNAME_C                                  VARCHAR(765),
--   DESIGN_TOOL_USER_ID_C                                                    VARCHAR(240),
--   DESIGN_TOOL_USER_STATUS_C                                                VARCHAR(240),
--   ACCEPT_TAND_C_C                                                          BOOLEAN,
--   ACCESS_TO_RESIDENTIAL_NOTIFICATIONS_C                                    BOOLEAN,
--   USER_PREFERENCES_HIDE BOOLEAN
-- );
-- drop table if exists brs.quote;
-- create table if not exists brs.QUOTE
-- (
--   ID                                         VARCHAR(18),
--   OWNER_ID                                   VARCHAR(18),
--   IS_DELETED                                 BOOLEAN,
--   NAME                                       VARCHAR(765),
--   CURRENCY_ISO_CODE                          VARCHAR(9),
--   RECORD_TYPE_ID                             VARCHAR(18),
--   CREATED_DATE                               TIMESTAMPTZ,
--   CREATED_BY_ID                              VARCHAR(18),
--   LAST_MODIFIED_DATE                         TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                        VARCHAR(18),
--   SYSTEM_MODSTAMP                            TIMESTAMPTZ,
--   LAST_VIEWED_DATE                           TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                       TIMESTAMPTZ,
--   OPPORTUNITY_ID                             VARCHAR(18),
--   PRICEBOOK_2_ID                             VARCHAR(18),
--   CONTACT_ID                                 VARCHAR(18),
--   QUOTE_NUMBER                               VARCHAR(90),
--   IS_SYNCING                                 BOOLEAN,
--   SHIPPING_HANDLING                          numeric(18, 2),
--   TAX                                        numeric(18, 2),
--   STATUS                                     VARCHAR(120),
--   EXPIRATION_DATE                            DATE,
--   DESCRIPTION                                VARCHAR(96000),
--   BILLING_STREET                             VARCHAR(765),
--   BILLING_CITY                               VARCHAR(120),
--   BILLING_STATE                              VARCHAR(240),
--   BILLING_POSTAL_CODE                        VARCHAR(60),
--   BILLING_COUNTRY                            VARCHAR(240),
--   BILLING_LATITUDE                           double precision,
--   BILLING_LONGITUDE                          double precision,
--   BILLING_GEOCODE_ACCURACY                   VARCHAR(765),
--   SHIPPING_STREET                            VARCHAR(765),
--   SHIPPING_CITY                              VARCHAR(120),
--   SHIPPING_STATE                             VARCHAR(240),
--   SHIPPING_POSTAL_CODE                       VARCHAR(60),
--   SHIPPING_COUNTRY                           VARCHAR(240),
--   SHIPPING_LATITUDE                          double precision,
--   SHIPPING_LONGITUDE                         double precision,
--   SHIPPING_GEOCODE_ACCURACY                  VARCHAR(765),
--   QUOTE_TO_STREET                            VARCHAR(765),
--   QUOTE_TO_CITY                              VARCHAR(120),
--   QUOTE_TO_STATE                             VARCHAR(240),
--   QUOTE_TO_POSTAL_CODE                       VARCHAR(60),
--   QUOTE_TO_COUNTRY                           VARCHAR(240),
--   QUOTE_TO_LATITUDE                          double precision,
--   QUOTE_TO_LONGITUDE                         double precision,
--   QUOTE_TO_GEOCODE_ACCURACY                  VARCHAR(765),
--   ADDITIONAL_STREET                          VARCHAR(765),
--   ADDITIONAL_CITY                            VARCHAR(120),
--   ADDITIONAL_STATE                           VARCHAR(240),
--   ADDITIONAL_POSTAL_CODE                     VARCHAR(60),
--   ADDITIONAL_COUNTRY                         VARCHAR(240),
--   ADDITIONAL_LATITUDE                        double precision,
--   ADDITIONAL_LONGITUDE                       double precision,
--   ADDITIONAL_GEOCODE_ACCURACY                VARCHAR(765),
--   BILLING_NAME                               VARCHAR(765),
--   SHIPPING_NAME                              VARCHAR(765),
--   QUOTE_TO_NAME                              VARCHAR(765),
--   ADDITIONAL_NAME                            VARCHAR(765),
--   EMAIL                                      VARCHAR(240),
--   PHONE                                      VARCHAR(120),
--   FAX                                        VARCHAR(120),
--   ACCOUNT_ID                                 VARCHAR(18),
--   DISCOUNT                                   double precision,
--   GRAND_TOTAL                                numeric(18, 2),
--   CAN_CREATE_QUOTE_LINE_ITEMS                BOOLEAN,
--   ASP_1_C                                    numeric(18, 2),
--   BLENDED_SAVINGS_ESS_C                      numeric(18, 2),
--   ANNUAL_PRICE_C                             numeric(18, 2),
--   BLENDED_SAVINGS_PV_C                       numeric(18, 2),
--   CUSTOMER_PE_GU_C                           numeric(18, 2),
--   YIELD_C                                    double precision,
--   DISCOUNT_RATE_C                            double precision,
--   FEDERAL_TAX_RATE_C                         double precision,
--   BOS_W_C                                    numeric(18, 3),
--   CELL_MONITORING_COST_C                     numeric(18),
--   NET_CONTRACT_PRICE_C                       numeric(18, 2),
--   CENTS_K_WH_C                               double precision,
--   COMMENTS_C                                 VARCHAR(96000),
--   RETAIL_SUPPLY_RATE_K_WH_C                  numeric(18, 3),
--   CONTRACT_PRICING_APPROVAL_C                BOOLEAN,
--   CONTRACT_SIGNED_DATE_C                     DATE,
--   CONTRACT_TYPE_C                            VARCHAR(765),
--   STORAGE_COUNT_C                            double precision,
--   STORAGE_MODEL_C                            VARCHAR(765),
--   DISCOUNT_C                                 numeric(16, 2),
--   COST_ESTIMATE_DATE_REQUESTED_C             DATE,
--   COST_ESTIMATE_PACKAGE_C                    BOOLEAN,
--   SITE_C                                     VARCHAR(18),
--   COSTOMATIC_FIRM_C                          BOOLEAN,
--   COSTS_OUTPUT_COMMENTS_C                    VARCHAR(96000),
--   CREATED_DATE_C                             DATE,
--   INVESTOR_PE_GU_C                           numeric(18, 2),
--   O_M_PRICE_C                                numeric(18, 2),
--   DATE_SENT_TO_CUSTOMER_C                    DATE,
--   ANNUAL_INCENTIVE_NO_OF_YEARS_C             double precision,
--   DESIGN_LOOKUP_C                            VARCHAR(18),
--   PROPERTY_TAX_RATE_C                        double precision,
--   STATE_TAX_RATE_C                           double precision,
--   DIRECT_PROJECT_MARGIN_C                    double precision,
--   LEASE_MARGIN_C                             double precision,
--   LEASE_RATE_C                               numeric(18, 4),
--   PPA_RATE_ADDER_C                           numeric(18, 4),
--   SOLAR_ONLY_NPV_C                           numeric(18, 2),
--   SOLAR_ONLY_SAVINGS_TOTAL_C                 numeric(18, 2),
--   ELECTRICAL_ENGINEER_C                      VARCHAR(765),
--   ELECTRICAL_ENGINEERS_C                     VARCHAR(18),
--   ELECTRICAL_ESTIMATOR_C                     VARCHAR(765),
--   ENERGY_EFFICENCY_QUOTE_C                   BOOLEAN,
--   ESCALATOR_C                                double precision,
--   ESTIMATE_URGENT_REQUEST_C                  BOOLEAN,
--   ESTIMATED_PROPOSAL_DELIVERY_C              DATE,
--   ESTIMATOR_C                                VARCHAR(765),
--   FINANCIAL_STRUCTURE_FEASIBILITY_C          BOOLEAN,
--   FULL_PROPOSAL_OR_JUST_PRICING_C            VARCHAR(765),
--   GROSS_MARGIN_C                             double precision,
--   INCENTIVE_FORMS_COMPLETED_C                BOOLEAN,
--   INITIAL_COST_ESTIMATE_ON_TIME_C            VARCHAR(765),
--   INITIAL_LAYOUT_ON_TIME_C                   VARCHAR(765),
--   INITIAL_SIMULATION_ON_TIME_C               VARCHAR(765),
--   INITIAL_SINGLE_LINE_ON_TIME_C              VARCHAR(765),
--   INITIAL_SITE_AUDIT_ON_TIME_C               VARCHAR(765),
--   INITIAL_STRUCTURAL_ANALYSIS_ON_TIME_C      VARCHAR(765),
--   KICKOFF_MEETING_DATE_C                     DATE,
--   LEGAL_SUPPORT_C                            BOOLEAN,
--   LINE_ITEMS_FROM_OPP_C                      BOOLEAN,
--   MODULE_TYPE_C                              VARCHAR(765),
--   MOUNTING_SYSTEM_MODULE_C                   VARCHAR(4099),
--   NEW_DESIGN_C                               double precision,
--   NUMBER_OF_SITES_C                          double precision,
--   OCIP_REQUIRED_C                            VARCHAR(765),
--   O_M_SERVICE_LEVEL_C                        VARCHAR(765),
--   O_M_SUPORT_C                               BOOLEAN,
--   OTHER_ROOFING_C                            VARCHAR(150),
--   PM_COST_BASED_ON_DESIGN_C                  double precision,
--   PM_COST_WITHOUT_DESIGN_C                   numeric(18, 2),
--   PPA_CUSTOMIZATION_C                        BOOLEAN,
--   PPA_PRICING_TEMPLATE_BUDGETARY_C           BOOLEAN,
--   PPA_PRICING_TEMPLATE_FIRM_C                BOOLEAN,
--   PSR_C                                      VARCHAR(18),
--   PV_AVAILABILITY_STATUS_C                   VARCHAR(765),
--   PV_W_C                                     numeric(18, 3),
--   PAYMENT_TERMS_C                            VARCHAR(765),
--   PERMITS_INCLUDED_C                         VARCHAR(765),
--   PERMITTING_DUE_DILIGENCE_COMPLETE_C        BOOLEAN,
--   PHOTO_RENDERING_C                          BOOLEAN,
--   PRESENTATION_C                             BOOLEAN,
--   PRICE_APPROVAL_C                           BOOLEAN,
--   PRICE_TO_CUSTOMER_C                        numeric(10, 2),
--   PRICING_MODEL_FILE_NAME_C                  VARCHAR(360),
--   PRO_FORMA_C                                BOOLEAN,
--   PROJECT_MANAGER_COSTING_C                  BOOLEAN,
--   PROJECT_MANAGER_C                          VARCHAR(765),
--   PROJECT_MANAGERS_C                         VARCHAR(18),
--   PROJECT_SERVICE_REQUEST_DATE_SENT_C        DATE,
--   CASH_INCENTIVE_DISCOUNT_C                  numeric(18, 2),
--   PROPOSAL_DUE_ORIGINAL_C                    DATE,
--   PROPOSAL_DUE_C                             DATE,
--   PROPOSAL_FILE_NAME_C                       VARCHAR(765),
--   PROPOSAL_C                                 BOOLEAN,
--   ACH_OPT_IN_C                               BOOLEAN,
--   BYPASS_ACH_C                               BOOLEAN,
--   APR_TYPE_C                                 VARCHAR(765),
--   STORAGE_COMMISSION_C                       numeric(16, 2),
--   SUN_POWER_DISCOUNT_C                       numeric(18, 2),
--   DATE_SENT_TO_MY_SUN_POWER_C                TIMESTAMPTZ,
--   QUOTE_AMOUNT_C                             numeric(14, 2),
--   QUOTE_APPROVAL_DATE_C                      DATE,
--   QUOTE_COST_C                               numeric(18, 2),
--   QUOTE_EXPIRATION_DATE_C                    DATE,
--   QUOTE_GROSS_MARGIN_C                       numeric(14, 2),
--   QUOTE_STEPS_C                              VARCHAR(765),
--   RFI_DATE_SENT_C                            DATE,
--   RATE_ANALYSIS_C                            BOOLEAN,
--   REBATE_C                                   VARCHAR(300),
--   RESOURCE_APPROVAL_C                        BOOLEAN,
--   REVENUE_C                                  numeric(10, 2),
--   ROOF_PITCH_C                               VARCHAR(765),
--   ROOFING_MATERIAL_C                         VARCHAR(4099),
--   SALES_ANALYST_C                            VARCHAR(18),
--   SHIPPING_INCO_TERM_DATE_C                  DATE,
--   SHIPPING_INCO_TERMS_C                      VARCHAR(765),
--   SIMULATION_COMPLETED_C                     DATE,
--   SIMULATION_DATE_REQUESTED_C                DATE,
--   SIMULATION_C                               BOOLEAN,
--   SIMULATOR_C_C                              VARCHAR(765),
--   SINGLE_LINE_BASED_ON_DESIGN_C              double precision,
--   SINGLE_LINE_COMPLETED_C                    DATE,
--   SINGLE_LINE_DATE_REQUESTED_C               DATE,
--   SINGLE_LINE_URGENT_REQUEST_C               BOOLEAN,
--   SINGLE_LINE_WITHOUT_DESIGN_C               double precision,
--   SINGLE_LINE_C                              BOOLEAN,
--   SOLAR_ONLY_SAVINGS_YR_1_C                  numeric(18, 2),
--   SOLAR_STORAGE_NPV_C                        numeric(18, 2),
--   SOLAR_STORAGE_SAVINGS_TOTAL_C              numeric(18, 2),
--   SOLAR_STORAGE_SAVINGS_YR_1_C               numeric(18, 2),
--   SELECTED_ESS_C                             VARCHAR(18),
--   STORAGE_PRICE_C                            numeric(18, 2),
--   CASH_ASP_SOLAR_ONLY_C                      numeric(18, 2),
--   CASH_NPV_C                                 numeric(18, 2),
--   ARCHIVED_C                                 BOOLEAN,
--   SITE_AUDITORS_C                            VARCHAR(18),
--   MY_SUN_POWER_C                             BOOLEAN,
--   STORAGE_BACKUP_TYPE_C                      VARCHAR(765),
--   SIZING_CALCULATIONS_C                      BOOLEAN,
--   STANDARD_CONTRACT_USED_C                   BOOLEAN,
--   LOAN_BASE_PRICE_C                          numeric(18, 2),
--   STRL_FDTN_ANALYSIS_DUE_C                   DATE,
--   STRL_FDTN_ANALYSIS_TRACKING_COMPLETED_C    DATE,
--   STRUCTURAL_FOUNDATION_ENGINEERS_C          VARCHAR(18),
--   SYSTEM_OUTPUT_K_WH_C                       double precision,
--   STORAGE_EXPANSION_UNIT_QUANTITY_C          double precision,
--   STORAGE_EXPANSION_UNIT_C                   VARCHAR(765),
--   STORAGE_SYSTEM_C                           VARCHAR(765),
--   SYSTEM_SIZE_BOS_C                          numeric(18, 2),
--   SYSTEM_SIZE_PV_C                           numeric(18, 3),
--   SYSTEM_SIZE_K_WP_C                         double precision,
--   TERM_YEARS_C                               double precision,
--   TOTAL_BOS_COST_C                           numeric(18, 2),
--   TOTAL_DEVELOPMENT_COST_C                   numeric(18, 2),
--   TOTAL_PV_COST_C                            numeric(18, 2),
--   TRANSMISSION_DUE_DILIGENCE_COMPLETE_C      BOOLEAN,
--   K_WP_SMARTMOUNT_C                          double precision,
--   K_WP_SUNTILE_C                             double precision,
--   OLD_SYS_QUOTE_NUMBER_C                     VARCHAR(150),
--   STORAGE_LOCATION_C                         VARCHAR(765),
--   FINANCE_CHARGE_C                           numeric(18, 2),
--   LOAN_DATE_PHASE_1_C                        DATE,
--   LOAN_DATE_PHASE_2_C                        DATE,
--   SEND_TO_DRC_C                              BOOLEAN,
--   IS_SEND_APPROVALTO_SALES_ANALYST_C         BOOLEAN,
--   DRC_NOTES_C                                VARCHAR(96000),
--   SALES_ANALYST_SUPPORT_C                    BOOLEAN,
--   OPPORTUNITY_OWNER_S_MANAGER_C              VARCHAR(240),
--   PRICE_C                                    numeric(18, 2),
--   ACCOUNT_C                                  VARCHAR(18),
--   ADDITIONAL_EQUIPMENT_C                     VARCHAR(765),
--   ADMIN_NOTES_C                              VARCHAR(765),
--   COMPANY_ID_C                               VARCHAR(120),
--   CONSTRUCTION_C                             numeric(18, 2),
--   CUSTOMER_ID_C                              VARCHAR(765),
--   CUSTOMER_ADDRESS_ADDRESS_C                 VARCHAR(120),
--   CUSTOMER_ADDRESS_CITY_C                    VARCHAR(120),
--   CUSTOMER_ADDRESS_COUNTY_C                  VARCHAR(120),
--   CUSTOMER_ADDRESS_STATE_C                   VARCHAR(6),
--   CUSTOMER_ADDRESS_ZIP_C                     double precision,
--   CUSTOMER_ELECTRIC_UTILITY_C                VARCHAR(765),
--   CUSTOMER_RATE_NAME_C                       VARCHAR(765),
--   DATE_CREATED_C                             DATE,
--   DATE_MODIFIED_C                            DATE,
--   FULL_PRE_PAYMENT_AMOUNT_BASE_AMOUNT_C      numeric(18, 2),
--   IS_LOCKED_C                                BOOLEAN,
--   LEASE_DOC_CREATED_C                        BOOLEAN,
--   LEASE_NUMBER_C                             VARCHAR(90),
--   MODULE_ORACLE_ITEM_NUMBER_C                VARCHAR(18),
--   MODULE_QUANTITY_C                          double precision,
--   OVERRIDE_30_KW_LIMIT_C                     BOOLEAN,
--   TEMP_CONTACT_1_C                           VARCHAR(765),
--   TEMP_CONTACT_2_C                           VARCHAR(765),
--   CHECK_CONT_LICENCE_C                       BOOLEAN,
--   LOAN_DATE_PHASE_3_C                        DATE,
--   CONTACTS_NAMES_C                           VARCHAR(765),
--   DATE_C                                     VARCHAR(765),
--   DEALER_CONTRACTOR_LICENSE_NUMBER_C         VARCHAR(765),
--   DEALER_FEES_C                              numeric(18, 2),
--   DEALER_INSTALLER_ADDRESS_ADDRESS_C         VARCHAR(180),
--   DEALER_INSTALLER_ADDRESS_CITY_C            VARCHAR(765),
--   DEALER_INSTALLER_ADDRESS_COUNTY_C          VARCHAR(765),
--   DEALER_INSTALLER_ADDRESS_STATE_C           VARCHAR(765),
--   DEALER_INSTALLER_ADDRESS_ZIP_C             double precision,
--   DEALER_INSTALLER_C                         VARCHAR(180),
--   DESCRIPTION_C                              VARCHAR(765),
--   DOC_OUT_FOR_SIGNATURE_C                    BOOLEAN,
--   MONTHLY_PAYMENT_W_ACH_PHASE_1_C            numeric(16, 2),
--   EARLY_BUYOUT_OPTION_DATE_C                 VARCHAR(765),
--   EARLY_BUYOUT_OPTION_PRICE_C                numeric(18),
--   FIRST_MONTHLY_PAYMENT_BASE_AMOUNT_C        numeric(18, 2),
--   FIRST_MONTHLY_PAYMENT_EST_TAX_ON_PAYME_C   numeric(18, 2),
--   FIRST_MONTHLY_PAYMENT_ESTIMATED_PAYMENT_C  numeric(18, 2),
--   FIRST_MONTHLY_PAYMENT_C                    double precision,
--   FULL_PRE_PAYMENT_AMOUNT_ESTIMATED_PAYMEN_C numeric(18, 2),
--   FULL_PRE_PAYMENT_AMOUNT_ESTIMATED_TAX_ON_C numeric(18, 2),
--   FULL_PREPAID_LEASE_C                       BOOLEAN,
--   FULL_PREPAYMENT_OF_LEASE_AMOUNT_C          numeric(18, 2),
--   INSTALL_DATE_C                             VARCHAR(765),
--   INTERCONNECT_C                             numeric(18, 2),
--   INVERTER_BRAND_2_C                         VARCHAR(300),
--   INVERTER_BRAND_3_C                         VARCHAR(300),
--   INVERTER_BRAND_4_C                         VARCHAR(300),
--   INVERTER_BRAND_C                           VARCHAR(300),
--   INVERTER_MODEL_2_C                         VARCHAR(300),
--   INVERTER_MODEL_3_C                         VARCHAR(300),
--   INVERTER_MODEL_4_C                         VARCHAR(300),
--   INVERTER_MODEL_C                           VARCHAR(300),
--   INVERTER_QUANTITY_2_C                      double precision,
--   INVERTER_QUANTITY_3_C                      double precision,
--   INVERTER_QUANTITY_4_C                      double precision,
--   INVERTER_QUANTITY_C                        double precision,
--   IS_QUOTE_LOCKED_C                          BOOLEAN,
--   IS_SELECTED_SCENARIO_C                     BOOLEAN,
--   EV_CHARGER_MODEL_C                         VARCHAR(765),
--   LEASE_DOC_SIGNED_C                         BOOLEAN,
--   LEASE_DOC_TERMINATED_C                     BOOLEAN,
--   LEASE_FROM_ACCOUNT_C                       BOOLEAN,
--   LESSEE_2_C                                 VARCHAR(300),
--   LESSEE_3_C                                 VARCHAR(300),
--   LESSEE_4_C                                 VARCHAR(300),
--   LESSEE_C                                   VARCHAR(18),
--   LICENSE_ID_C                               VARCHAR(120),
--   MODULE_C                                   VARCHAR(120),
--   MONITORING_SYSTEM_MODEL_C                  VARCHAR(300),
--   MONITORING_SYSTEM_OPTION_C                 VARCHAR(180),
--   MONITORING_SYSTEM_QUANTITY_C               VARCHAR(150),
--   MONTHLY_POWER_BILL_AFTER_SOLAR_C           VARCHAR(150),
--   MONTHLY_POWER_BILL_BEFORE_SOLAR_C          VARCHAR(150),
--   MOUNTING_OPTION_C                          VARCHAR(120),
--   ORACLE_VENDOR_EMAIL_FIELD_VALUE_C          VARCHAR(240),
--   ORIGINATION_C                              numeric(18, 2),
--   OTHER_CHARGES_ROW_0_AMOUNT_C               VARCHAR(150),
--   OTHER_CHARGES_ROW_0_DESCRIPTION_C          VARCHAR(765),
--   OTHER_CHARGES_ROW_0_NAME_C                 VARCHAR(765),
--   OTHER_CHARGES_ROW_1_AMOUNT_C               VARCHAR(150),
--   OTHER_CHARGES_ROW_1_DESCRIPTION_C          VARCHAR(765),
--   OTHER_CHARGES_ROW_1_NAME_C                 VARCHAR(765),
--   OTHER_CHARGES_ROW_2_AMOUNT_C               VARCHAR(150),
--   OTHER_CHARGES_ROW_2_DESCRIPTION_C          VARCHAR(765),
--   OTHER_CHARGES_ROW_2_NAME_C                 VARCHAR(765),
--   OTHER_CHARGES_ROW_3_AMOUNT_C               VARCHAR(150),
--   OTHER_CHARGES_ROW_3_DESCRIPTION_C          VARCHAR(765),
--   OTHER_CHARGES_ROW_3_NAME_C                 VARCHAR(765),
--   OTHER_CHARGES_ROW_4_AMOUNT_C               VARCHAR(150),
--   OTHER_CHARGES_ROW_4_DESCRIPTION_C          VARCHAR(765),
--   OTHER_CHARGES_ROW_4_NAME_C                 VARCHAR(765),
--   OTHER_CHARGES_ROW_5_AMOUNT_C               VARCHAR(150),
--   OTHER_CHARGES_ROW_5_DESCRIPTION_C          VARCHAR(765),
--   OTHER_CHARGES_ROW_5_NAME_C                 VARCHAR(765),
--   OTHER_CHARGES_ROW_6_AMOUNT_C               VARCHAR(150),
--   OTHER_CHARGES_ROW_6_DESCRIPTION_C          VARCHAR(765),
--   OTHER_CHARGES_ROW_6_NAME_C                 VARCHAR(765),
--   PARTIAL_PREPAYMENT_C                       double precision,
--   POWER_USED_BEFORE_SOLAR_K_WH_YEAR_C        VARCHAR(300),
--   PRIMARY_PSR_EMAIL_ID_C                     VARCHAR(240),
--   PROPOSED_ELECTRIC_UTILITY_C                VARCHAR(765),
--   PROPOSED_RATE_NAME_C                       VARCHAR(765),
--   QUOTE_DATA_UPLOAD_FAILURE_C                VARCHAR(765),
--   QUOTE_ID_C                                 VARCHAR(120),
--   QUOTE_INVERTER_VALUES_C                    VARCHAR(96000),
--   QUOTE_SUMMARY_C                            VARCHAR(18),
--   RACKING_NU_C                               VARCHAR(120),
--   RACKING_QUANTITY_C                         VARCHAR(150),
--   REF_BY_OLD_QUOTE_C                         BOOLEAN,
--   SALESPERSON_ID_C                           VARCHAR(120),
--   SCENARIO_ID_C                              VARCHAR(60),
--   SCENARIO_INDEX_C                           double precision,
--   SHADING_MEASUREMENT_DATE_C                 VARCHAR(150),
--   SHADING_NOTES_C                            VARCHAR(765),
--   SOLAR_REBATE_AMOUNT_C                      numeric(18, 2),
--   SYSTEM_COST_C                              numeric(18, 2),
--   THE_ENDO_BOX_C                             BOOLEAN,
--   TOTAL_MONTHLY_PAYMENTS_C                   numeric(18, 2),
--   FINAL_LEASE_NUMBER_C                       VARCHAR(90),
--   SALES_TAX_C                                double precision,
--   ORIGINAL_LEASE_NUMBER_C                    VARCHAR(54),
--   ADHOC_CREATE_LDA_C                         BOOLEAN,
--   MONTHLY_PAYMENT_W_ACH_PHASE_2_C            numeric(16, 2),
--   ORIGINAL_LEASE_DOC_DATE_C                  DATE,
--   LEASE_DOC_SIGNED_DATE_C                    DATE,
--   LEASE_DOC_CREATED_DATE_C                   DATE,
--   LEASE_DOC_SENT_OUT_FOR_SIGNATURE_C         DATE,
--   CONSOLIDATED_LEASE_NUMBER_DUP_C            VARCHAR(90),
--   MONTHLY_PAYMENT_W_ACH_PHASE_3_C            numeric(16, 2),
--   AMENDED_LEASE_C                            VARCHAR(18),
--   AMENDED_C                                  BOOLEAN,
--   AMENDMENT_COPY_ERROR_MESSAGE_C             VARCHAR(98304),
--   AMENDMENT_DATE_C                           DATE,
--   AMENDMENT_DOC_SIGNED_C                     BOOLEAN,
--   AMENDMENT_HISTORY_1_C                      VARCHAR(765),
--   AMENDMENT_QUOTE_ID_C                       VARCHAR(765),
--   AMENDMENT_TYPE_C                           VARCHAR(765),
--   AMMENDMENT_TYPE_AMD_QUOTE_C                VARCHAR(75),
--   FINANCING_AMENDMENT_NOTES_C                VARCHAR(765),
--   LEASE_TOBE_AMENDED_C                       VARCHAR(765),
--   LESSEE_INFO_AM_DATE_C                      TIMESTAMPTZ,
--   PRODUCT_AM_DATE_C                          TIMESTAMPTZ,
--   PRODUCTION_AM_DATE_C                       TIMESTAMPTZ,
--   AMENDED_LEASE_NUMBER_C                     VARCHAR(765),
--   LEASE_ANNUAL_ESCALATION_C                  double precision,
--   NUMBER_OF_INTERCONNECTIONS_C               double precision,
--   SYSTEM_PRODUCTION_YEAR_1_C                 double precision,
--   UTILITY_BILL_ANNUAL_ESCALATION_C           double precision,
--   LESSOR_C                                   VARCHAR(765),
--   SENT_WELCOME_EMAIL_C                       BOOLEAN,
--   SEND_LIEN_WAIVER_AGREEMENT_C               BOOLEAN,
--   TRIGGER_CHECKBOX_C                         BOOLEAN,
--   LIEN_WAIVER_ALREADY_SENT_C                 BOOLEAN,
--   ANNUAL_BILL_C                              numeric(18),
--   ANNUAL_USAGE_C                             double precision,
--   ANNUAL_TARGET_C                            BOOLEAN,
--   AUTO_DRIVING_REDUCTION_C                   double precision,
--   BUYDOWN_AMOUNT_C                           numeric(18),
--   BUYDOWN_OVERRIDE_C                         BOOLEAN,
--   CO_2_EMISSIONS_REDUCTION_C                 double precision,
--   CASH_AMOUNT_1_C                            numeric(18),
--   CASH_AMOUNT_2_C                            numeric(18, 2),
--   CASH_AMOUNT_3_C                            numeric(18, 2),
--   CASH_AMOUNT_C                              double precision,
--   CASH_DESCRIPTION_1_C                       VARCHAR(75),
--   CASH_DESCRIPTION_2_C                       VARCHAR(75),
--   CASH_DESCRIPTION_3_C                       VARCHAR(75),
--   CASH_DESCRIPTION_C                         VARCHAR(75),
--   CURRENT_RATE_C                             VARCHAR(765),
--   DM_C                                       double precision,
--   DESIGN_FACTOR_C                            VARCHAR(765),
--   DESIGN_FACTOR_VALUE_C                      double precision,
--   DOWN_PAYMENT_C                             double precision,
--   ELAPSED_TIME_C                             VARCHAR(30),
--   END_DATE_C                                 DATE,
--   FILING_STATUS_C                            VARCHAR(765),
--   GENERAL_DERATE_FACTOR_C                    double precision,
--   INCENTIVES_C                               numeric(18),
--   INCENTIVES_DETAIL_1_C                      VARCHAR(600),
--   INCENTIVES_DETAIL_1_AMT_C                  numeric(10),
--   INCENTIVES_DETAIL_2_C                      VARCHAR(600),
--   INCENTIVES_DETAIL_2_AMT_C                  numeric(10),
--   INCENTIVES_DETAIL_3_C                      VARCHAR(600),
--   INCOME_C                                   numeric(18),
--   INV_0_LAYOUT_0_MODULE_COUNT_PER_STRING_C   double precision,
--   INV_0_LAYOUT_0_PARALLEL_STRINGS_COUNT_C    double precision,
--   INVERTER_0_LAYOUT_0_AXIS_TILT_ANGLE_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_10_C     VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_11_C     VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_12_C     VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_1_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_2_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_3_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_4_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_5_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_6_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_7_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_8_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_SHADING_MONTH_9_C      VARCHAR(30),
--   INVERTER_0_LAYOUT_0_STANDARD_PVMODULE_ID_C double precision,
--   INVERTER_0_LAYOUT_0_SYSTEM_AZIMUTH_C       double precision,
--   INVERTER_0_STANDAR_INVERTER_ID_C           double precision,
--   INVERTER_COUNT_C                           double precision,
--   INVERTER_MANUFACTURER_ROOF_1_C             VARCHAR(765),
--   INVERTER_MANUFACTURER_ROOF_2_C             VARCHAR(765),
--   INVERTER_MANUFACTURER_ROOF_3_C             VARCHAR(765),
--   INVERTER_MANUFACTURER_ROOF_4_C             VARCHAR(765),
--   INVERTER_MANUFACTURER_C                    VARCHAR(765),
--   ISNEW_C                                    BOOLEAN,
--   LATITUDE_C                                 VARCHAR(60),
--   LEASE_SALES_TAX_RATE_C                     double precision,
--   LOAN_TERM_C                                VARCHAR(765),
--   LONGITUDE_C                                VARCHAR(75),
--   MODULES_PER_STRING_ROOF_1_C                double precision,
--   MODULES_PER_STRING_ROOF_2_C                double precision,
--   MODULES_PER_STRING_ROOF_3_C                double precision,
--   MODULES_PER_STRING_ROOF_4_C                double precision,
--   MODULES_PER_STRING_C                       double precision,
--   MODULES_C                                  VARCHAR(765),
--   MONITORING_SYSTEM_C                        VARCHAR(765),
--   MONTHLY_APR_C                              double precision,
--   MONTHLY_AUG_C                              double precision,
--   MONTHLY_DEC_C                              double precision,
--   MONTHLY_FEB_C                              double precision,
--   MONTHLY_JAN_C                              double precision,
--   MONTHLY_JUL_C                              double precision,
--   MONTHLY_JUN_C                              double precision,
--   MONTHLY_MAR_C                              double precision,
--   MONTHLY_MAY_C                              double precision,
--   MONTHLY_NOV_C                              double precision,
--   MONTHLY_OCT_C                              double precision,
--   MONTHLY_SEP_C                              double precision,
--   MOUNTING_DESCRIPTION_C                     VARCHAR(765),
--   NOT_AN_HISTORICAL_QUOTE_C                  BOOLEAN,
--   ON_MARKUP_ONLY_C                           BOOLEAN,
--   OPTIONAL_INCENTIVES_C                      VARCHAR(765),
--   PBI_AMOUNT_C                               numeric(18),
--   PBI_OVERRIDE_C                             BOOLEAN,
--   PBI_YEARS_C                                double precision,
--   PARTIAL_TARGET_C                           BOOLEAN,
--   PRODUCTION_SHAVER_C                        double precision,
--   PROPOSED_RATE_C                            VARCHAR(765),
--   QUOTE_TYPE_C                               VARCHAR(765),
--   REC_ESCALATION_C                           double precision,
--   REC_LIFE_YEARS_C                           double precision,
--   REC_VALUE_K_WH_C                           double precision,
--   RECALCULATE_C                              VARCHAR(6),
--   ROOF_DETAILS_1_C                           VARCHAR(18),
--   ROOF_DETAILS_2_C                           VARCHAR(18),
--   ROOF_DETAILS_3_C                           VARCHAR(18),
--   ROOF_DETAILS_4_C                           VARCHAR(18),
--   SALES_TAX_RATE_C                           double precision,
--   STATUS_C                                   VARCHAR(30),
--   SYSTEM_MODEL_C                             VARCHAR(765),
--   TARGET_IMPLIED_RATE_C                      double precision,
--   TARGET_IMPLIED_TARGET_C                    BOOLEAN,
--   TAXABLE_1_C                                BOOLEAN,
--   TAXABLE_2_C                                BOOLEAN,
--   TAXABLE_3_C                                BOOLEAN,
--   TAXABLE_C                                  BOOLEAN,
--   TOTAL_ENERGY_C                             double precision,
--   TOTAL_PARALLEL_STRINGS_ROOF_1_C            double precision,
--   TOTAL_PARALLEL_STRINGS_ROOF_2_C            double precision,
--   TOTAL_PARALLEL_STRINGS_ROOF_3_C            double precision,
--   TOTAL_PARALLEL_STRINGS_ROOF_4_C            double precision,
--   TOTAL_PARALLEL_STRINGS_C                   double precision,
--   TREES_PLANTED_C                            double precision,
--   MARK_1_C                                   double precision,
--   TOTAL_ENERGY_TEST_C                        double precision,
--   COPY_SM_BEFORE_LOCK_C                      VARCHAR(300),
--   COPY_SM_AFTER_LOCK_C                       VARCHAR(300),
--   AGREEMENT_STATUS_C                         VARCHAR(300),
--   CUSTOMER_S_DOWN_PAYMENT_1_C                double precision,
--   CUSTOMER_S_DOWN_PAYMENT_2_C                double precision,
--   DC_CABINET_C                               double precision,
--   DESIGN_HELP_STATUS_C                       VARCHAR(765),
--   DIRECTION_C                                double precision,
--   DOWN_PAYMENT_TYPE_C                        VARCHAR(765),
--   ERDF_FEE_C                                 numeric(18, 4),
--   NON_ACH_FINANCE_CHARGE_C                   numeric(16, 2),
--   APPLIED_REBATE_RATE_C                      double precision,
--   NON_ACH_TOTAL_PAYMENTS_C                   numeric(16, 2),
--   FEASIBILITY_INDICATOR_C                    VARCHAR(765),
--   FIT_ANNUAL_ESC_C                           double precision,
--   FIT_RATE_C                                 numeric(18, 4),
--   GREATER_THAN_25_METERS_C                   BOOLEAN,
--   GRID_CONNECTION_TYPE_C                     VARCHAR(765),
--   INVERTER_COUNT_ROOF_1_C                    double precision,
--   INVERTER_COUNT_ROOF_2_C                    double precision,
--   INVERTER_COUNT_ROOF_3_C                    double precision,
--   INVERTER_COUNT_ROOF_4_C                    double precision,
--   INVERTER_MODEL_ROOF_1_C                    VARCHAR(300),
--   INVERTER_MODEL_ROOF_2_C                    VARCHAR(300),
--   INVERTER_MODEL_ROOF_3_C                    VARCHAR(300),
--   INVERTER_MODEL_ROOF_4_C                    VARCHAR(300),
--   IRREGULAR_ROOF_C                           BOOLEAN,
--   MULTIPLE_ROOFS_C                           BOOLEAN,
--   ORIGINAL_ERDFFEE_C                         numeric(18, 4),
--   ORIGINAL_FIT_RATE_C                        numeric(18, 4),
--   PRIMARY_CONTACT_C                          VARCHAR(18),
--   QUOTE_LOI_STATUS_C                         VARCHAR(765),
--   RACKING_C                                  VARCHAR(765),
--   ROOF_1_MPPT_1_MODULE_C                     double precision,
--   ROOF_1_MPPT_1_STRING_C                     double precision,
--   ROOF_1_MPPT_2_MODULE_C                     double precision,
--   ROOF_1_MPPT_2_STRING_C                     double precision,
--   ROOF_1_MPPT_3_MODULE_C                     double precision,
--   ROOF_1_MPPT_3_STRING_C                     double precision,
--   ROOF_1_MPPT_4_MODULE_C                     double precision,
--   ROOF_1_MPPT_4_STRING_C                     double precision,
--   ROOF_2_MPPT_1_MODULE_C                     double precision,
--   ROOF_2_MPPT_1_STRING_C                     double precision,
--   ROOF_2_MPPT_2_MODULE_C                     double precision,
--   ROOF_2_MPPT_2_STRING_C                     double precision,
--   ROOF_2_MPPT_3_MODULE_C                     double precision,
--   ROOF_2_MPPT_3_STRING_C                     double precision,
--   ROOF_2_MPPT_4_MODULE_C                     double precision,
--   ROOF_2_MPPT_4_STRING_C                     double precision,
--   NON_ACH_INTEREST_RATE_C                    double precision,
--   LENDER_ALLOCATION_STATUS_C                 VARCHAR(765),
--   EV_CHARGER_COMMISSION_C                    numeric(16, 2),
--   LEASE_DOC_REVIEWED_C                       VARCHAR(765),
--   EV_CHARGER_QUANTITY_C                      double precision,
--   QUOTE_SELECTED_DATE_C                      TIMESTAMPTZ,
--   REFINANCED_QUOTE_C                         VARCHAR(18),
--   EV_OUTLET_MODEL_C                          VARCHAR(765),
--   DESIGN_FILE_C                              VARCHAR(765),
--   EV_OUTLET_QUANTITY_C                       double precision,
--   EV_CHARGER_COST_C                          numeric(18, 2),
--   EV_OUTLET_COST_C                           numeric(18, 2),
--   TOTAL_EV_PRICE_C                           numeric(18, 2),
--   SECONDARY_CONTACT_C                        VARCHAR(18),
--   SYSTEM_MODEL_FR_C                          VARCHAR(765),
--   SYSTEM_PRICE_C                             numeric(18, 2),
--   TOTAL_YR_1_PRODUCTION_C                    double precision,
--   TRENCHING_C                                VARCHAR(765),
--   WIRING_DISTANCE_C                          VARCHAR(765),
--   X_25_METERS_OR_LESS_C                      BOOLEAN,
--   DC_CABINET_ROOF_2_C                        double precision,
--   DC_CABINET_ROOF_3_C                        double precision,
--   DC_CABINET_ROOF_4_C                        double precision,
--   AC_CABINET_TYPE_C                          VARCHAR(150),
--   CUSTOMER_DOWNPAYMENT_TYPE_C                VARCHAR(765),
--   AVERGE_PAYBACK_RATE_PER_K_WH_C             double precision,
--   DEALER_FEE_INSTALLATION_PARTNER_TOTAL_C    numeric(18, 2),
--   DEALER_FEES_SALES_PARTNER_TOTAL_C          numeric(18, 2),
--   DOWN_PAYMENT_TAX_C                         numeric(18, 2),
--   INSTALLER_C                                VARCHAR(18),
--   MAXIMUM_RATED_CAPACITY_DC_C                double precision,
--   MONTHLY_BASE_PLUS_TAX_YEAR_1_C             double precision,
--   MONTHLY_PAYMENT_BASE_YEAR_1_C              numeric(18, 2),
--   MONTHLY_PAYMENT_TAX_FEES_YEAR_1_C          numeric(18, 2),
--   MONTHLY_PAYMENT_TAX_YEAR_1_C               numeric(18, 2),
--   PRIMARY_C                                  BOOLEAN,
--   PROPOSAL_DOCUMENT_LINK_C                   VARCHAR(39000),
--   SENT_FOR_CREDIT_CHECK_C                    BOOLEAN,
--   FORECASTED_INSTALLATION_DATE_C             DATE,
--   TOTAL_MONTHLY_PAYMENT_BASE_PLUS_TAX_C      numeric(18, 2),
--   TOTAL_MONTHLY_PAYMENT_BASE_C               numeric(18, 2),
--   TOTAL_MONTHLY_PAYMENT_TAX_FEES_C           numeric(18, 2),
--   TOTAL_MONTHLY_PAYMENT_TAX_C                numeric(18, 2),
--   TOTAL_PRODUCTION_BASE_C                    double precision,
--   TOTAL_PRODUCTION_HIGH_C                    double precision,
--   TOTAL_PRODUCTION_LOW_C                     double precision,
--   TOTAL_PRODUCTION_RANGE_C                   VARCHAR(765),
--   UTILITY_DISTRIBUTOR_C                      VARCHAR(765),
--   O_M_ESCALATOR_C                            double precision,
--   SAFE_HARBOR_MODULE_QUANTITY_C              double precision,
--   SPECTRUM_PARTNER_QUOTE_C                   BOOLEAN,
--   PERCENTAGE_ELECTRICITY_PRODUCED_C          double precision,
--   SYSTEM_SIZE_AC_C                           double precision,
--   PBI_SUM_C                                  double precision,
--   PBI_TERM_C                                 double precision,
--   ADDER_FEE_C                                numeric(18, 2),
--   CREATE_TPS_PO_C                            BOOLEAN,
--   DRIP_FEE_C                                 numeric(18, 2),
--   IP_FEE_C                                   numeric(18, 2),
--   TPS_FEE_C                                  numeric(18, 2),
--   TOTAL_DEALER_FEE_C                         numeric(18, 2),
--   NH_COMMUNITY_C                             VARCHAR(18),
--   OK_TO_CREATE_LEASE_CONTRACT_C              BOOLEAN,
--   APPROVED_FINANCE_AMOUNT_C                  numeric(18, 2),
--   COST_OF_FINANCING_C                        double precision,
--   CREDIT_BUREAU_C                            VARCHAR(765),
--   CREDIT_CHECK_APPLICATION_C                 VARCHAR(18),
--   EQUIPMENT_INSTALLATION_VALUE_C             numeric(18, 2),
--   FINANCED_AMOUNT_C                          numeric(18, 2),
--   LOAN_CONTRACT_STATUS_C                     VARCHAR(765),
--   TOTAL_CONTRACT_PRICE_C                     numeric(18, 2),
--   INSTALLATION_MODEL_C                       VARCHAR(18),
--   INTEREST_RATE_C                            double precision,
--   PROPOSAL_PREP_BY_C                         VARCHAR(300),
--   MASTER_CONFIGURATOR_ID_C                   VARCHAR(18),
--   MODULE_CONFIGURATION_ID_C                  VARCHAR(18),
--   SECTOR_C                                   VARCHAR(300),
--   CERTIFIED_THIRD_PARTY_LOAN_C               BOOLEAN,
--   ECOBEE_USER_C                              BOOLEAN,
--   THIRD_PARTY_LOAN_NUMBER_C                  VARCHAR(90),
--   SREC_INDICATOR_C                           BOOLEAN,
--   DYNAMIC_PROPOSAL_C                         BOOLEAN,
--   ESS_TERM_C                                 VARCHAR(765),
--   MONTHLY_RESILIENCY_PAYMENT_C               numeric(18, 2),
--   QUOTE_WIZARD_C                             VARCHAR(765),
--   CREDIT_RATING_C                            VARCHAR(765),
--   ITC_INELIGIBLE_COST_C                      numeric(12, 2),
--   UTILITY_RATE_CODE_C                        VARCHAR(765),
--   YEAR_1_PPA_PRICE_C                         numeric(18, 2),
--   YEAR_1_SAVINGS_C                           numeric(18, 2),
--   TERM_SHEET_GENERATED_DATE_C                TIMESTAMPTZ,
--   TERM_SHEET_C                               BOOLEAN,
--   EST_FEDERAL_TAX_CREDIT_C                   numeric(18, 2),
--   EST_STATE_TAX_CREDIT_C                     numeric(18, 2),
--   EST_STATE_AND_LOCAL_REBATES_C              numeric(18, 2),
--   BLENDED_COST_PER_K_WH_C                    numeric(18, 2),
--   DEMAND_COST_AFTER_C                        numeric(18, 2),
--   DEMAND_COST_BEFORE_C                       numeric(18, 2),
--   ESS_AVERAGE_DEGREDATION_RATE_C             double precision,
--   ESS_ENERGY_CONSUMPTION_YR_1_C              double precision,
--   ESS_INCLUDED_C                             BOOLEAN,
--   ESS_MAX_DISCHARGE_POWER_K_W_C              double precision,
--   ESS_NUMBER_OF_CYCLES_C                     double precision,
--   ESS_TOTAL_COST_C                           numeric(18, 2),
--   ESS_TOTAL_ENERGY_CAPACITY_K_WH_C           double precision,
--   ESS_TOTAL_ENERGY_DISCHARGE_YR_1_C          double precision,
--   ELECTRIC_BILL_COST_AFTER_C                 numeric(18, 2),
--   ELECTRIC_BILL_COST_BEFORE_C                numeric(18, 2),
--   ENERGY_COST_AFTER_C                        numeric(18, 2),
--   ENERGY_COST_BEFORE_C                       numeric(18, 2),
--   EXTERNAL_PROPOSAL_ID_C                     VARCHAR(150),
--   EXTERNAL_PROPOSAL_URL_C                    VARCHAR(765),
--   MAXIMUM_RATED_CAPACITY_AC_C                double precision,
--   MODULE_DEGRADATION_RATE_C                  double precision,
--   NET_ANNUAL_USAGE_C                         double precision,
--   PERFORMANCE_GUARANTEE_C                    BOOLEAN,
--   ESS_PRICE_TYPE_C                           VARCHAR(765),
--   SELECTED_QUOTE_IN_MY_SUN_POWER_C           BOOLEAN,
--   MONTHLY_PAYMENT_PHASE_1_C                  numeric(18, 2),
--   MONTHLY_PAYMENT_PHASE_2_C                  numeric(18, 2),
--   MONTHLY_PAYMENT_PHASE_3_C                  numeric(18, 2),
--   NUM_OF_PAYMENTS_PHASE_1_C                  double precision,
--   NUM_OF_PAYMENTS_PHASE_2_C                  double precision,
--   NUM_OF_PAYMENTS_PHASE_3_C                  double precision,
--   _FIVETRAN_SYNCED                           TIMESTAMPTZ,
--   IO_LOAN_AVAILABLE_C                        BOOLEAN,
--   COST_OF_FINANCING_W_C                      numeric(19, 4),
--   _FIVETRAN_DELETED                          BOOLEAN,
--   SYSTEM_PRICE_EXCLUDING_TAX_C               numeric(18, 2),
--   STORAGE_SIZE_K_WH_C                        double precision,
--   OTHER_INSTALLATION_LOCATION_C              VARCHAR(450),
--   EXISTING_MAIN_PANEL_RATING_C               VARCHAR(765),
--   NEW_MAIN_PANEL_RATING_C                    VARCHAR(765),
--   TRENCH_DIRT_ONLY_C                         double precision,
--   SUB_PANEL_FEEDER_MIGRATION_C               double precision,
--   TRENCH_NON_DIRT_SURFACES_C                 double precision,
--   FEEDER_CONDUCTORS_UP_TO_125_A_C            double precision,
--   FEEDER_CONDUCTORS_125_A_C                  double precision,
--   INSTALLATION_LOCATION_C                    VARCHAR(765),
--   MAIN_PANEL_UPGRADE_C                       VARCHAR(765),
--   BOLLARD_INSTALLATIONS_C                    double precision,
--   CIRCUIT_MIGRATION_C                        double precision,
--   CHARGING_AMPERAGE_NEEDED_C                 VARCHAR(765),
--   DISTANCE_FROM_MAIN_PANEL_C                 double precision,
--   FEEDER_MIGRATION_100_A_C                   double precision,
--   FEEDER_CONDUCTORS_UT_125_A_C               VARCHAR(765),
--   FEEDER_CONDUCTORS_GT_125_A_C               VARCHAR(765),
--   ANNUAL_INCENTIVE_RATE_K_WH_C               numeric(20, 4),
--   PRICE_ID_C                                 VARCHAR(765),
--   OPTIMIZATION_TYPE_C                        VARCHAR(765),
--   AVOIDED_COST_OF_POWER_C                    numeric(14, 4),
--   ENERGY_COST_PER_KWH_WITHOUT_SOLAR_1_C      numeric(19, 4),
--   CONDITIONAL_MPU_NON_STANDARD_REASON_C      VARCHAR(4099),
--   APPROVALS_IN_PLACE_C                       BOOLEAN,
--   QUOTE_IS_READY_AND_APPROVED_C              BOOLEAN,
--   APPROVAL_REQUIRED_C                        BOOLEAN,
--   PRICE_W_C                                  double precision,
--   PRICE_K_WH_C                               double precision,
--   REJECTION_REASON_CODE_S_C                  VARCHAR(4099),
--   PRICING_CATALOG_VERSION_C                  VARCHAR(765),
--   INSUFFICIENT_INFO_C                        BOOLEAN,
--   INSUFFICIENT_HOME_SURVEY_REASON_CODES_C    VARCHAR(4099),
--   REMAINING_AMOUNT_C                         numeric(18, 2),
--   DEPOSIT_SUBMITTED_C                        BOOLEAN,
--   DEPOSIT_DATE_C                             TIMESTAMPTZ,
--   COMPLEX_INSTALL_ADDER_C                    numeric(14),
--   REASON_COMPLEX_INSTALL_ADDER_C             VARCHAR(4099),
--   STORAGE_MANUFACTURER_C                     VARCHAR(765),
--   ARCHIVED_QUOTE_LINE_DATA_C                 VARCHAR(393216),
--   NUMBER_OF_QUOTE_LINES_ARCHIVED_C           double precision,
--   NON_BACKUP_STORAGE_ACKNOWLEDGED_C          VARCHAR(765),
--   RELATED_WORK_ID                            VARCHAR(18),
--   CONTRACT_ID                                VARCHAR(18)
-- );
-- drop table if exists brs.DS_AGREEMENT_C;
-- create table if not exists brs.DS_AGREEMENT_C
-- (
--   ID                                    VARCHAR(18),
--   OWNER_ID                              VARCHAR(18),
--   IS_DELETED                            BOOLEAN,
--   NAME                                  VARCHAR(240),
--   CURRENCY_ISO_CODE                     VARCHAR(9),
--   RECORD_TYPE_ID                        VARCHAR(18),
--   CREATED_DATE                          TIMESTAMPTZ,
--   CREATED_BY_ID                         VARCHAR(18),
--   LAST_MODIFIED_DATE                    TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                   VARCHAR(18),
--   SYSTEM_MODSTAMP                       TIMESTAMPTZ,
--   LAST_VIEWED_DATE                      TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                  TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID                VARCHAR(18),
--   CONNECTION_SENT_ID                    VARCHAR(18),
--   ACCOUNT_C                             VARCHAR(18),
--   CHANGE_ORDER_TYPE_C                   VARCHAR(765),
--   COUNTERSIGNATORY_NOTES_C              VARCHAR(98304),
--   NOTES_C                               VARCHAR(98304),
--   QUOTE_C                               VARCHAR(18),
--   SENT_TO_MY_SUN_POWER_C                BOOLEAN,
--   NH_CONFIRMATION_EMAIL_STATUS_C        VARCHAR(765),
--   COPIED_FROM_C                         VARCHAR(18),
--   DS_AGREEMENT_C                        VARCHAR(18),
--   DOCU_SIGN_ENVELOPE_C                  VARCHAR(18),
--   DOCU_SIGN_STATUS_C                    VARCHAR(18),
--   ENVELOPE_STATUS_C                     VARCHAR(765),
--   ON_HOLD_REASON_S_C                    VARCHAR(4099),
--   REVIEWER_C                            VARCHAR(18),
--   ADHOC_CREATE_LDA_REQUESTED_C          BOOLEAN,
--   CANCELLATION_REASON_C                 VARCHAR(765),
--   CO_BORROWER_AMENDMENT_C               BOOLEAN,
--   CONTRACT_TYPE_C                       VARCHAR(765),
--   DOCUMENT_URL_C                        VARCHAR(765),
--   READY_TO_SIGN_C                       BOOLEAN,
--   HOMEOWNER_DATA_C                      VARCHAR(18),
--   SUBMITTED_FOR_REVIEW_C                BOOLEAN,
--   LEGACY_AGREEMENT_ID_C                 VARCHAR(54),
--   LEGACY_DOCUMENT_KEY_C                 VARCHAR(765),
--   MIGRATED_FROM_ADOBE_C                 BOOLEAN,
--   CONNECTED_SOLUTIONS_PARTICIPANT_C     VARCHAR(765),
--   ACCOUNT_NAME_C                        VARCHAR(765),
--   CONTRACT_END_DATE_C                   DATE,
--   CONTRACT_START_DATE_C                 DATE,
--   FINANCIAL_PAYMENT_C                   VARCHAR(18),
--   INTERCONNECTION_AMOUNT_C              numeric(18, 2),
--   INVOICE_COMPLIANCE_DOCUMENT_C         VARCHAR(18),
--   ORIGINATION_AND_INSTALLATION_AMOUNT_C numeric(18, 2),
--   TEMPLATES_C                           VARCHAR(1500),
--   HOLD_NOTES_C                          VARCHAR(98304),
--   SUB_CATEGORY_C                        VARCHAR(4099),
--   _FIVETRAN_SYNCED                      TIMESTAMPTZ,
--   _FIVETRAN_DELETED                     BOOLEAN,
--   TITLE_CHECK_C                         VARCHAR(18)
-- );
-- drop table if exists brs.LEASE_PAYMENT_C;
-- create table if not exists brs.LEASE_PAYMENT_C
-- (
--   ID                                         VARCHAR(18),
--   IS_DELETED                                 BOOLEAN,
--   NAME                                       VARCHAR(240),
--   CURRENCY_ISO_CODE                          VARCHAR(9),
--   RECORD_TYPE_ID                             VARCHAR(18),
--   CREATED_DATE                               TIMESTAMPTZ,
--   CREATED_BY_ID                              VARCHAR(18),
--   LAST_MODIFIED_DATE                         TIMESTAMPTZ,
--   LAST_MODIFIED_BY_ID                        VARCHAR(18),
--   SYSTEM_MODSTAMP                            TIMESTAMPTZ,
--   LAST_ACTIVITY_DATE                         DATE,
--   LAST_VIEWED_DATE                           TIMESTAMPTZ,
--   LAST_REFERENCED_DATE                       TIMESTAMPTZ,
--   CONNECTION_RECEIVED_ID                     VARCHAR(18),
--   CONNECTION_SENT_ID                         VARCHAR(18),
--   ACCEPTANCE_APPRVD_C                        DATE,
--   ACCEPTANCE_RCVD_C                          DATE,
--   ADD_EQUIPMENT_QTY_C                        double precision,
--   ADDITIONAL_EQUIPMENT_C                     VARCHAR(765),
--   CM_PYMNT_POSTED_C                          DATE,
--   CM_PYMNT_REFERENCE_C                       VARCHAR(72),
--   CM_PYMNT_RQUSTD_C                          DATE,
--   CLOSING_REQUEST_BATCH_C                    VARCHAR(600),
--   CLOSING_REQUEST_DATE_C                     DATE,
--   CLOSING_REQUEST_RESP_C                     VARCHAR(600),
--   CMPLTD_ICF_APPRVD_C                        DATE,
--   CMPLTD_ICF_RCVD_C                          DATE,
--   CMSNG_RPT_APPRVD_C                         DATE,
--   CMSNG_RPT_RCVD_C                           DATE,
--   CNFRMD_ICF_APPRVD_C                        DATE,
--   CNFRMD_ICF_RCVD_C                          DATE,
--   CNFRMD_MON_PRVSND_C                        DATE,
--   COND_FIN_LW_APPRVD_C                       DATE,
--   COND_FIN_LW_RCVD_C                         DATE,
--   COND_PROG_LW_APPRVD_C                      DATE,
--   COND_PROG_LW_RCVD_C                        DATE,
--   CURRENT_STAGE_DATE_C                       DATE,
--   DEALER_LABOR_COST_C                        numeric(12, 2),
--   DEALER_MATERIAL_COST_C                     numeric(12, 2),
--   DEALER_CONTACT_C                           VARCHAR(18),
--   DES_PLAN_APPRVD_C                          DATE,
--   DES_PLAN_RCVD_C                            DATE,
--   EARLY_BUYOUT_PRICE_C                       numeric(10, 2),
--   EST_NPV_C                                  numeric(10, 2),
--   EST_YR_1_PRODUCTION_C                      double precision,
--   FILING_STATUS_C                            VARCHAR(765),
--   FIN_PERMITS_APPRVD_C                       DATE,
--   FIN_PERMITS_RCVD_C                         DATE,
--   INCOME_C                                   numeric(18),
--   INSTALL_INV_AMOUNT_C                       numeric(8, 2),
--   INSTALL_INV_APPRVD_C                       DATE,
--   INSTALL_INV_NUMBER_C                       VARCHAR(96),
--   INSTALL_INV_RCVD_C                         DATE,
--   INSTALL_PYMNT_APPRVD_C                     DATE,
--   INSTALL_PYMNT_SENT_C                       DATE,
--   INSTALLATION_PO_C                          VARCHAR(90),
--   INTERCONNECT_PO_C                          VARCHAR(90),
--   INTRCNCT_INV_AMOUNT_C                      numeric(8, 2),
--   INTRCNCT_INV_APPRVD_C                      DATE,
--   INTRCNCT_INV_NUMBER_C                      VARCHAR(96),
--   INTRCNCT_INV_RCVD_C                        DATE,
--   INTRCNCT_PYMNT_APPRVD_C                    DATE,
--   INTRCNCT_PYMNT_SENT_C                      DATE,
--   LEASE_CLOSE_DATE_C                         DATE,
--   AMENDMENT_DATE_C                           DATE,
--   MAT_INV_AMOUNT_C                           numeric(12, 2),
--   MAT_INV_APPRVD_C                           DATE,
--   MAT_INV_LW_APPRVD_C                        DATE,
--   MAT_INV_LIEN_WAIVER_C                      DATE,
--   MAT_INV_RCVD_C                             DATE,
--   MAT_INVOICE_NUMBER_C                       VARCHAR(96),
--   MAT_PYMNT_APPRVD_C                         DATE,
--   MAT_PYMNT_SENT_C                           DATE,
--   AMENDMENT_REVISION_LEASE_NUMBER_C          double precision,
--   ANNUAL_ESCALATION_NOT_AVAILABLE_CHECKBOX_C BOOLEAN,
--   BYPASS_ENERGY_START_DATE_UPDATE_C          BOOLEAN,
--   ORIGINATION_PO_C                           VARCHAR(90),
--   PTO_LTR_APPRVD_C                           DATE,
--   PTO_LTR_RCVD_C                             DATE,
--   PARTNER_ACCOUNT_C                          VARCHAR(18),
--   PARTNER_ACCOUNT_ID_C                       VARCHAR(18),
--   PHOTOS_APPRVD_C                            DATE,
--   PHOTOS_RCVD_C                              DATE,
--   PRE_SOLAR_ELEC_USAGE_C                     VARCHAR(765),
--   PRE_SOLAR_TARIFF_C                         VARCHAR(762),
--   PREFLIGHT_BATCH_DATE_C                     DATE,
--   PREFLIGHT_BATCH_C                          VARCHAR(600),
--   PREFLIGHT_RESPONSE_C                       VARCHAR(600),
--   PROJ_ADMIN_STATUS_C                        VARCHAR(765),
--   PROJ_INSTALL_COMPETE_C                     DATE,
--   PLACE_IN_SERVICE_ENTERED_C                 BOOLEAN,
--   RACKING_BRAND_C                            VARCHAR(60),
--   SO_NUMBER_C                                VARCHAR(30),
--   SP_INVOICE_APPRVD_C                        DATE,
--   SP_INVOICE_RCVD_C                          DATE,
--   SP_INVOICE_C                               VARCHAR(90),
--   SP_MATERIAL_COSTS_C                        numeric(12, 2),
--   SALES_TAX_C                                double precision,
--   SCHED_DELIVERY_DATE_C                      DATE,
--   STAGE_C                                    VARCHAR(765),
--   SYSTEM_PRICE_2_C                           numeric(12, 2),
--   UNCOND_FIN_LW_APPROVED_C                   DATE,
--   UNCOND_FIN_LW_RCVD_C                       DATE,
--   WARR_SNS_APPRVD_C                          DATE,
--   WARR_SNS_RCVD_C                            DATE,
--   Y_1_MONTHLY_PAYMENT_C                      numeric(6, 2),
--   INTRCNCT_LTR_RCVD_C                        DATE,
--   INTRCNCT_LTR_APPRVD_C                      DATE,
--   LEASE_2_C                                  BOOLEAN,
--   PLACED_IN_SERVICE_C                        DATE,
--   NOTE_TO_DEALER_INSTALL_C                   VARCHAR(3000),
--   NOTE_TO_DEALER_FINAL_C                     VARCHAR(3000),
--   BILLING_NOTES_C                            VARCHAR(765),
--   LEASE_CHANGE_HOLD_APPLIED_C                DATE,
--   LEASE_CHANGE_HOLD_RELEASED_C               DATE,
--   LEASE_CHANGE_HOLD_DISPOSITION_C            VARCHAR(765),
--   ADDENDUM_SENT_C                            DATE,
--   ADDENDUM_SIGNED_C                          DATE,
--   ADDENDUM_COUNTERSIGNED_C                   DATE,
--   LEASE_CHANGE_NOTES_C                       VARCHAR(765),
--   REVISED_ITEMS_RCVD_C                       DATE,
--   CM_PYMNT_SUBMITTED_C                       VARCHAR(60),
--   NOTICE_TO_PROCEED_SENT_C                   DATE,
--   CITI_ACCEPTANCE_DATE_C                     DATE,
--   MAT_PYMNT_SUBMITTED_C                      DATE,
--   INSTALL_PYMNT_SUBMITTED_C                  DATE,
--   INTRCNCT_PYMNT_SUBMITTED_C                 DATE,
--   LEASE_1_C                                  BOOLEAN,
--   DEALER_FEE_PO_C                            VARCHAR(60),
--   PO_CREATED_C                               DATE,
--   SPEB_SO_C                                  VARCHAR(90),
--   DEALER_LEASE_CONTACT_NAME_C                VARCHAR(120),
--   DEALER_LEASE_CONTACT_EMAIL_C               VARCHAR(240),
--   DATE_DELIVERED_C                           DATE,
--   PROJECTED_INTERCONNECT_DATE_C              DATE,
--   PRICING_C                                  VARCHAR(75),
--   DEALER_FEE_90_PO_RECEIPT_COMPLETE_C        DATE,
--   DEALER_FEE_90_PO_RECEIPT_NUMBER_C          VARCHAR(150),
--   DEALER_FEE_10_PO_RECEIPT_COMPLETE_C        DATE,
--   DEALER_FEE_10_PO_RECEIPT_NUMBER_C          VARCHAR(150),
--   CASH_GRANT_PACKAGE_COMPLETE_C              DATE,
--   FMV_BY_STATE_C                             double precision,
--   WATTAGE_C                                  double precision,
--   US_CASH_GRANT_SUBMISSION_DATE_C            DATE,
--   INVOICE_ADMIN_C                            VARCHAR(150),
--   DEALER_FEE_ORIGINATION_C                   numeric(18, 2),
--   DEALER_FEE_INSTALL_C                       numeric(18, 2),
--   DEALER_FEE_INTERCONNECT_C                  numeric(18, 2),
--   INVERTER_MODEL_3_C                         double precision,
--   PARTNER_ID_TEXT_C                          VARCHAR(297),
--   US_CASH_GRANT_RECEIVED_DATE_C              DATE,
--   DEALER_REBATE_RESERVATION_CONFIRMATION_C   VARCHAR(297),
--   STATUS_C                                   VARCHAR(765),
--   FUNDING_TRANCHE_C                          VARCHAR(765),
--   REBATE_AUTHORITY_C                         VARCHAR(765),
--   EXPIRATION_DATE_C                          DATE,
--   DATE_IN_PTO_LETTER_C                       DATE,
--   ACH_C                                      BOOLEAN,
--   TAN_C                                      VARCHAR(297),
--   PAYMENT_RECEIVED_C                         DATE,
--   REBATE_RESERVED_C                          numeric(18, 2),
--   REBATE_ACTUAL_C                            numeric(18, 2),
--   INSPECTION_WAIVER_C                        BOOLEAN,
--   FINANCING_PREPAYMENT_C                     numeric(18, 2),
--   REASON_FOR_CANCELLATION_C                  VARCHAR(765),
--   BOOKING_TEMPLATE_SENT_TO_LD_C              DATE,
--   ACCOUNT_C                                  VARCHAR(18),
--   CONTACT_C                                  VARCHAR(18),
--   DEALER_ORIGINATION_FEE_C                   numeric(12, 2),
--   DEALER_REBATE_CLAIM_C                      numeric(12, 2),
--   END_CUSTOMER_ACCOUNT_C                     VARCHAR(18),
--   OPPORTUNITY_C                              VARCHAR(18),
--   PYMNT_CERT_MONTH_C                         VARCHAR(60),
--   QUOTE_C                                    VARCHAR(18),
--   SIZE_KWDC_C                                double precision,
--   PERFORMANCE_ACCEPTANCE_DATE_C              DATE,
--   PAYMENT_REQUEST_SUBMITTED_C                DATE,
--   INSTALL_ACCULMAGE_CONFIRMED_C              DATE,
--   INTERCONNECTION_ACCULMAGED_CONFIRMED_C     DATE,
--   LEASE_1_OR_2_C                             VARCHAR(765),
--   ANNUAL_PROD_REPORT_YR_1_C                  DATE,
--   TRANCHING_STATUS_C                         VARCHAR(765),
--   ANNUAL_ESCALATION_NOT_AVAILABLE_C          VARCHAR(765),
--   CUSTOMER_PROMISE_DATE_INVERTER_C           DATE,
--   CUSTOMER_PROMISE_DATE_MOUNTING_C           DATE,
--   CUSTOMER_PROMISE_DATE_PV_C                 DATE,
--   CUSTOMER_REQUEST_DATE_INVERTER_C           DATE,
--   CUSTOMER_REQUEST_DATE_MOUNTING_C           DATE,
--   AMENDMENT_REVISION_LEASE_NUMBER_1_C        VARCHAR(60),
--   LEASE_CHANGE_TYPE_C                        VARCHAR(765),
--   CUSTOMER_REQUEST_DATE_PV_C                 DATE,
--   ANNUAL_ESCALATION_OLD_C                    double precision,
--   BASE_MON_PYMNT_YR_1_OLD_C                  numeric(12, 2),
--   CREATE_LEASE_SUMMARY_C                     BOOLEAN,
--   DELIVERY_DATE_INVERTERS_C                  DATE,
--   DELIVERY_DATE_MOUNTING_C                   DATE,
--   DELIVERY_DATE_PV_C                         DATE,
--   FINANCIER_CHANGE_DATE_C                    DATE,
--   LEASE_COST_C                               numeric(18, 2),
--   PO_AMOUNT_INSTALLATION_C                   numeric(18, 2),
--   PO_AMOUNT_INTERCONNECT_C                   numeric(18, 2),
--   FAIR_MARKET_VALUE_ACCTG_C                  numeric(18, 2),
--   PO_AMOUNT_ORIGINATION_C                    numeric(18, 2),
--   DEALER_CONTACT_OLD_C                       VARCHAR(18),
--   PO_CREATION_DATE_INSTALLATION_C            TIMESTAMPTZ,
--   PO_CREATION_DATE_INTERCONNECT_C            TIMESTAMPTZ,
--   INVERTER_SERIAL_NUMBERS_C                  VARCHAR(180),
--   PO_CREATION_DATE_ORIGINATION_C             TIMESTAMPTZ,
--   DATE_LEASE_DOCUMENT_SIGNED_C               DATE,
--   SMS_INSTALLATION_CHECKLIST_RECEIVED_C      DATE,
--   SMS_INSTALLATION_CHECKLIST_APPROV_C        DATE,
--   LPS_NOTES_C                                VARCHAR(98304),
--   PTO_PRIOR_NTP_C                            VARCHAR(765),
--   CG_VALUATION_METHODOLOGY_C                 VARCHAR(765),
--   COND_PROG_LW_RCVD_OLD_C                    DATE,
--   CREDIT_CHECK_DATE_OLD_C                    DATE,
--   CREDIT_CHECK_STATUS_OLD_C                  VARCHAR(30),
--   DATE_OF_COMMISSIONING_C                    DATE,
--   X_1603_FINANCIER_C                         VARCHAR(765),
--   PO_RECEIPT_INSTALLATION_C                  VARCHAR(765),
--   ENERGY_START_DATE_C                        DATE,
--   SMS_ID_C                                   VARCHAR(18),
--   X_1603_STATUS_C                            VARCHAR(765),
--   X_1603_STATUS_DATE_C                       DATE,
--   X_1603_NOTES_C                             VARCHAR(765),
--   COST_BASIS_AMOUNT_C                        VARCHAR(765),
--   DEALER_FEE_TOTAL_OLD_C                     numeric(14, 2),
--   SOCIAL_SECURITY_NUMBER_C                   VARCHAR(27),
--   DEALER_NAME_OLD_C                          VARCHAR(540),
--   PO_RECEIPT_INTERCONNECT_C                  VARCHAR(765),
--   INVOICE_DOCUMENT_EMAIL_C                   VARCHAR(240),
--   DISPOSAL_FLAG_C                            VARCHAR(765),
--   DOCS_GEN_DATE_OLD_C                        DATE,
--   DOWN_PAYMENT_OLD_C                         numeric(9, 2),
--   EARLY_BUYOUT_DATE_OLD_C                    DATE,
--   REPORTING_FINANCIER_C                      VARCHAR(765),
--   EMAIL_1_OLD_C                              VARCHAR(240),
--   EMAIL_2_OLD_C                              VARCHAR(240),
--   LAST_INSTALL_DOC_SUBMISSION_C              DATE,
--   PO_RECEIPT_ORIGINATION_C                   VARCHAR(765),
--   LAST_INTERCONNECT_DOC_SUBMISSION_C         DATE,
--   EXPECTED_REBATE_OLD_C                      numeric(9, 2),
--   PAYMENT_AMOUNT_INSTALLATION_C              numeric(18, 2),
--   LESSEE_EMAIL_C                             VARCHAR(240),
--   PARTNER_ORACLE_VENDOR_EMAIL_C              VARCHAR(240),
--   PAYMENT_AMOUNT_INTERCONNECT_C              numeric(18, 2),
--   PAYMENT_AMOUNT_ORIGINATION_C               numeric(18, 2),
--   NOTICE_TO_PROCEED_SENT_TEXT_C              VARCHAR(765),
--   INSTALL_INV_APPRVD_TEXT_C                  VARCHAR(765),
--   SENT_INTERCONNECTION_EMAIL_C               BOOLEAN,
--   FIRST_NAME_1_OLD_C                         VARCHAR(105),
--   FIRST_NAME_2_OLD_C                         VARCHAR(105),
--   FULL_PREPAID_LEASE_OLD_C                   BOOLEAN,
--   FULL_PREPAYMENT_AMT_OLD_C                  numeric(9, 2),
--   INTERCONNECTION_EMAIL_SENT_C               BOOLEAN,
--   HOME_PHONE_OLD_C                           VARCHAR(120),
--   PENDING_INTERCONNECTION_EMAIL_SENT_C       BOOLEAN,
--   ANNUAL_PROD_REPORT_YR_2_C                  DATE,
--   ANNUAL_PROD_REPORT_YR_3_C                  DATE,
--   ANNUAL_PROD_REPORT_YR_4_C                  DATE,
--   ANNUAL_PROD_REPORT_YR_5_C                  DATE,
--   AWARD_AMOUNT_C                             numeric(12, 2),
--   FMV_PURCHASE_PRICE_C                       numeric(12, 2),
--   FINANCING_COMPLETION_PAYMENT_C             numeric(12, 2),
--   INCENTIVE_INTERCONNECT_DATE_C              DATE,
--   FMV_RATE_C                                 numeric(9, 7),
--   PAYMENT_DATE_INSTALLATION_C                DATE,
--   PAYMENT_DATE_INTERCONNECT_C                DATE,
--   PIS_ENTRY_DATE_C                           DATE,
--   NEW_HOMEOWNER_ACCOUNT_C                    VARCHAR(18),
--   INVERTER_BRAND_OLD_C                       VARCHAR(60),
--   INVERTER_MODEL_2_OLD_C                     VARCHAR(120),
--   INVERTER_MODEL_3_OLD_C                     double precision,
--   INVERTER_MODEL_OLD_C                       VARCHAR(120),
--   INVERTER_QTY_OLD_C                         double precision,
--   DEV_CO_C                                   VARCHAR(765),
--   LAST_NAME_1_OLD_C                          VARCHAR(105),
--   LAST_NAME_2_OLD_C                          VARCHAR(105),
--   PTO_LETTER_ISSUANCE_DATE_C                 DATE,
--   LEASE_TYPE_OLD_C                           VARCHAR(60),
--   LEASE_OLD_C                                VARCHAR(90),
--   BOS_COST_C                                 numeric(18, 2),
--   INVERTER_COST_C                            numeric(18, 2),
--   PAYMENT_DATE_ORIGINATION_C                 DATE,
--   MISC_COST_INTERNAL_FUTURE_USE_C            numeric(18, 2),
--   MISC_ITEMS_INSTALLER_C                     numeric(18, 2),
--   MONITORING_C                               numeric(18, 2),
--   MODULE_QTY_OLD_C                           double precision,
--   MODULE_OLD_C                               VARCHAR(60),
--   MONITORING_TYPE_OLD_C                      VARCHAR(150),
--   NET_DEALER_SERVICE_COST_C                  numeric(18, 2),
--   PV_COST_C                                  numeric(18, 2),
--   RACKING_COST_INSTALLER_C                   numeric(18, 2),
--   RACKING_COST_INTERNAL_C                    numeric(18, 2),
--   SALES_TAX_AMOUNT_C                         numeric(18, 2),
--   PURCHASE_ORDER_NUMBER_INSTALLATION_C       VARCHAR(765),
--   PSR_OLD_C                                  VARCHAR(150),
--   TOTAL_DEALER_SUPPLIED_MATERIAL_C           numeric(18, 2),
--   TOTAL_MATERIAL_COST_C                      numeric(18, 2),
--   PARTIAL_PREPAYMENT_OLD_C                   numeric(12, 2),
--   PURCHASE_ORDER_NUMBER_INTERCONNECT_C       VARCHAR(765),
--   PARTNER_ACCOUNT_OLD_C                      VARCHAR(18),
--   TOTAL_SPWR_SUPPLIER_MATERIAL_C             numeric(18, 2),
--   TOTAL_SERVICE_COST_DEALER_FEE_C            numeric(18, 2),
--   UPDATED_DELIVERY_DATE_C                    DATE,
--   AGREEMENT_C                                VARCHAR(18),
--   COMMISSIONING_APPROVED_C                   DATE,
--   COMMISSIONING_STATUS_C                     VARCHAR(765),
--   CONDUCTOR_INSPECTION_DATE_C                DATE,
--   PRICING_OLD_C                              VARCHAR(75),
--   CONDUCTOR_INSPECTION_STATUS_C              VARCHAR(765),
--   PROJ_INSTALL_COMPETE_OLD_C                 DATE,
--   PROJ_INSTALL_DATE_OLD_C                    DATE,
--   CONDUCTOR_INSPECTION_C                     VARCHAR(765),
--   CONSUEL_APPROVED_C                         VARCHAR(765),
--   CONSUEL_CERTIFICATION_RECEIVED_C           DATE,
--   RSM_OLD_C                                  VARCHAR(120),
--   CONSUEL_CERTIFICATION_REQUESTED_C          VARCHAR(765),
--   RACKING_MODEL_OLD_C                        VARCHAR(90),
--   RACKING_QTY_OLD_C                          double precision,
--   REBATE_ACTUAL_OLD_C                        numeric(18, 2),
--   DP_DELIVERY_RECEIPT_C                      DATE,
--   SO_NUMBER_OLD_C                            VARCHAR(30),
--   DECLARATION_PREALABLE_APPROVED_C           DATE,
--   DECLARATION_PREALABLE_REQUEST_DATE_C       DATE,
--   DECLARATION_PREALABLE_STATUS_C             VARCHAR(765),
--   SALES_TAX_OLD_C                            double precision,
--   DOCUMENTS_REMAINING_FOR_INSTALL_PAYMENTS_C double precision,
--   SITE_CITY_OLD_C                            VARCHAR(105),
--   SITE_COUNTY_OLD_C                          VARCHAR(105),
--   SITE_STATE_PROV_OLD_C                      VARCHAR(105),
--   SITE_STREET_OLD_C                          VARCHAR(765),
--   SITE_ZIP_POST_CODE_OLD_C                   VARCHAR(105),
--   DOSSIER_PREPARATION_C                      VARCHAR(765),
--   ERDF_APPROVED_C                            VARCHAR(765),
--   ERDF_DELIVERY_RECEIPT_DATE_EXPIRED_C       DATE,
--   ERDF_INTERCONNECTION_REQUEST_DATE_C        DATE,
--   SYSTEM_PRICE_OLD_C                         numeric(12, 2),
--   TOT_MONTHLY_PAYMENTS_OLD_C                 numeric(7, 2),
--   ERDF_PROPOSAL_APPROVED_DATE_C              DATE,
--   ERDF_STATUS_C                              VARCHAR(765),
--   WARR_SNS_APPRVD_OLD_C                      DATE,
--   FI_T_BONUS_APPROVAL_STATUS_C               VARCHAR(765),
--   WARR_SNS_RCVD_OLD_C                        DATE,
--   GRID_CONNECTION_APPROVAL_STATUS_C          VARCHAR(765),
--   PURCHASE_ORDER_NUMBER_ORIGINATION_C        VARCHAR(765),
--   Y_1_MONTHLY_PAYMENT_OLD_C                  numeric(6, 2),
--   DELETE_NOTE_C                              VARCHAR(297),
--   SALES_ORDER_NUMBER_C                       VARCHAR(765),
--   LEASE_DUP_C                                VARCHAR(90),
--   SCHED_DELIVERY_DATE_INVERTERS_C            DATE,
--   INSPECTION_WAIVER_RECEIVED_DATE_C          DATE,
--   SCHED_DELIVERY_DATE_MOUNTING_C             DATE,
--   SCHED_DELIVERY_DATE_PV_C                   DATE,
--   PSR_EMAIL_C                                VARCHAR(240),
--   INVOICE_ADMIN_2_C                          VARCHAR(18),
--   SCHEDULED_PAYMENT_DATE_INSTALLATION_C      DATE,
--   SCHEDULED_PAYMENT_DATE_INTERCONNECT_C      DATE,
--   SCHEDULED_PAYMENT_DATE_ORIGINATION_C       DATE,
--   SUBSTITUTE_REPORT_SUBMITTED_DATE_C         DATE,
--   SUPPLIER_INVOICE_AMOUNT_INSTALLATION_C     numeric(18, 2),
--   SUPPLIER_INVOICE_AMOUNT_INTERCONNECT_C     numeric(18, 2),
--   SUPPLIER_INVOICE_AMOUNT_ORIGINATION_C      numeric(18, 2),
--   SUPPLIER_INVOICE_NUMBER_INSTALLATION_C     VARCHAR(765),
--   SUPPLIER_INVOICE_NUMBER_INTERCONNECT_C     VARCHAR(765),
--   SUPPLIER_INVOICE_NUMBER_ORIGINATION_C      VARCHAR(765),
--   TRANCHE_1_BATCH_C                          VARCHAR(18),
--   TRANCHE_1_RESPONSE_C                       VARCHAR(765),
--   TRANCHE_2_BATCH_C                          VARCHAR(18),
--   TRANCHE_2_RESPONSE_C                       VARCHAR(765),
--   TRANCHE_3_BATCH_C                          VARCHAR(18),
--   TRANCHE_3_RESPONSE_C                       VARCHAR(765),
--   TRANCHE_NOTES_C                            VARCHAR(765),
--   X_1603_PLACED_IN_SERVICE_SUBMISSION_DATE_C DATE,
--   SUBMITTED_FOR_BOOKING_DATE_C               DATE,
--   BOOKED_DATE_C                              DATE,
--   ITC_CASH_GRANT_VALUATION_ACCTG_C           numeric(18, 2),
--   NOTICE_TO_PROCEED_EMAIL_SENT_C             BOOLEAN,
--   WITH_SH_INVENTORY_C                        BOOLEAN,
--   INSTALLATION_COMPLETED_C                   VARCHAR(765),
--   INSTALLATION_FEES_C                        numeric(18),
--   INSTALLATION_INVOCE_PAID_C                 DATE,
--   INSTALLATION_REQUEST_DATE_C                DATE,
--   INTERCONECTION_INVOICE_PAID_C              DATE,
--   INTERCONNECTION_DATE_C                     DATE,
--   INTERCONNECTION_FEES_C                     numeric(18),
--   INTERCONNECTION_REQUEST_DATE_C             DATE,
--   LEASE_OF_INTENT_STATUS_C                   VARCHAR(765),
--   LETTER_OF_INTENT_SIGNED_C                  DATE,
--   LETTER_OF_INTENT_STATUS_C                  VARCHAR(765),
--   MATERIALS_DELIVERED_C                      DATE,
--   METER_INSTALLATION_C                       VARCHAR(765),
--   ORDER_STATUS_C                             VARCHAR(765),
--   SITE_COUNTRY_OLD_C                         VARCHAR(150),
--   TPO_APPROVAL_STATUS_C                      VARCHAR(765),
--   TOWN_HALL_MAILING_ADDRESS_C                VARCHAR(765),
--   UNDER_WRITING_STATUS_C                     VARCHAR(765),
--   UNDER_WRITING_CALL_C                       VARCHAR(765),
--   UNDERWRITING_DISAPPROVED_REASON_C          VARCHAR(765),
--   UNDERWRITING_EMAIL_C                       VARCHAR(765),
--   NEW_HOMEOWNER_PRIMARY_CONTACT_C            VARCHAR(18),
--   COA_SIGNATURE_DATE_C                       DATE,
--   CRAE_NR_C                                  VARCHAR(765),
--   CALL_DATE_C                                DATE,
--   COMMISSIONING_DATE_PLANNED_C               DATE,
--   COMMISSIONING_REQUEST_DATE_TO_ERDF_C       DATE,
--   CONSUEL_CERTIFICATE_C                      VARCHAR(765),
--   DP_RECEIPT_DATE_C                          DATE,
--   DELIVERY_POINT_NUMBER_OF_PRODUCTION_C      VARCHAR(765),
--   DOCUMENTS_REMAINING_FOR_THE_COMMISSIONIN_C double precision,
--   ERDF_RECEIPT_DATE_OF_OUR_ORDER_C           DATE,
--   SPVT_MEASUREMENT_DATE_C                    DATE,
--   EMAIL_DATE_C                               DATE,
--   FILE_NR_C                                  VARCHAR(765),
--   FORWARDING_DATE_OF_THE_NON_OPPOSITION_CE_C DATE,
--   FORWARDING_DATE_TO_THE_PARTNER_C           DATE,
--   FORWARDING_DATE_TO_THE_TAX_DEPARTMENT_C    DATE,
--   HOMEOWNER_SIGNATURE_DATE_C                 DATE,
--   INSTALLATION_START_DATE_BY_THE_PARTNER_C   DATE,
--   INTERCONNECTION_PAYMENT_APPROVED_DATE_C    DATE,
--   INTERCONNECTION_PAYMENT_DATE_C             DATE,
--   INTERCONNECTION_QUOTATION_DATE_PDR_C       DATE,
--   METER_INSTALLATION_DATE_PLANNED_C          DATE,
--   NON_OPPOSITION_CERTIFICATE_DATE_C          DATE,
--   OA_CONTRACT_NUMBER_C                       VARCHAR(765),
--   PDR_ORDER_AND_PAYMENT_DATE_C               DATE,
--   QUALIFIED_INTERCONNECTION_REQUEST_DATE_C   DATE,
--   RECEIPT_FORWARDING_DATE_TO_THE_HO_PAR_C    DATE,
--   SIGNATURE_DATE_BY_THE_TAX_DEPARTMENT_C     DATE,
--   TECHNICAL_VISIT_DATE_PLANNED_C             DATE,
--   INVOICE_COMPLIANCE_NOTES_C                 VARCHAR(98304),
--   RECOMMENDED_FOLLOW_UP_DATE_C               DATE,
--   SPVT_RESULT_C                              VARCHAR(765),
--   SPVT_CASE_TO_SUN_POWER_C                   BOOLEAN,
--   RECOMMENDED_FOLLOW_UP_DATE_UIR_C           DATE,
--   SENT_ENERGY_PRODUCING_EMAIL_C              BOOLEAN,
--   GUARANTEE_START_DATE_C                     DATE,
--   ELECTRICITY_DISTRIBUTOR_C                  VARCHAR(765),
--   ORIGINATION_PAYMENT_APPROVED_C             DATE,
--   ORIGINATION_INVOICE_AMOUNT_C               double precision,
--   ORIGINATION_INVOICE_NUMBER_C               VARCHAR(96),
--   ORIGINATION_PAYMENT_DATE_C                 DATE,
--   ORIGINATION_PAYMENT_SUBMITTED_C            DATE,
--   PTC_DATE_C                                 DATE,
--   ORIGINATION_ACCULMAGE_CONFIRMED_C          DATE,
--   SREC_FINANCIER_C                           VARCHAR(18),
--   NOTE_TO_DEALER_ORIGINATION_C               VARCHAR(765),
--   INTERCONNECT_HOLD_RELEASE_SENT_TO_AP_C     DATE,
--   SPVT_RESULT_PASS_DATE_C                    DATE,
--   DEALER_FEE_ORIGINATION_PO_RECEIPT_COMPLE_C DATE,
--   DEALER_FEE_ORIGINATION_PO_RECEIPT_NUMBER_C VARCHAR(150),
--   ORIGINATION_INV_AMOUNT_C                   numeric(12, 2),
--   PROPOSAL_DESIGN_REVIEW_PASSED_C            BOOLEAN,
--   PIS_DEADLINE_DATE_C                        DATE,
--   D_4_D_CATEGORY_C                           VARCHAR(765),
--   SREC_JV_VALUE_C                            numeric(18, 2),
--   PIS_ESTIMATION_C                           VARCHAR(60),
--   ESS_COMMISSION_DATE_C                      DATE,
--   ESS_TERM_C                                 double precision,
--   ENERGY_SOLUTIONS_C                         VARCHAR(765),
--   MONTHLY_RESILIENCY_PAYMENT_C               numeric(18, 2),
--   SREC_SS_FACE_VALUE_C                       numeric(18, 2),
--   SREC_SS_SHORTFALL_VALUE_C                  numeric(18, 2),
--   TERMINATION_DATE_C                         DATE,
--   MOSAIC_STATUS_C                            VARCHAR(765),
--   RESIDENTIAL_PROJECT_C                      VARCHAR(18),
--   ORACLE_CANCELLATION_STATUS_C               VARCHAR(765),
--   APPROVED_INSTALL_DOCS_C                    double precision,
--   APPROVED_INTERCONNECT_DOCS_C               double precision,
--   APPROVED_ORIGINATION_DOCS_C                double precision,
--   SUBMITTED_INSTALL_DOCS_C                   double precision,
--   SUBMITTED_INTERCONNECT_DOCS_C              double precision,
--   SUBMITTED_ORIGINATION_DOCS_C               double precision,
--   TOTAL_INSTALL_DOCS_C                       double precision,
--   TOTAL_INTERCONNECT_DOCS_C                  double precision,
--   TOTAL_ORIGINATION_DOCS_C                   double precision,
--   NOTE_TO_DEALER_C                           DATE,
--   INTEGRATION_HISTORY_C                      VARCHAR(98304),
--   AUTO_AMENDMENT_HOLD_C                      BOOLEAN,
--   BUYDOWN_OVERRIDE_C                         BOOLEAN,
--   BATCH_04_DATE_C                            DATE,
--   DEVCO_BATCH_4_C                            VARCHAR(765),
--   HOLDBACK_NTP_B_C                           VARCHAR(765),
--   PURCHASE_NTP_B_C                           VARCHAR(765),
--   SETTLEMENT_NTP_B_C                         VARCHAR(765),
--   WELCOME_CALL_COMPLETE_C                    DATE,
--   _FIVETRAN_SYNCED                           TIMESTAMPTZ,
--   SREC_FINANCIERS_C                          VARCHAR(765),
--   AGREEMENT_TEXT_C                           VARCHAR(60),
--   ORDER_DESIRED_DATE_C                       DATE,
--   _FIVETRAN_DELETED                          BOOLEAN,
--   PRIMARY_CONTACT_EMAIL_C                    VARCHAR(240),
--   SETTLEMENT_SR_DEBT_C                       double precision,
--   HOLD_BACK_SR_DEBT_C                        double precision,
--   PURCHASE_PRICE_C                           double precision,
--   SETTLEMENT_HANNON_MEZZ_C                   double precision,
--   BATCH_01_DATE_C                            DATE,
--   SETTLEMENT_PRICE_C                         double precision,
--   SETTLEMENT_SUN_POWER_MEZZ_C                double precision,
--   BATCH_02_DATE_C                            DATE,
--   BATCH_03_DATE_C                            DATE,
--   FORECASTED_REVREC_C                        DATE,
--   HOLD_BACK_HANNON_MEZZ_C                    double precision,
--   SERVICER_OF_RECORD_C                       VARCHAR(765),
--   HOLD_BACK_TE_CASH_C                        double precision,
--   PURCHASE_HANNON_MEZZ_C                     double precision,
--   HOLD_BACK_SUNPOWER_MEZZ_C                  double precision,
--   DEVCO_BATCH_3_C                            VARCHAR(765),
--   DATE_COUNTERSIGNED_OLD_C                   DATE,
--   CONTRACT_STATUS_C                          VARCHAR(765),
--   PURCHASE_TE_CASH_C                         double precision,
--   DEVCO_BATCH_2_C                            VARCHAR(765),
--   DEVCO_BATCH_1_C                            VARCHAR(765),
--   SETTLEMENT_TE_CASH_C                       double precision,
--   PURCHASE_SR_DEBT_C                         double precision,
--   FUNDING_NOTES_C                            VARCHAR(765),
--   PURCHASE_SUN_POWER_MEZZ_C                  double precision,
--   FINAL_PERMITS_ENTERED_BY_C                 VARCHAR(18),
--   REV_REC_ENTRY_DATE_C                       TIMESTAMPTZ
-- );




-- CREATE INDEX if not exists REWORK_REQUESTS_C_residential_project_c ON brs.REWORK_REQUESTS_C (residential_project_c);
-- CREATE INDEX if not exists TASK_REWORK_REQUEST_C_residential_project_c ON brs.TASK_REWORK_REQUEST_C (residential_project_c);
-- CREATE INDEX if not exists work_order_id ON brs.work_order (id);
-- CREATE INDEX if not exists work_order_case_id ON brs.work_order (case_id);
-- CREATE INDEX if not exists work_order_residential_project_c ON brs.work_order (residential_project_c);
-- CREATE INDEX if not exists work_order_account_id ON brs.work_order (account_id);
-- CREATE INDEX if not exists case_id ON brs.case (id);
-- CREATE INDEX if not exists case_residential_project_c ON brs.case (residential_project_c);
-- CREATE INDEX if not exists case_CATEGORY_C ON brs.case (CATEGORY_C);
-- CREATE INDEX if not exists case_SUB_CATEGORIES_C ON brs.case (SUB_CATEGORIES_C);
-- CREATE INDEX if not exists case_STATUS ON brs.case (STATUS);
-- CREATE INDEX if not exists case_PARTNER_ACCOUNT_C ON brs.case (PARTNER_ACCOUNT_C);
-- CREATE INDEX if not exists OPPORTUNITY_id ON brs.OPPORTUNITY (id);
-- CREATE INDEX if not exists OPPORTUNITY_REASON_WON_LOST_C ON brs.OPPORTUNITY (REASON_WON_LOST_C);
-- CREATE INDEX if not exists OPPORTUNITY_SUB_STAGE_C ON brs.OPPORTUNITY (SUB_STAGE_C);
-- CREATE INDEX if not exists OPPORTUNITY_STAGE_NAME ON brs.OPPORTUNITY (STAGE_NAME);
-- CREATE INDEX if not exists TITLE_CHECK_C_id ON brs.TITLE_CHECK_C (id);
-- CREATE INDEX if not exists TITLE_CHECK_C_ACCOUNT_C ON brs.TITLE_CHECK_C (ACCOUNT_C);
-- CREATE INDEX if not exists TITLE_CHECK_C_ACTION_TAKEN_C ON brs.TITLE_CHECK_C (ACTION_TAKEN_C);
-- CREATE INDEX if not exists CREDIT_CHECK_REQUEST_C_id ON brs.CREDIT_CHECK_REQUEST_C (id);
-- CREATE INDEX if not exists CREDIT_CHECK_REQUEST_C_ACCOUNT_C ON brs.CREDIT_CHECK_REQUEST_C (ACCOUNT_C);
-- CREATE INDEX if not exists CREDIT_CHECK_REQUEST_C_lender_c ON brs.CREDIT_CHECK_REQUEST_C (lender_c);
-- CREATE INDEX if not exists CREDIT_CHECK_REQUEST_C_credit_beureu_c ON brs.CREDIT_CHECK_REQUEST_C (credit_beureu_c);
-- CREATE INDEX if not exists CREDIT_CHECK_REQUEST_C_bureau_c ON brs.CREDIT_CHECK_REQUEST_C (bureau_c);
-- CREATE INDEX if not exists CREDIT_CHECK_REQUEST_C_application_type_c ON brs.CREDIT_CHECK_REQUEST_C (application_type_c);
-- CREATE INDEX if not exists ALLIANCE_PARTNER_C_ALLIANCE_PARTNER_C ON brs.ALLIANCE_PARTNER_C (id);
-- CREATE INDEX if not exists ALLIANCE_PARTNER_C_COMMUNITY_C ON brs.ALLIANCE_PARTNER_C (COMMUNITY_C);
-- CREATE INDEX if not exists ALLIANCE_PARTNER_C_RESIDENTIAL_PROJECT_C ON brs.ALLIANCE_PARTNER_C (RESIDENTIAL_PROJECT_C);
-- CREATE INDEX if not exists ALLIANCE_PARTNER_C_ROLE_C ON brs.ALLIANCE_PARTNER_C (ROLE_C);
-- CREATE INDEX if not exists PROJECT_TASK_C_RESIDENTIAL_PROJECT_C ON brs.PROJECT_TASK_C (RESIDENTIAL_PROJECT_C);
-- CREATE INDEX if not exists PROJECT_TASK_C_id ON brs.PROJECT_TASK_C (id);
-- CREATE INDEX if not exists PROJECT_TASK_C_status_c ON brs.PROJECT_TASK_C (status_c);
-- CREATE INDEX if not exists PROJECT_TASK_C_record_type_id ON brs.PROJECT_TASK_C (record_type_id);
-- CREATE INDEX if not exists PROJECT_TASK_C_created_date ON brs.PROJECT_TASK_C (created_date);
-- CREATE INDEX if not exists PROJECT_TASK_C_is_deleted ON brs.PROJECT_TASK_C (is_deleted);
-- CREATE INDEX if not exists PROJECT_TASK_C_parent_task_c ON brs.PROJECT_TASK_C (parent_task_c);
-- CREATE INDEX if not exists account_nw_account_type ON brs.account (type);
-- CREATE INDEX if not exists nw_account_id ON brs.account (id);
-- CREATE INDEX if not exists account_nw_billing_state ON brs.account (billing_state);
-- CREATE INDEX if not exists account_nw_available_lender_c ON brs.account (available_lender_c);
-- CREATE INDEX if not exists account_nw_status_c ON brs.account (status_c);
-- CREATE INDEX if not exists nh_community_c_ncc_builder_c ON brs.nh_community_c (builder_c);
-- CREATE INDEX if not exists nh_community_c_ncc_state_c ON brs.nh_community_c (state_c);
-- CREATE INDEX if not exists nh_community_c_ncc_lease_term_c ON brs.nh_community_c (lease_term_c);
-- CREATE INDEX if not exists nh_community_c_ncc_weeks_prior_to_rough_install_for_cut_off_c ON brs.nh_community_c (weeks_prior_to_rough_install_for_cut_off_c);
-- CREATE INDEX if not exists nh_community_c_ncc_builder_architect_c ON brs.nh_community_c (builder_architect_c);
-- CREATE INDEX if not exists nh_community_c_ncc_builder_project_manager_c ON brs.nh_community_c (builder_project_manager_c);
-- CREATE INDEX if not exists nh_community_c_ncc_campaign_c ON brs.nh_community_c (campaign_c);
-- CREATE INDEX if not exists nh_community_c_ncc_competitor_c ON brs.nh_community_c (competitor_c);
-- CREATE INDEX if not exists nh_community_c_ncc_distribution_type_c ON brs.nh_community_c (distribution_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_home_energy_source_c ON brs.nh_community_c (home_energy_source_c);
-- CREATE INDEX if not exists nh_community_c_ncc_multi_family_interconnection_c ON brs.nh_community_c (multi_family_interconnection_c);
-- CREATE INDEX if not exists nh_community_c_ncc_pre_plumb_c ON brs.nh_community_c (pre_plumb_c);
-- CREATE INDEX if not exists nh_community_c_ncc_reason_won_lost_c ON brs.nh_community_c (reason_won_lost_c);
-- CREATE INDEX if not exists nh_community_c_ncc_rough_wire_c ON brs.nh_community_c (rough_wire_c);
-- CREATE INDEX if not exists nh_community_c_ncc_type_of_release_c ON brs.nh_community_c (type_of_release_c);
-- CREATE INDEX if not exists nh_community_c_ncc_stage_c ON brs.nh_community_c (stage_c);
-- CREATE INDEX if not exists nh_community_c_ncc_building_type_c ON brs.nh_community_c (building_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_ownership_type_c ON brs.nh_community_c (ownership_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_financial_offering_c ON brs.nh_community_c (financial_offering_c);
-- CREATE INDEX if not exists nh_community_c_ncc_permit_pack_type_c ON brs.nh_community_c (permit_pack_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_permitting_responsibility_c ON brs.nh_community_c (permitting_responsibility_c);
-- CREATE INDEX if not exists nh_community_c_ncc_ssp_required_c ON brs.nh_community_c (ssp_required_c);
-- CREATE INDEX if not exists nh_community_c_ncc_ess_permit_pack_type_c ON brs.nh_community_c (ess_permit_pack_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_ess_permitting_responsibility_c ON brs.nh_community_c (ess_permitting_responsibility_c);
-- CREATE INDEX if not exists nh_community_c_ncc_mounting_type_c ON brs.nh_community_c (mounting_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_roof_attachment_c ON brs.nh_community_c (roof_attachment_c);
-- CREATE INDEX if not exists nh_community_c_ncc_multi_family_array_c ON brs.nh_community_c (multi_family_array_c);
-- CREATE INDEX if not exists nh_community_c_ncc_roof_type_c ON brs.nh_community_c (roof_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_installation_type_c ON brs.nh_community_c (installation_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_inverter_type_c ON brs.nh_community_c (inverter_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_structural_options_enhancements_c ON brs.nh_community_c (structural_options_enhancements_c);
-- CREATE INDEX if not exists nh_community_c_ncc_evse_offering_c ON brs.nh_community_c (evse_offering_c);
-- CREATE INDEX if not exists nh_community_c_ncc_builder_file_validation_c ON brs.nh_community_c (builder_file_validation_c);
-- CREATE INDEX if not exists nh_community_c_ncc_storage_type_c ON brs.nh_community_c (storage_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_storage_backup_type_c ON brs.nh_community_c (storage_backup_type_c);
-- CREATE INDEX if not exists nh_community_c_ncc_rebate_program_c ON brs.nh_community_c (rebate_program_c);
-- CREATE INDEX if not exists nh_community_c_ncc_rebate_payable_to_c ON brs.nh_community_c (rebate_payable_to_c);
-- CREATE INDEX if not exists nh_community_c_ncc_COMMUNITY_ADDER_C ON brs.nh_community_c (COMMUNITY_ADDER_C);
-- CREATE INDEX if not exists plan_type_c_ptc_CFI_C ON brs.plan_type_c (CFI_C);
-- CREATE INDEX if not exists plan_type_c_ptc_code_level_c ON brs.plan_type_c (code_level_c);
-- CREATE INDEX if not exists DESIGN_C_id ON brs.DESIGN_C (id);
-- CREATE INDEX if not exists MODULE_CONFIGURATION_C_id ON brs.MODULE_CONFIGURATION_C (id);
-- CREATE INDEX if not exists PLAN_TYPE_C_id ON brs.PLAN_TYPE_C (id);
-- CREATE INDEX if not exists NH_CONTRACTS_C_id ON brs.NH_CONTRACTS_C (id);
-- CREATE INDEX if not exists NH_COMMUNITY_VISIT_C_id ON brs.NH_COMMUNITY_VISIT_C (id);
-- CREATE INDEX if not exists NH_COMMUNITY_VISIT_C_nh_community_c ON brs.NH_COMMUNITY_VISIT_C (nh_community_c);
-- CREATE INDEX if not exists NH_COMMUNITY_C_id ON brs.NH_COMMUNITY_C (id);
-- CREATE INDEX if not exists CAMPAIGN_id ON brs.CAMPAIGN (id);
-- CREATE INDEX if not exists BUILDER_PRICING_C_id ON brs.BUILDER_PRICING_C (id);
-- CREATE INDEX if not exists BUILDER_PRICING_C_community_c ON brs.BUILDER_PRICING_C (community_c);
-- CREATE INDEX if not exists ALLIANCE_PARTNER_C_id ON brs.ALLIANCE_PARTNER_C (id);
-- CREATE INDEX if not exists AHJ_UTILITY_C_id ON brs.AHJ_UTILITY_C (id);
-- CREATE INDEX if not exists ACCOUNT_id_id ON brs.ACCOUNT (id);
-- CREATE INDEX if not exists RESIDENTIAL_PROJECT_C_id ON brs.RESIDENTIAL_PROJECT_C (id);
-- CREATE INDEX if not exists campaign_nh_community_c_id ON brs.campaign (nh_community_c);
-- CREATE INDEX if not exists plan_type_c_community_c ON brs.plan_type_c (community_c);
-- CREATE INDEX if not exists DESIGN_C_nh_NEW_HOMES_COMMUNITY_C_id ON brs.DESIGN_C (NEW_HOMES_COMMUNITY_C);
-- CREATE INDEX if not exists DESIGN_C_nh_reason_level_2_c_id ON brs.DESIGN_C (reason_level_2_c);
-- CREATE INDEX if not exists DESIGN_C_nh_reason_level_1_c ON brs.DESIGN_C (reason_level_1_c);
-- CREATE INDEX if not exists DESIGN_C_nh_mppp_revision_needed_c ON brs.DESIGN_C (mppp_revision_needed_c);
-- CREATE INDEX if not exists DESIGN_C_nh_urgent_request_type_c ON brs.DESIGN_C (nh_urgent_request_type_c);
-- CREATE INDEX if not exists DESIGN_C_incoming_request_had_all_information_c ON brs.DESIGN_C (incoming_request_had_all_information_c);
-- CREATE INDEX if not exists DESIGN_C_pdf_copy_only_c ON brs.DESIGN_C (pdf_copy_only_c);
-- CREATE INDEX if not exists DESIGN_C_electrical_pe_signature_c ON brs.DESIGN_C (electrical_pe_signature_c);
-- CREATE INDEX if not exists DESIGN_C_structural_pe_signature_c ON brs.DESIGN_C (structural_pe_signature_c);
-- CREATE INDEX if not exists residential_project_c_priority_c ON brs.residential_project_c (priority_c);
-- CREATE INDEX if not exists residential_project_c_community_c ON brs.residential_project_c (community_c);
-- CREATE INDEX if not exists rpc_cancellation_justification_c ON brs.residential_project_c (cancellation_justification_c);
-- CREATE INDEX if not exists rpc_sun_power_deal_type_c ON brs.residential_project_c (sun_power_deal_type_c);
-- CREATE INDEX if not exists rpc_sun_vault_deal_type_c ON brs.residential_project_c (sun_vault_deal_type_c);
-- CREATE INDEX if not exists rpc_rescheduled_reason_code_c ON brs.residential_project_c (rescheduled_reason_code_c);
-- CREATE INDEX if not exists rpc_rp_fields_and_builder_files_validated_c ON brs.residential_project_c (rp_fields_and_builder_files_validated_c);
-- CREATE INDEX if not exists rpc_block_reason_c ON brs.residential_project_c (block_reason_c);
-- CREATE INDEX if not exists rpc_monitoring_c ON brs.residential_project_c (monitoring_c);
-- CREATE INDEX if not exists rpc_roof_attachment_c ON brs.residential_project_c (roof_attachment_c);
-- CREATE INDEX if not exists rpc_smart_thermostat_c ON brs.residential_project_c (smart_thermostat_c);
-- CREATE INDEX if not exists rpc_thermostat_manufacturer_c ON brs.residential_project_c (thermostat_manufacturer_c);
-- CREATE INDEX if not exists rpc_thermostat_model_c ON brs.residential_project_c (thermostat_model_c);
-- CREATE INDEX if not exists rpc_installation_type_c ON brs.residential_project_c (installation_type_c);
-- CREATE INDEX if not exists rpc_roof_type_c ON brs.residential_project_c (roof_type_c);
-- CREATE INDEX if not exists rpc_type_of_design_c ON brs.residential_project_c (type_of_design_c);
-- CREATE INDEX if not exists rpc_roof_1_pitch_c ON brs.residential_project_c (roof_1_pitch_c);
-- CREATE INDEX if not exists rpc_proposed_solar_breaker_installed_in_msp_c ON brs.residential_project_c (proposed_solar_breaker_installed_in_msp_c);
-- CREATE INDEX if not exists rpc_pdf_copy_only_c ON brs.residential_project_c (pdf_copy_only_c);
-- CREATE INDEX if not exists rpc_roof_2_pitch_c ON brs.residential_project_c (roof_2_pitch_c);
-- CREATE INDEX if not exists rpc_roof_3_pitch_c ON brs.residential_project_c (roof_3_pitch_c);
-- CREATE INDEX if not exists rpc_roof_4_pitch_c ON brs.residential_project_c (roof_4_pitch_c);
-- CREATE INDEX if not exists rpc_further_discount_status_c ON brs.residential_project_c (further_discount_status_c);
-- CREATE INDEX if not exists rpc_microinverter_status_c ON brs.residential_project_c (microinverter_status_c);
-- CREATE INDEX if not exists rpc_pre_coe_comm_failure_reason_c ON brs.residential_project_c (pre_coe_comm_failure_reason_c);
-- CREATE INDEX if not exists rpc_utility_meter_installed_c ON brs.residential_project_c (utility_meter_installed_c);
-- CREATE INDEX if not exists rpc_system_activation_status_c ON brs.residential_project_c (system_activation_status_c);
-- CREATE INDEX if not exists rpc_rse_outcome_c ON brs.residential_project_c (rse_outcome_c);
-- CREATE INDEX if not exists rpc_pv_hers_certification_type_c ON brs.residential_project_c (pv_hers_certification_type_c);
-- CREATE INDEX if not exists rpc_nem_applicability_c ON brs.residential_project_c (nem_applicability_c);
-- CREATE INDEX if not exists rpc_internet_access_c ON brs.residential_project_c (internet_access_c);
-- CREATE INDEX if not exists rpc_preferred_communication_c ON brs.residential_project_c (preferred_communication_c);
-- CREATE INDEX if not exists rpc_tree_trim_c ON brs.residential_project_c (tree_trim_c);
-- CREATE INDEX if not exists rpc_attic_crawl_space_c ON brs.residential_project_c (attic_crawl_space_c);
-- CREATE INDEX if not exists rpc_dog_on_site_c ON brs.residential_project_c (dog_on_site_c);
-- CREATE INDEX if not exists rpc_customer_construction_project_c ON brs.residential_project_c (customer_construction_project_c);
-- CREATE INDEX if not exists rpc_complexity_indicator_c ON brs.residential_project_c (complexity_indicator_c);
-- CREATE INDEX if not exists builder_pricing_c_storage_size_c ON brs.builder_pricing_c (storage_size_c);
-- CREATE INDEX if not exists builder_pricing_c_code_year_c ON brs.builder_pricing_c (code_year_c);
-- CREATE INDEX if not exists nh_community_visit_c_role_c ON brs.nh_community_visit_c (role_c);
-- CREATE INDEX if not exists project_task_c_project_priority_c ON brs.project_task_c (project_priority_c);
-- CREATE INDEX if not exists project_task_c_role_assignment_c ON brs.project_task_c (role_assignment_c);
-- CREATE INDEX if not exists project_task_c_blocks_c ON brs.project_task_c (blocks_c);
-- CREATE INDEX if not exists project_task_c_path_type_c_123 ON brs.project_task_c ( upper(path_type_c));
-- CREATE INDEX if not exists project_task_c_reason_levels_c ON brs.project_task_c (reason_levels_c);
-- CREATE INDEX if not exists project_task_c_task_path_type_c ON brs.project_task_c (task_path_type_c);
-- CREATE INDEX if not exists residential_project_c_opportunity_c ON brs.residential_project_c (opportunity_c);
-- CREATE INDEX if not exists work_order_cancellation_details_c ON brs.work_order (cancellation_details_c);
-- CREATE INDEX if not exists work_order_service_request_type_c ON brs.work_order (service_request_type_c);
-- CREATE INDEX if not exists work_order_cancellation_reasons_c ON brs.work_order (cancellation_reasons_c);
-- CREATE INDEX if not exists work_order_opportunity_c ON brs.work_order (opportunity_c);
-- CREATE INDEX if not exists work_order_priority ON brs.work_order (priority);
-- CREATE INDEX if not exists work_order_service_type_c ON brs.work_order (service_type_c);
-- CREATE INDEX if not exists work_order_disposition_reason_c ON brs.work_order (disposition_reason_c);
-- CREATE INDEX if not exists work_order_inspection_type_c ON brs.work_order (inspection_type_c);
-- CREATE INDEX if not exists work_order_follow_up_reason_c ON brs.work_order (follow_up_reason_c);
-- CREATE INDEX if not exists task_rework_request_c_severity_c ON brs.task_rework_request_c (severity_c);
-- CREATE INDEX if not exists task_rework_request_c_rca_tag_c ON brs.task_rework_request_c (rca_tag_c);
-- CREATE INDEX if not exists rework_requests_c_action_required_c ON brs.rework_requests_c (action_required_c);
-- CREATE INDEX if not exists rework_requests_c_rework_quality_tag_c ON brs.rework_requests_c (rework_quality_tag_c);
-- CREATE INDEX if not exists rework_requests_c_rework_reason_c ON brs.rework_requests_c (rework_reason_c);
-- CREATE INDEX if not exists rework_requests_c_rework_reason_2_c ON brs.rework_requests_c (rework_reason_2_c);
-- CREATE INDEX if not exists rework_requests_c_rework_reason_3_c ON brs.rework_requests_c (rework_reason_3_c);
-- CREATE INDEX if not exists quote_account_c ON brs.quote (account_c);
-- CREATE INDEX if not exists quote_created_date ON brs.quote (created_date);
-- CREATE INDEX if not exists residential_project_c_account_c ON brs.residential_project_c (account_c);
-- CREATE INDEX if not exists quote_inverter_brand_c ON brs.quote (inverter_brand_c);
-- CREATE INDEX if not exists quote_mounting_description_c ON brs.quote (mounting_description_c);
-- CREATE INDEX if not exists quote_monitoring_system_c ON brs.quote (monitoring_system_c);
-- CREATE INDEX if not exists quote_non_backup_storage_acknowledged_c ON brs.quote (non_backup_storage_acknowledged_c);
-- CREATE INDEX if not exists quote_credit_bureau_c ON brs.quote (credit_bureau_c);
-- CREATE INDEX if not exists quote_lease_doc_reviewed_c ON brs.quote (lease_doc_reviewed_c);
-- CREATE INDEX if not exists ds_agreement_c_account_c ON brs.ds_agreement_c (account_c);
--  CREATE INDEX if not exists ds_agreement_c_contract_type_c ON brs.ds_agreement_c (contract_type_c);
--  CREATE INDEX if not exists ds_agreement_c_cancellation_reason_c ON brs.ds_agreement_c (cancellation_reason_c);


-- CREATE INDEX if not exists lease_payment_c_x_1603_financier_c ON brs.lease_payment_c (x_1603_financier_c);
-- CREATE INDEX if not exists lease_payment_c_x_1603_status_c ON brs.lease_payment_c (x_1603_status_c);
-- CREATE INDEX if not exists lease_payment_c_dev_co_c ON brs.lease_payment_c (dev_co_c);
-- CREATE INDEX if not exists lease_payment_c_Funding_Tranche_c ON brs.lease_payment_c (Funding_Tranche_c);
-- CREATE INDEX if not exists lease_payment_c_Lease_1_or_2_c ON brs.lease_payment_c (Lease_1_or_2_c);
-- CREATE INDEX if not exists lease_payment_c_Lease_Change_Hold_Disposition_c ON brs.lease_payment_c (Lease_Change_Hold_Disposition_c);
-- CREATE INDEX if not exists lease_payment_c_Mosaic_Status_c ON brs.lease_payment_c (Mosaic_Status_c);
-- CREATE INDEX if not exists lease_payment_c_Oracle_Cancellation_Status_c ON brs.lease_payment_c (Oracle_Cancellation_Status_c);
-- CREATE INDEX if not exists lease_payment_c_Reason_for_Cancellation_c ON brs.lease_payment_c (Reason_for_Cancellation_c);
-- CREATE INDEX if not exists lease_payment_c_Rebate_Authority_c ON brs.lease_payment_c (Rebate_Authority_c);
-- CREATE INDEX if not exists lease_payment_c_SPVT_Result_c ON brs.lease_payment_c (SPVT_Result_c);
-- CREATE INDEX if not exists lease_payment_c_Stage_c ON brs.lease_payment_c (Stage_c);
-- CREATE INDEX if not exists lease_payment_c_Tranche_1_Response_c ON brs.lease_payment_c (Tranche_1_Response_c);
-- CREATE INDEX if not exists lease_payment_c_Tranche_2_Response_c ON brs.lease_payment_c (Tranche_2_Response_c);
-- CREATE INDEX if not exists lease_payment_c_Tranche_3_Response_c ON brs.lease_payment_c (Tranche_3_Response_c);
-- CREATE INDEX if not exists lease_payment_c_Tranching_Status_c ON brs.lease_payment_c (Tranching_Status_c);
-- CREATE INDEX if not exists lease_payment_c_account_c ON brs.lease_payment_c (account_c);




SET session_replication_role = replica;
with update_data as (
  select u.first_name,u.last_name
  from flow.user_position upos
         join flow.user u on upos.user_id = u.id
         inner join brs.sp_user spu on u.first_name like spu.first_name  and u.last_name like spu.last_name
  where upos.position_id in (804,803,802)
    and is_active is true
  group by u.first_name,u.last_name
  having count(1) = 1),
     update_for_reals as (
       select u.id,spu.id as sunpower_id,u.first_name,u.last_name
       from flow.user u
              join flow.user_position upos on upos.user_id = u.id
              inner join update_data ud on ud.first_name = u.first_name and ud.last_name = u.last_name
              inner join brs.sp_user spu on u.first_name like spu.first_name  and u.last_name like spu.last_name and spu.is_active is true
       where upos.position_id in (804,803,802))
update flow."user" u2
set nh_migration_id = sunpower_id
from update_for_reals ufr
where ufr.id = u2.id;


DO --10 seconds
$do$
  declare
    x            record;
    v_contact_id bigint;
  v_object_category_id bigint;
  v_lov_available_lender_c bigint[];

  BEGIN
    select oc.id
      into v_object_category_id
        from flow.object_category oc
      where object_category_code = 'BUILDER_NEW_HOMES_BUILDER' and object_type_id= 2;
    for x in select lov1.id as status_c1 ,cs.id as company_state_id,
                    a.cash_partner_c,
                    a.contact_name_c,
                    a.credit_check_c,
                    a.credit_limit_c,
                    a.credit_limit_date_c,
                    a.default_dealer_warehouse_shipping_site_c,
                    a.description,
                    a.i_supplier_c,
                    a.legal_business_name_c,
                    a.rlcpa_notes_c,
                    a.shipping_city,
                    a.shipping_postal_code,
                    a.shipping_state,
                    a.shipping_street,
                    a.spwr_cash_partner_c,
                    a.website,
                    a.id,
                    a.name,
                    a.last_name,
                    a.billing_street,
                    a.billing_city,
                    a.billing_postal_code,
                    a.phone,
                    a.email_c,
                    a.account_number,
                    a.available_lender_c
             from brs.account a
                    left join flow.state s on s.abbreviation = a.billing_state
                    left join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
                    left join flow.list_of_value lov1 on lov1.name = a.status_c and lov1.parent_id = 25722
             where type = 'Builder'

      loop
        v_contact_id = null;
        insert into flow.contact(contact_type_id, first_name, last_name, street1, street2, city, postal_code, phone,
                                 email, mobile, date_created, date_modified, created_by_id, modified_by_id, company_id,
                                 archived,
                                 company_state_id, company_country_id, nw_migration_id,object_category_id)
        values (1, x.name, x.LAST_NAME, x.billing_street, null, x.billing_city, x.billing_postal_code, x.phone, x.email_c,
                x.phone, now(), now(), 2384850, 2384850, 3, false,
                x.company_state_id, 1, x.id,v_object_category_id)
        returning id into v_contact_id;

        if v_contact_id is not null then
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28812, x.account_number::text,true);
          v_lov_available_lender_c = null;
          if x.available_lender_c is not null then
            select array_agg(lov.id)
            into v_lov_available_lender_c
            from (
                   SELECT unnest(string_to_array(aggregated_column, ';')) available_lender_c
                   FROM (
                          SELECT STRING_AGG(available_lender_c, ';') AS aggregated_column
                          from brs.ACCOUNT A2
                          where id = x.id
                        ) AS subquery) as foo
                   inner join flow.list_of_value lov on lov.name = foo.available_lender_c and lov.parent_id = 25717;
            perform flow.set_contact_cfv(v_contact_id , 2384850,28813,v_lov_available_lender_c::text, true);
          end if;
         -- perform flow.set_contact_cfv(v_contact_id, 2384850, 28813, x.lov_available_lender_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28814, x.cash_partner_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28815, x.contact_name_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28816, x.credit_check_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28817, x.credit_limit_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28818, x.credit_limit_date_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28819, x.default_dealer_warehouse_shipping_site_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28820, x.description::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28821, x.i_supplier_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28822, x.legal_business_name_c::text,true);
          --perform flow.set_contact_cfv(v_contact_id, 2384850, 28823, x.owner_id::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28826, x.rlcpa_notes_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28831, x.shipping_city::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28832, x.shipping_postal_code::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28833, x.shipping_state::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28830, x.shipping_street::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28827, x.spwr_cash_partner_c::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28828, x.status_c1::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28829, x.website::text,true);
        end if;
      end loop;

  end
$do$;


DO  --2:38
$do$
  declare
    x record;
  v_object_category_id bigint;
  v_project_id bigint;
    v_community_adder_c bigint[];
    v_financial_offering_c bigint[];
  v_roof_attachment_c bigint[];
  BEGIN
    select oc.id
    into v_object_category_id
    from flow.object_category oc
    where object_category_code = 'COMMUNITY' and object_type_id = 1;
    for x in select c2.id as contact_id,
                    c.community_id_c,
                    c.number_of_homes_reserved_c,
                    c.sr_community_account_manager_c,
                    c.proposal_link_c,
                    c.account_manager_c,
                    c.expected_community_construction_start_c,
                    c.grand_opening_date_c,
                    c.number_of_homes_in_community_c,
                    c.field_manager_c,
                    c.sr_builder_operation_manager_c,
                    c.utility_c,
                    c.sr_community_account_manager_c,
                    c.ahj_c,
                    c.builder_initial_submitter_c,
                    c.tract_number_c,
                    c.model_discount_c,
                    c.lease_escalator_c,
                    c.flat_lease_community_c,
                    c.my_sun_power_c,
                    c.bulk_rp_creation_c,
                    c.builder_purchasing_contact_c,
                    c.builder_utility_rep_c,
                    c.community_adder_c,
                    c.distance_adder_c,
                    c.phase_cutover_c,
                    c.prevailing_wage_c,
                    c.prevailing_wage_details_c,
                    c.transition_notes_c,
                    c.utility_considerations_c,
                    c.region_c,
                    c.financial_offering_c,
                    c.preferred_pv_partner_c,
                    c.preferred_storage_partner_c,
                    c.community_superintendent_name_c,
                    c.community_superintendent_email_c,
                    c.community_superintendent_phone_number_c,
                    c.activation_coordinator_c,
                    c.tracking_number_c,
                    c.builder_delivery_info_c,
                    c.permit_ahj_fees_c,
                    c.permitting_notes_c,
                    c.master_permit_c,
                    c.builder_permitting_complete_c,
                    c.cash_pv_module_qty_c,
                    c.right_sized_c,
                    c.sheet_size_c,
                    c.roof_attachment_c,
                    c.multi_family_steep_roof_c,
                    c.custom_community_adder_c,
                    c.custom_adder_description_c,
                    c.storage_c,
                    c.climate_zone_c,
                    c.t_24_code_reserved_c,
                    c.rebate_reservation_expiry_date_c,
                    c.rebate_reservation_confirmation_number_c,
                    c.reservation_amount_per_project_c,
                    c.reserved_kw_c,
                    c.reservation_notes_c,
                    c.reserved_incentive_level_c,
                    c.registry_notes_c,
                    c.builder_hers_rater_c,
                    c.load_application_c,
                    c.load_application_received_c,
                    c.address_list_c,
                    c.address_list_info_complete_c,
                    c.architecture_files_c,
                    c.architecture_files_info_complete_c,
                    c.community_documents_folder_c,
                    c.document_notes_c,
                    c.electrical_diagram_c,
                    c.sequence_sheet_c,
                    c.sequence_sheet_info_complete_c,
                    c.site_plan_c,
                    c.site_plan_info_complete_c,cs.id as company_state_id,lov.id as lov_lease_term_c_id,
                    l.id as l_weeks_prior_to_rough_install_for_cut_off_c_id,
                    l1.id as l1_builder_architect_c_id,
                    l2.id as l1_builder_project_manager_c_id,
                    l3.id as l3_competitor_c_id,
                    l4.id as l4_distribution_type_c_id,
                    l5.id as l5_home_energy_source_c_id,
                    l6.id as l6_multi_family_interconnection_c_id,
                    l7.id as l7_pre_plumb_c_id,
                    l8.id as l8_reason_won_lost_c_id,
                    l9.id as l9_rough_wire_c_id,
                    l10.id as l10_type_of_release_c_id,
                    l11.id as l11_stage_c_id,
                    l12.id as l12_building_type_c_id,
                    l13.id as l13_OWNERSHIP_TYPE_C_id,
                    l15.id as l15_permit_pack_type_c_id,
                    l16.id as l16_PERMITTING_RESPONSIBILITY_C_id,
                    l17.id as l17_ssp_required_c_id,
                    l18.id as l18_ess_permit_pack_type_c_id,
                    l19.id as l19_ess_permitting_responsibility_c_id,
                    l20.id as l20_mounting_type_c_id,
                    l22.id as l22_multi_family_array_c_id,
                    l23.id as l23_roof_type_c_id,
                    l24.id as l24_installation_type_c_id,
                    l25.id as l25_inverter_type_c_id,
                    l26.id as l26_structural_options_enhancements_c_id,
                    l27.id as l27_evse_offering_c_id,
                    l28.id as l28_builder_file_validation_c_id,
                    l29.id as l29_storage_type_c_id,
                    l30.id as l30_storage_backup_type_c_id,
                    l31.id as l31_rebate_program_c_id,
                    l32.id as l32_rebate_payable_to_c_id,
                    l33.id as l33_community_type_c_id,
                    c.community_status_c,
                    c.name,
                    c.id,
                    c.zip_code_c,
                    c.city_location_c,
                    c.IS_DELETED,
                    c.builder_preferred_roofer_c
             from brs.NH_COMMUNITY_C c
                    inner join brs.account a on a.id = c.builder_c
                    inner join flow.contact c2 on c2.nw_migration_id = a.id
                    left join flow.state s on s.abbreviation = c.state_c
                    left join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
                    left join flow.list_of_value lov on lov.name = c.lease_term_c and lov.parent_id = 25216
                    left join flow.list_of_value l on l.name = c.weeks_prior_to_rough_install_for_cut_off_c and l.parent_id = 25214
                    left join flow.list_of_value l1 on l1.name = c.builder_architect_c and l1.parent_id = 25180
                    left join flow.list_of_value l2 on l2.name = c.builder_project_manager_c and l2.parent_id = 25180
                    left join flow.list_of_value l3 on l3.name = c.competitor_c and l3.parent_id =25232
                    left join flow.list_of_value l4 on l4.name = c.distribution_type_c and l4.parent_id =25222
                    left join flow.list_of_value l5 on l5.name = c.home_energy_source_c and l5.parent_id =25242
                    left join flow.list_of_value l6 on l6.name = c.multi_family_interconnection_c and l6.parent_id =25244
                    left join flow.list_of_value l7 on l7.name = c.pre_plumb_c and l7.parent_id =25234
                    left join flow.list_of_value l8 on l8.name = c.reason_won_lost_c and l8.parent_id =25231
                    left join flow.list_of_value l9 on l9.name = c.rough_wire_c and l9.parent_id =25238
                    left join flow.list_of_value l10 on l10.name = c.type_of_release_c and l10.parent_id =25240
                    left join flow.list_of_value l11 on l11.name = c.stage_c and l11.parent_id =25224
                    left join flow.list_of_value l12 on l12.name = c.building_type_c and l12.parent_id =25176
                    left join flow.list_of_value l13 on l13.name = c.OWNERSHIP_TYPE_C and l13.parent_id =25180
                    left join flow.list_of_value l15 on l15.name = c.permit_pack_type_c and l15.parent_id =25246
                    left join flow.list_of_value l16 on l16.name = c.PERMITTING_RESPONSIBILITY_C and l16.parent_id =25248
                    left join flow.list_of_value l17 on l17.name = c.ssp_required_c and l17.parent_id =25250
                    left join flow.list_of_value l18 on l18.name = c.ess_permit_pack_type_c and l18.parent_id =25252
                    left join flow.list_of_value l19 on l19.name = c.ess_permitting_responsibility_c and l19.parent_id =25254
                    left join flow.list_of_value l20 on l20.name = c.mounting_type_c and l20.parent_id =25258
                    left join flow.list_of_value l22 on l22.name = c.multi_family_array_c and l22.parent_id =25262
                    left join flow.list_of_value l23 on l23.name = c.roof_type_c and l23.parent_id =25264
                    left join flow.list_of_value l24 on l24.name = c.installation_type_c and l24.parent_id =25266
                    left join flow.list_of_value l25 on l25.name = c.inverter_type_c and l25.parent_id =25268
                    left join flow.list_of_value l26 on l26.name = c.structural_options_enhancements_c and l26.parent_id =25270
                    left join flow.list_of_value l27 on l27.name = c.evse_offering_c and l27.parent_id =25272
                    left join flow.list_of_value l28 on l28.name = c.builder_file_validation_c and l28.parent_id =25274
                    left join flow.list_of_value l29 on l29.name = c.storage_type_c and l29.parent_id =25171
                    left join flow.list_of_value l30 on l30.name = c.storage_backup_type_c and l30.parent_id =25208
                    left join flow.list_of_value l31 on l31.name = c.rebate_program_c and l31.parent_id =25276
                    left join flow.list_of_value l32 on l32.name = c.rebate_payable_to_c and l32.parent_id =25278
                    left join flow.list_of_value l33 on l33.name = c.community_type_c and l33.parent_id =25162
      loop
        v_project_id = null;
        v_community_adder_c = null;
        v_financial_offering_c = null;
        v_roof_attachment_c = null;
        insert into flow.project( contact_id, company_process_id, project_name, date_created, date_modified,
                                 created_by_id, modified_by_id, company_project_status_type_id,
                                 company_state_id,city,postal_code,
                                 company_country_id, archived,object_category_id,nw_migration_id)
        values(x.contact_id,26,x.name,now(),now(),
               2384850,2384850,case when x.IS_DELETED is true and x.community_status_c is null then 225
                                    when x.community_status_c is null then 223
                                    when x.community_status_c = 'Hold' then 224
                                    when x.community_status_c = 'Active' then 223
                                    when x.community_status_c = 'Cancelled' then 225
                                    when x.community_status_c = 'Construction Complete' then 226
                                    when x.community_status_c = 'Closed' then 227 end,x.company_state_id,x.city_location_c,x.zip_code_c,1,false,v_object_category_id,x.id) returning id into v_project_id;

        if v_project_id is not null then
          perform flow.set_project_cfv(v_project_id , 2384850,27998,x.community_id_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27999,x.number_of_homes_reserved_c::text , true);
          --perform flow.set_project_cfv(v_project_id , 2384850,28005,x.sr_community_account_manager_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28011,x.proposal_link_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27979,x.l33_community_type_c_id::text , true);
          --perform flow.set_project_cfv(v_project_id , 2384850,27980,x.account_manager_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27981,x.expected_community_construction_start_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27982,x.grand_opening_date_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27983,x.number_of_homes_in_community_c::text , true);
     --TODO check this dup with below     perform flow.set_project_cfv(v_project_id , 2384850,27996,x.my_sun_power_c::text , true);
         -- perform flow.set_project_cfv(v_project_id , 2384850,27988,x.field_manager_c::text , true);
         -- perform flow.set_project_cfv(v_project_id , 2384850,27989,x.sr_builder_operation_manager_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28006,x.utility_c::text , true);
          --perform flow.set_project_cfv(v_project_id , 2384850,28005,x.sr_community_account_manager_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28007,x.ahj_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28010,x.builder_initial_submitter_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28008,x.tract_number_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28000,x.model_discount_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28001,x.lov_lease_term_c_id::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28002,x.lease_escalator_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28003,x.flat_lease_community_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27996,x.my_sun_power_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28004,x.bulk_rp_creation_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28009,x.l_weeks_prior_to_rough_install_for_cut_off_c_id::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28030,x.l1_builder_architect_c_id::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28031,x.l1_builder_project_manager_c_id::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28029,x.builder_purchasing_contact_c::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28034,x.builder_utility_rep_c::text , true);
          v_community_adder_c = null;
          if x.community_adder_c is not null then
            select array_agg(lov.id)
            into v_community_adder_c
            from (
                   SELECT unnest(string_to_array(aggregated_column, ';')) community_adder_c
                   FROM (
                          SELECT STRING_AGG(community_adder_c, ';') AS aggregated_column
                          from brs.nh_community_c ncc
                          where id = x.id
                        ) AS subquery) as foo
                   inner join flow.list_of_value lov on lov.name = foo.community_adder_c and lov.parent_id = 25236;
            perform flow.set_project_cfv(v_project_id , 2384850,28025,v_community_adder_c::text, true);
          end if;

          perform flow.set_project_cfv(v_project_id , 2384850,28015,x.l3_competitor_c_id::text , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28027,x.distance_adder_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28016,x.l4_distribution_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28035,x.l5_home_energy_source_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28036,x.l6_multi_family_interconnection_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28033,x.phase_cutover_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28024,x.l7_pre_plumb_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28037,x.prevailing_wage_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28038,x.prevailing_wage_details_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28014,x.l8_reason_won_lost_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28026,x.l9_rough_wire_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28032,x.transition_notes_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28028,x.l10_type_of_release_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28013,x.l11_stage_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27984,x.utility_considerations_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27986,x.l12_building_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27987,x.l13_OWNERSHIP_TYPE_C_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28017,x.region_c::text, true);
           v_financial_offering_c = null;
          if x.financial_offering_c is not null then
            select array_agg(lov.id)
            into v_financial_offering_c
            from (
                   SELECT unnest(string_to_array(aggregated_column, ';')) financial_offering_c
                   FROM (
                          SELECT STRING_AGG(financial_offering_c, ';') AS aggregated_column
                          from brs.nh_community_c ncc
                          where id = x.id
                        ) AS subquery) as foo
                   inner join flow.list_of_value lov on lov.name = foo.financial_offering_c and lov.parent_id = 25184;
            perform flow.set_project_cfv(v_project_id , 2384850,27990,v_financial_offering_c::text, true);
          end if;

          perform flow.set_project_cfv(v_project_id , 2384850,28018,x.builder_preferred_roofer_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28019,x.preferred_pv_partner_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28020,x.preferred_storage_partner_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28021,x.community_superintendent_name_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28022,x.community_superintendent_email_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28023,x.community_superintendent_phone_number_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28725,x.activation_coordinator_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28040,x.tracking_number_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28039,x.l15_permit_pack_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28041,x.l16_PERMITTING_RESPONSIBILITY_C_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28042,x.builder_delivery_info_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28043,x.l17_ssp_required_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28044,x.permit_ahj_fees_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28093,x.permitting_notes_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28045,x.master_permit_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28046,x.builder_permitting_complete_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28047,x.l18_ess_permit_pack_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28048,x.l19_ess_permitting_responsibility_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28049,x.cash_pv_module_qty_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28051,x.right_sized_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28052,x.l20_mounting_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28053,x.sheet_size_c::text, true);
          v_roof_attachment_c = null;
          if x.roof_attachment_c is not null then
            select array_agg(lov.id)
            into v_roof_attachment_c
            from (
                   SELECT unnest(string_to_array(aggregated_column, ';')) roof_attachment_c
                   FROM (
                          SELECT STRING_AGG(roof_attachment_c, ';') AS aggregated_column
                          from brs.nh_community_c ncc
                          where id = x.id
                        ) AS subquery) as foo
                   inner join flow.list_of_value lov on lov.name = foo.roof_attachment_c and lov.parent_id = 25260;
            perform flow.set_project_cfv(v_project_id , 2384850,28054,v_roof_attachment_c::text, true);
          end if;
          perform flow.set_project_cfv(v_project_id , 2384850,28057,x.l22_multi_family_array_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28055,x.l23_roof_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28058,x.multi_family_steep_roof_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28055,x.l24_installation_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28059,x.custom_community_adder_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28060,x.custom_adder_description_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28062,x.l25_inverter_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28063,x.l26_structural_options_enhancements_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28064,x.l27_evse_offering_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28065,x.l28_builder_file_validation_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27985,x.l29_storage_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27995,x.l30_storage_backup_type_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28061,x.storage_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28066,x.l31_rebate_program_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28067,x.climate_zone_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28068,x.l32_rebate_payable_to_c_id::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28073,x.t_24_code_reserved_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28071,x.rebate_reservation_expiry_date_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28072,x.rebate_reservation_confirmation_number_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28075,x.reservation_amount_per_project_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28076,x.reserved_kw_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28077,x.reservation_notes_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28078,x.reserved_incentive_level_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28079,x.registry_notes_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28080,x.builder_hers_rater_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28435,x.load_application_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28436,x.load_application_received_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28082,x.address_list_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28083,x.address_list_info_complete_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28089,x.architecture_files_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28090,x.architecture_files_info_complete_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28086,x.community_documents_folder_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28092,x.document_notes_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28091,x.electrical_diagram_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28084,x.sequence_sheet_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28085,x.sequence_sheet_info_complete_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28087,x.site_plan_c::text, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28088,x.site_plan_info_complete_c::text, true);
        end if;

      end loop;

  end
$do$;


DO  --35 seconds
$do$
  declare
    x                                      record;
    y                                      record;
    z                                      record;
    t                                      record;
    s                                      record;
    w record;
    u record;
    v_project_process_step_plan_id              bigint;
    v_project_process_step_plan_event_id        bigint;
    v_project_process_step_design_id       bigint;
    v_project_process_step_event_design_id bigint;
    v_project_process_step_campaign_id     bigint;
    v_deliver_to_c_id                      bigint[];
    v_count bigint;
    v_project_process_step_pricing_id  bigint;
    v_project_process_step_pricing_event_id  bigint;
      v_project_process_step_visits_id  bigint;
  v_project_process_step_visits_events_id   bigint;
  BEGIN
    v_count = 0;
    for x in select p.id     as project_id,
                    co.id    as community_id
             from brs.NH_COMMUNITY_C co
                    inner join flow.project p on p.nw_migration_id = co.id
                    inner join brs.account a on a.id = co.builder_c
                    inner join flow.contact c2 on c2.nw_migration_id = a.id
      loop
        v_count = v_count + 1;
          if v_count = 1000 then
          raise notice 'v_count = %',v_count;
        v_count = 0;
          end if;
        v_project_process_step_plan_id = null;
        v_project_process_step_design_id = null;
        v_project_process_step_visits_id = null;
        v_project_process_step_pricing_id = null;
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3756, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
        returning id into v_project_process_step_plan_id;

        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3738, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
        returning id into v_project_process_step_design_id;

        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3789, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
        returning id into v_project_process_step_pricing_id;

        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3757, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
        returning id into v_project_process_step_visits_id;



        for u in select
                   c3.owner_id,
                   lov1.id as lov1_sales_status_c_id,
                   c3.end_date,
                   c3.short_description_c,
                   c3.description,
                   c3.solar_cut_off_c,
                   CASE WHEN row_number() OVER (PARTITION BY nh_community_c ORDER BY c3.created_date desc) = 1 THEN TRUE ELSE FALSE END AS is_last_row
          from brs.campaign c3
                 left join flow.list_of_value lov1 on lov1.name = c3.sales_status_c and lov1.parent_id = 25309
          where c3.nh_community_c = x.community_id
          order by c3.nh_community_c, c3.created_date
        loop
            v_project_process_step_campaign_id = null;
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (x.project_id, 3758, null, case when u.is_last_row is true then 1 else 2 end, null, now(), now(), 2384850, 2384850, false,
                    case when u.is_last_row is true then  true else false end, null, null, null)
            returning id into v_project_process_step_campaign_id;
            perform flow.set_pps_cfv(x.project_id, 2384850, 28116, u.lov1_sales_status_c_id::text, true);
            --perform flow.set_pps_cfv(x.project_id, 2384850, 28117, x.owner_id, true);
            perform flow.set_pps_cfv(x.project_id, 2384850, 28118, u.end_date::text, true);
            perform flow.set_pps_cfv(x.project_id, 2384850, 28119, u.short_description_c::text, true);
            perform flow.set_pps_cfv(x.project_id, 2384850, 28120, u.description::text, true);
            perform flow.set_pps_cfv(x.project_id, 2384850, 28121, u.solar_cut_off_c::text, true);
        end loop;

        for s in select bpc.active_c,
                        bpc.cash_incentive_fee_c,
                        bpc.lease_incentive_fee_c,
                        bpc.nem_3_0_lease_incentives_c,
                        bpc.net_contracted_price_c,
                        bpc.notes_c,
                        bpc.storage_configuration_group_c,
                        bpc.storage_price_c,
                        bpc.system_wattage_dc_c,
                        bpc.wrap_insurance_percent_c,
                        lov1.id as lov1_code_year_c,
                        lov2.id as lov2_storage_size_c
                 from brs.builder_pricing_c bpc
                        left join flow.list_of_value lov1 on lov1.name = bpc.code_year_c and lov1.parent_id = 25300
                        left join flow.list_of_value lov2 on lov2.name = bpc.storage_size_c and lov2.parent_id = 25562
                 where bpc.community_c = x.community_id

          loop
            v_project_process_step_pricing_event_id = null;
            insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                        company_event_status_type_id, start_time, end_time,
                                                        date_created,
                                                        date_modified, created_by_id, modified_by_id, archived,
                                                        cancelled_date, completed_date, scheduled_date, save_version)
            values (v_project_process_step_pricing_id, 239, null, 3, null, null, now(), now(), 2384850, 2384850, false, null,
                    null, null, 1)
            returning id into v_project_process_step_pricing_event_id;

            --  perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28099, y.CREATED_BY_ID, true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28732, s.active_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28572, s.cash_incentive_fee_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28574, s.lov1_code_year_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28575, s.lease_incentive_fee_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28576, s.nem_3_0_lease_incentives_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28585, s.net_contracted_price_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28570, s.notes_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28578, s.storage_configuration_group_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28580, s.storage_price_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28834, s.lov2_storage_size_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28582, s.system_wattage_dc_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_pricing_event_id, 2384850, 28583, s.wrap_insurance_percent_c::text,true);



          end loop;

        for t in select ncvc.visit_notes_c,
                        ncvc.RECENT_VISIT_DATE_C,
                        lov1.id as lov1_role_c_id
                 from brs.NH_COMMUNITY_VISIT_C ncvc
                 left join flow.list_of_value lov1 on lov1.name =ncvc.role_c and lov1.parent_id =25304
                 where ncvc.nh_community_c = x.community_id

          loop
            v_project_process_step_visits_events_id = null;
            insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                        company_event_status_type_id, start_time, end_time,
                                                        date_created,
                                                        date_modified, created_by_id, modified_by_id, archived,
                                                        cancelled_date, completed_date, scheduled_date, save_version)
            values (v_project_process_step_visits_id, 237, null, 3, t.RECENT_VISIT_DATE_C, null, now(), now(), 2384850, 2384850, false, null,
                    null, null, 1)
            returning id into v_project_process_step_visits_events_id;

            --  perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28099, y.CREATED_BY_ID, true);
            perform flow.set_pps_event_cfv(v_project_process_step_visits_events_id, 2384850, 28114, t.lov1_role_c_id::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_visits_events_id, 2384850, 28115, t.visit_notes_c::text,true);

          end loop;

        for y in select ptc.NAME,
                        ptc.ADDITIONAL_COST_FOR_STORAGE_C,
                        ptc.BASE_SQUARE_FOOTAGE_C,
                        ptc.flat_monthly_tpo_rate_c,
                        ptc.min_system_size_watts_c,
                        ptc.modules_c,
                        ptc.retail_value_c,
                        ptc.solar_access_c,
                        ptc.sun_vault_retail_value_c,
                        lov1.id as lov1_CFI_C_id,
                        lov2.id as lov2_code_level_c_id
                 from brs.plan_type_c ptc
                        left join flow.list_of_value lov1 on lov1.name = ptc.CFI_C and lov1.parent_id = 25293
                        left join flow.list_of_value lov2 on lov2.name = ptc.code_level_c and lov2.parent_id = 25300
                 where ptc.community_c = x.community_id

          loop
            v_project_process_step_plan_event_id = null;
            insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                        company_event_status_type_id, start_time, end_time,
                                                        date_created,
                                                        date_modified, created_by_id, modified_by_id, archived,
                                                        cancelled_date, completed_date, scheduled_date, save_version)
            values (v_project_process_step_plan_id, 236, null, 3, null, null, now(), now(), 2384850, 2384850, false, null,
                    null, null, 1)
            returning id into v_project_process_step_plan_event_id;

            --  perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28099, y.CREATED_BY_ID, true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28098, y.NAME::text, true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28100, y.ADDITIONAL_COST_FOR_STORAGE_C::text, true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28101, y.BASE_SQUARE_FOOTAGE_C::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28102, y.lov1_CFI_C_id::text, true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28103, y.lov2_code_level_c_id::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28104, y.flat_monthly_tpo_rate_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28105, y.min_system_size_watts_c::text,true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28107, y.modules_c::text, true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28108, y.retail_value_c::text, true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28109, y.solar_access_c::text, true);
            perform flow.set_pps_event_cfv(v_project_process_step_plan_event_id, 2384850, 28110, y.sun_vault_retail_value_c::text,true);

          end loop;
          for z in select dc.revision_of_c,
                          dc.missing_information_c,
                          dc.date_design_must_be_completed_c,
                          dc.date_design_request_verified_c,
                          dc.estimated_completion_date_c,
                          dc.design_start_date_c,
                          dc.date_completed_design_reviewed_c,
                          dc.design_completed_date_c,
                          dc.actual_time_hours_c,
                          dc.reason_for_late_delivery_c,
                          dc.for_eor_review_date_c,
                          dc.for_eor_rejection_date_c,
                          dc.design_approved_c,
                          dc.date_design_signed_c,
                          dc.date_design_shipped_c,
                          dc.applied_for_permit_c,
                          dc.permit_award_actual_c,
                          dc.shared_with_builder_c,
                          dc.design_work_located_in_c,
                          dc.number_of_sets_c,
                          dc.delivery_tracking_number_c,
                          dc.deliver_to_c,
                          dc.notes_from_requester_c,
                          dc.status_c,
                          dc.id,
                          lov1.id as lov1_mppp_revision_needed_c_id,
                          lov2.id as lov2_nh_urgent_request_type_c_id,
                          lov3.id as lov3_incoming_request_had_all_information_c_id,
                          lov4.id as lov4_pdf_copy_only_c_id,
                          lov5.id as lov5_electrical_pe_signature_c_id,
                          lov6.id as lov6_structural_pe_signature_c_id,
                          lov7.id as lov7_reason_level_1_c_id,
                          lov8.id as lov8_reason_level_2_c_id
                   from brs.DESIGN_C DC
                          left join flow.list_of_value lov1
                                    on lov1.name = dc.mppp_revision_needed_c and lov1.parent_id = 25617
                          left join flow.list_of_value lov2
                                    on lov2.name = dc.nh_urgent_request_type_c and lov2.parent_id = 25620
                          left join flow.list_of_value lov3
                                    on lov3.name = dc.incoming_request_had_all_information_c and lov3.parent_id = 25632
                          left join flow.list_of_value lov4 on lov4.name = dc.pdf_copy_only_c::text and lov4.parent_id = 25504
                          left join flow.list_of_value lov5
                                    on lov5.name = dc.electrical_pe_signature_c and lov5.parent_id = 25635
                          left join flow.list_of_value lov6
                                    on lov6.name = dc.structural_pe_signature_c and lov6.parent_id = 25643
                          left join flow.list_of_value lov7
                                    on lov7.name = dc.reason_level_1_c and lov7.parent_id = 25589
                          left join flow.list_of_value lov8
                                    on lov8.name = dc.reason_level_2_c and lov8.parent_id =25594
                   where dc.NEW_HOMES_COMMUNITY_C = x.community_id

            loop
              v_project_process_step_event_design_id = null;
              insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                          company_event_status_type_id, start_time, end_time,
                                                          date_created,
                                                          date_modified, created_by_id, modified_by_id, archived,
                                                          cancelled_date, completed_date, scheduled_date, save_version)
              values (v_project_process_step_design_id, 240, null,
                      case
                        when z.status_c is null then 90
                        when z.status_c = 'Not Started' then 90
                        when z.status_c = 'Pending MP Completion' then 91
                        when z.status_c = 'In Progress' then 106
                        when z.status_c = 'Request for Information' then 92
                        when z.status_c = 'Pending Information' then 93
                        when z.status_c = 'Under Review' then 94
                        when z.status_c = 'Rejected' then 95
                        when z.status_c = 'Approved' then 96
                        when z.status_c = 'For Plotting' then 97
                        when z.status_c = 'Reference Only' then 98
                        when z.status_c = 'Sent to Builder' then 99
                        when z.status_c = 'Submitted to AHJ' then 100
                        when z.status_c = 'Rejected with Comments' then 101
                        when z.status_c = 'Received AHJ Approval' then 102
                        when z.status_c = 'Delivered to Builder' then 103
                        when z.status_c = 'Revised' then 107
                        when z.status_c = 'Built Out' then 108
                        when z.status_c = 'Cancelled' then 104
                        when z.status_c = 'Engineering Research' then 105 end, null, null, now(), now(), 2384850, 2384850,
                      false, null,
                      null, null, 1)
              returning id into v_project_process_step_event_design_id;

              --  perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28740, z.project_designer_c, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28428, z.revision_of_c::text,true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28429, z.lov7_reason_level_1_c_id::text,true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28430, z.lov8_reason_level_2_c_id::text,true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28739, z.lov1_mppp_revision_needed_c_id::text, true);
              -- perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28427, z., true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28741,z.lov2_nh_urgent_request_type_c_id::text, true);
              --perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28742, z.ownr, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28743,z.lov3_incoming_request_had_all_information_c_id::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28744,z.missing_information_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28745,z.date_design_must_be_completed_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28746,z.date_design_request_verified_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28747,z.estimated_completion_date_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28748,z.design_start_date_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28749,z.date_completed_design_reviewed_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28750,z.design_completed_date_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28751,z.actual_time_hours_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28752,z.reason_for_late_delivery_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28753,z.for_eor_review_date_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28754,z.for_eor_rejection_date_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28755,z.design_approved_c::text,true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28756,z.date_design_signed_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28757,z.date_design_shipped_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28758,z.applied_for_permit_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28759,z.permit_award_actual_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28760,z.shared_with_builder_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28761,z.design_work_located_in_c::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28762,z.number_of_sets_c::text,true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28763,z.lov4_pdf_copy_only_c_id::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28764,z.lov5_electrical_pe_signature_c_id::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28765,z.lov6_structural_pe_signature_c_id::text, true);
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28766,z.delivery_tracking_number_c::text, true);
              v_deliver_to_c_id = null;
              if z.deliver_to_c is not null then
                select array_agg(lov.id)
                into v_deliver_to_c_id
                from (SELECT unnest(string_to_array(aggregated_column, ';')) deliver_to_c
                      FROM (SELECT STRING_AGG(deliver_to_c, ';') AS aggregated_column
                            from brs.design_c d
                            where id = z.id) AS subquery) as foo
                       inner join flow.list_of_value lov on lov.name = foo.deliver_to_c and lov.parent_id = 25647;
                perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28767, v_deliver_to_c_id::text,
                                               true);
              end if;
              perform flow.set_pps_event_cfv(v_project_process_step_event_design_id, 2384850, 28768,z.notes_from_requester_c::text, true);
            end loop;

--           for w in select  distinct on (apc.role_c) apc.role_c,apc.partner_account_c
--                    from brs.alliance_partner_c apc
--                    where apc.COMMUNITY_C is not null and apc.IS_DELETED = false
--                      and apc.RECORD_TYPE_ID = '01234000000UQPYAA4'
--                      and apc.community_c = x.community_id
--                   order by apc.role_c ,apc.created_date desc
--           loop
--             case when w.role_c = 'Builder' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28877,w.partner_account_c::text, true);
--                  when w.role_c = 'Builder HERS Rater' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28878,w.partner_account_c::text, true);
--                  when w.role_c = 'Commissioning Partner' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28879,w.partner_account_c::text, true);
--                  when w.role_c = 'Customer Service Partner' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28880,w.partner_account_c::text, true);
--                  when w.role_c = 'Dealer' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28881,w.partner_account_c::text, true);
--                  when w.role_c = 'Design Partner' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28882,w.partner_account_c::text, true);
--                  when w.role_c = 'DRIP' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28883,w.partner_account_c::text, true);
--                  when w.role_c = 'EV Electrician' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28884,w.partner_account_c::text, true);
--                  when w.role_c = 'Field Service Representative' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28886,w.partner_account_c::text, true);
--                  when w.role_c = 'Inspection Partner' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28887,w.partner_account_c::text, true);
--                  when w.role_c = 'IP' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28888,w.partner_account_c::text, true);
--                  when w.role_c = 'MPU Electrician' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28889,w.partner_account_c::text, true);
--                  when w.role_c = 'Permitting Partner' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28890,w.partner_account_c::text, true);
--                  when w.role_c = 'PV HERS Provider' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28891,w.partner_account_c::text, true);
--                  when w.role_c = 'Roofer' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28892,w.partner_account_c::text, true);
--                  when w.role_c = 'Storage IP' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28893,w.partner_account_c::text, true);
--                  when w.role_c = 'T24 Energy Consultant' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28894,w.partner_account_c::text, true);
--                  when w.role_c = 'TPS' then
--                    perform flow.set_project_cfv(x.project_id , 2384850,28895,w.partner_account_c::text, true);
--             end case;
--           end loop;
      end loop;

  end
$do$;


DO
$do$
  declare
    x record;
    w record;
    t record;
  v_object_category_id bigint;
  v_contact_id bigint;
  v_project_id bigint;
  v_object_category_project_id bigint;
  v_system_adders_c bigint[];
  v_count bigint;
  BEGIN
    v_count = 0;
    select oc.id
    into v_object_category_project_id
    from flow.object_category oc
    where object_category_code = 'NEW_HOME';
    for x in select a2.homeowner_preferred_name_c,a2.id as homeowner_id,
                    a2.billing_street,
                    a2.billing_city,
                    a2.billing_postal_code,
                    a2.phone,
                    a2.email_c,
                    a2.name as account_name,
                    a.homeowner_preferred_name_c as builder_homeowner_preferred_name_c,
                    a.billing_street as builder_billing_street,
                    a.billing_city as builder_billing_city,
                    a.billing_postal_code as builder_billing_postal_code,
                    a.phone as builder_phone,
                    a.email_c as builder_email_c,
                    cs.id as company_state_id,
                    rpc.record_type_id,
                    rpc.project_number_c,
                    rpc.lot_number_c,
                    rpc.elevation_c,
                    rpc.enhancements_c,
                    rpc.structural_option_c,
                    rpc.pto_date_c,
                    rpc.ntp_date_c,
                    rpc.esd_date_c,
                    rpc.sales_order_complete_date_c,
                    rpc.phase_c,
                    rpc.closed_won_date_nh_c,
                    rpc.est_escrow_date_c,
                    rpc.lines_ready_to_submit_c,
                    rpc.sales_order_number_c,
                    rpc.escrow_date_ho_c,
                    rpc.auto_booked_c,
                    rpc.ho_provided_escrow_response_c,
                    rpc.historical_sales_order_number_c,
                    rpc.scheduled_installation_date_c,
                    rpc.oracle_order_header_id_c,
                    rpc.first_scheduled_installation_date_c,
                    rpc.amendment_reconciled_c,
                    rpc.unblock_quote_amendment_c,
                    rpc.solar_access_c,
                    rpc.scheduled_ahj_inspection_c,
                    rpc.milestone_c,
                    rpc.rev_rec_date_c,
                    rpc.misc_notes_c,
                    rpc.forecasted_unblock_date_c,
                    rpc.hoa_submission_date_c,
                    rpc.escrow_date_c,
                    rpc.number_of_panels_c,
                    rpc.inverter_quantity_c,
                    rpc.system_wattage_ac_c,
                    rpc.system_wattage_dc_c,
                    rpc.requested_delivery_date_c,
                    rpc.scheduled_arrival_date_c,
                    rpc.material_shipped_date_c,
                    rpc.material_delivery_date_c,
                    rpc.storage_system_c,
                    rpc.roof_1_system_orientation_c,
                    rpc.design_required_c,
                    rpc.roof_1_no_of_modules_c,
                    rpc.actual_time_hours_c,
                    rpc.roof_2_system_orientation_c,
                    rpc.roof_2_no_of_modules_c,
                    rpc.total_number_of_sets_proj_c,
                    rpc.roof_3_system_orientation_c,
                    rpc.number_of_split_arrays_c,
                    rpc.roof_3_no_of_modules_c,
                    rpc.design_notes_c,
                    rpc.roof_4_system_orientation_c,
                    rpc.permit_execution_fees_c,
                    rpc.roof_4_no_of_modules_c,
                    rpc.permit_eta_c,
                    rpc.previous_permit_eta_c,
                    rpc.sun_power_permit_override_c,
                    rpc.builder_wo_c,
                    rpc.builder_wo_date_of_receipt_c,
                    rpc.storage_size_discrepancy_c,
                    rpc.wo_price_c,
                    rpc.wo_system_size_w_c,
                    rpc.storage_price_discrepancy_c,
                    rpc.wo_storage_price_c,
                    rpc.module_count_discrepancy_c,
                    rpc.builder_wo_value_c,
                    rpc.builder_wo_value_c,
                    rpc.additional_builder_services_wo_c,
                    rpc.wrap_insurance_amount_c,
                    rpc.addtl_builder_services_wodateof_receipt_c,
                    rpc.total_sovalue_c,
                    rpc.additional_builder_services_wo_value_c,
                    rpc.further_discount_amount_c,
                    rpc.builder_incentive_value_c,
                    rpc.further_discount_rationale_c,
                    rpc.model_discount_percent_c,
                    rpc.model_discount_amount_c,
                    rpc.sunvault_model_discount_c,
                    rpc.sunvault_model_discount_amount_c,
                    rpc.trim_labor_pricing_c,
                    rpc.pv_trim_po_c,
                    rpc.rough_wire_wo_c,
                    rpc.trench_date_promised_c,
                    rpc.rough_wire_wo_date_receipt_c,
                    rpc.trench_started_c,
                    rpc.rough_wire_wo_value_c,
                    rpc.trench_date_c,
                    rpc.rough_labor_pricing_c,
                    rpc.pv_rough_po_c,
                    rpc.rough_wire_promised_c,
                    rpc.roofer_labor_pricing_c,
                    rpc.pv_install_promised_c,
                    rpc.roofer_inset_po_c,
                    rpc.trim_promised_c,
                    rpc.ready_for_rough_wire_checkbox_c,
                    rpc.ready_for_install_checkbox_c,
                    rpc.ready_for_rough_wire_c,
                    rpc.ready_for_install_c,
                    rpc.roughwire_complete_c,
                    rpc.pv_install_complete_c,
                    rpc.pv_install_completed_c,
                    rpc.rough_wire_completed_c,
                    rpc.rough_wire_pull_date_c,
                    rpc.trim_install_complete_c,
                    rpc.pre_coe_commissioning_pricing_c,
                    rpc.trim_install_completed_c,
                    rpc.trim_install_pull_date_c,
                    rpc.install_complete_c,
                    rpc.install_completed_c,
                    rpc.pre_coe_comm_notes_c,
                    rpc.install_pull_date_c,
                    rpc.utility_meter_confirmation_date_c,
                    rpc.inspection_price_c,
                    rpc.serial_number_c,
                    rpc.permit_cost_actual_c,
                    rpc.wi_fi_connected_c,
                    rpc.adders_value_c,
                    rpc.follow_up_date_c,
                    rpc.commitment_date_c,
                    rpc.storage_rough_po_c,
                    rpc.site_id_c,
                    rpc.storage_trim_po_c,
                    rpc.storage_rough_wire_promised_c,
                    rpc.storage_install_promised_c,
                    rpc.storage_rough_complete_c,
                    rpc.storage_rough_complete_date_c,
                    rpc.storage_rough_complete_pull_date_c,
                    rpc.storage_install_complete_c,
                    rpc.storage_install_complete_date_c,
                    rpc.storage_install_complete_pull_date_c,
                    rpc.rebate_reservation_expiry_date_lot_c,
                    rpc.hers_inspection_notes_c,
                    rpc.solar_rebate_actual_c,
                    rpc.pv_id_c,
                    rpc.solar_rebate_expected_c,
                    rpc.rebate_reservation_confirmation_lot_c,
                    rpc.rebate_claim_notes_c,
                    rpc.cf_2_r_c,
                    rpc.energy_efficiency_code_c,
                    rpc.rebate_claim_submitted_c,
                    rpc.hers_inspection_completed_c,
                    rpc.rebate_claim_approved_c,
                    rpc.utility_application_id_c,
                    rpc.t_24_notes_c,
                    rpc.utility_account_number_c,
                    rpc.utility_meter_number_c,
                    rpc.hers_certificate_received_c,
                    rpc.interconnection_notes_c,
                    rpc.rebate_claim_expiry_date_c,
                    rpc.gate_code_c,
                    rpc.roof_material_c,
                    rpc.hoa_name_c,
                    rpc.hoa_contact_phone_email_c,
                    rpc.age_of_roof_c,
                    rpc.intake_notes_c,
                    rpc.age_of_home_c,
                    rpc.storage_install_completed_by_c,
                   -- rpc.storage_rough_completed_c,
                    rpc.install_completed_by_c,
                    rpc.trim_install_completed_by_c,
                    rpc.pv_install_completed_by_c,
                    rpc.rough_wire_completed_by_c,
                    rpc.trench_completed_by_c,
                    rpc.activation_coordinator_c,
                    c2.id as builder_contact_id,
                    p.id as community_project_id,
                    lov1.id as  lov1_priority_c,
                    lov2.id as  lov2_cancellation_justification_c,
                    lov3.id as  lov3_sun_power_deal_type_c,
                    lov4.id as  lov4_sun_vault_deal_type_c,
                    lov5.id as  lov5_rescheduled_reason_code_c,
                    lov6.id as  lov6_rp_fields_and_builder_files_validated_c,
                    lov7.id as  lov7_block_reason_c,
                    lov8.id as  lov8_monitoring_c,
                    lov9.id as  lov9_roof_attachment_c,
                    lov10.id as lov10_smart_thermostat_c,
                    lov11.id as lov11_thermostat_manufacturer_c,
                    lov12.id as lov12_thermostat_model_c,
                    lov13.id as lov13_installation_type_c,
                    lov14.id as lov14_roof_type_c,
                    lov15.id as lov15_type_of_design_c,
                    lov16.id as lov16_roof_1_pitch_c,
                    lov17.id as lov17_proposed_solar_breaker_installed_in_msp_c,
                    lov18.id as lov18_pdf_copy_only_c,
                    lov19.id as lov19_roof_2_pitch_c,
                    lov20.id as lov20_roof_3_pitch_c,
                    lov21.id as lov21_roof_4_pitch_c,
                    lov22.id as lov22_further_discount_status_c,
                    lov23.id as lov23_microinverter_status_c,
                    lov24.id as lov24_pre_coe_comm_failure_reason_c,
                    lov25.id as lov25_utility_meter_installed_c,
                    lov26.id as lov26_system_activation_status_c,
                    lov27.id as lov27_rse_outcome_c,
                    lov28.id as lov28_pv_hers_certification_type_c,
                    lov29.id as lov29_nem_applicability_c,
                    lov30.id as lov30_internet_access_c,
                    lov31.id as lov31_preferred_communication_c,
                    lov32.id as lov32_tree_trim_c,
                    lov33.id as lov33_attic_crawl_space_c,
                    lov34.id as lov34_dog_on_site_c,
                    lov35.id as lov35_customer_construction_project_c,
                    lov36.id as lov36_complexity_indicator_c,
                    rpc.status_c,
                    rpc.name,
                    rpc.system_adders_c,
                    rpc.id
             from brs.NH_COMMUNITY_C c
                    inner join flow.project p on p.nw_migration_id = c.id
                    inner join brs.account a on a.id = c.builder_c
                    inner join flow.contact c2 on c2.nw_migration_id = a.id
                    inner join brs.residential_project_c rpc on rpc.community_c = c.id
                    left join brs.account a2 on a2.id = rpc.account_c and a2.type in ('Home Owner – SSE','Home Owner','Homeowner')
                    left join flow.state s on s.abbreviation = a2.billing_state
                    left join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
                    left join flow.list_of_value lov1 on lov1.name =   rpc.priority_c and lov1.parent_id =25516
                    left join flow.list_of_value lov2 on lov2.name =   rpc.cancellation_justification_c and lov2.parent_id =25520
                    left join flow.list_of_value lov3 on lov3.name =   rpc.sun_power_deal_type_c and lov3.parent_id =25524
                    left join flow.list_of_value lov4 on lov4.name =   rpc.sun_vault_deal_type_c and lov4.parent_id =25528
                    left join flow.list_of_value lov5 on lov5.name =   rpc.rescheduled_reason_code_c and lov5.parent_id =25544
                    left join flow.list_of_value lov6 on lov6.name =   rpc.rp_fields_and_builder_files_validated_c and lov6.parent_id =25542
                    left join flow.list_of_value lov7 on lov7.name =   rpc.block_reason_c and lov7.parent_id =25540
                    left join flow.list_of_value lov8 on lov8.name =   rpc.monitoring_c and lov8.parent_id =25538
                    left join flow.list_of_value lov9 on lov9.name =   rpc.roof_attachment_c and lov9.parent_id =25538
                    left join flow.list_of_value lov10 on lov10.name = rpc.smart_thermostat_c and lov10.parent_id =25532
                    left join flow.list_of_value lov11 on lov11.name = rpc.thermostat_manufacturer_c and lov11.parent_id =25522
                    left join flow.list_of_value lov12 on lov12.name = rpc.thermostat_model_c and lov12.parent_id =25518
                    left join flow.list_of_value lov13 on lov13.name = rpc.installation_type_c and lov13.parent_id =25514
                    left join flow.list_of_value lov14 on lov14.name = rpc.roof_type_c and lov14.parent_id =25512
                    left join flow.list_of_value lov15 on lov15.name = rpc.type_of_design_c and lov15.parent_id =25510
                    left join flow.list_of_value lov16 on lov16.name = rpc.roof_1_pitch_c and lov16.parent_id =25508
                    left join flow.list_of_value lov17 on lov17.name = rpc.proposed_solar_breaker_installed_in_msp_c and lov17.parent_id =25506
                    left join flow.list_of_value lov18 on lov18.name = rpc.pdf_copy_only_c and lov18.parent_id =25504
                    left join flow.list_of_value lov19 on lov19.name = rpc.roof_2_pitch_c and lov19.parent_id =25502
                    left join flow.list_of_value lov20 on lov20.name = rpc.roof_3_pitch_c and lov20.parent_id =25430
                    left join flow.list_of_value lov21 on lov21.name = rpc.roof_4_pitch_c and lov21.parent_id =25436
                    left join flow.list_of_value lov22 on lov22.name = rpc.further_discount_status_c and lov22.parent_id =25485
                    left join flow.list_of_value lov23 on lov23.name = rpc.microinverter_status_c and lov23.parent_id =25500
                    left join flow.list_of_value lov24 on lov24.name = rpc.pre_coe_comm_failure_reason_c and lov24.parent_id =25487
                    left join flow.list_of_value lov25 on lov25.name = rpc.utility_meter_installed_c and lov25.parent_id =25482
                    left join flow.list_of_value lov26 on lov26.name = rpc.system_activation_status_c and lov26.parent_id =25444
                    left join flow.list_of_value lov27 on lov27.name = rpc.rse_outcome_c and lov27.parent_id =25438
                    left join flow.list_of_value lov28 on lov28.name = rpc.pv_hers_certification_type_c and lov28.parent_id =25432
                    left join flow.list_of_value lov29 on lov29.name = rpc.nem_applicability_c and lov29.parent_id =25427
                    left join flow.list_of_value lov30 on lov30.name = rpc.internet_access_c and lov30.parent_id =25425
                    left join flow.list_of_value lov31 on lov31.name = rpc.preferred_communication_c and lov31.parent_id =25423
                    left join flow.list_of_value lov32 on lov32.name = rpc.tree_trim_c and lov32.parent_id =25421
                    left join flow.list_of_value lov33 on lov33.name = rpc.attic_crawl_space_c and lov33.parent_id =25419
                    left join flow.list_of_value lov34 on lov34.name = rpc.dog_on_site_c and lov34.parent_id =25417
                    left join flow.list_of_value lov35 on lov35.name = rpc.customer_construction_project_c and lov35.parent_id =25415
                    left join flow.list_of_value lov36 on lov36.name = rpc.complexity_indicator_c and lov36.parent_id =25413

      loop
        v_count = v_count + 1;
        if v_count = 1000 then
          raise notice 'v_count = %',v_count;
          v_count = 0;
        end if;
        v_contact_id = null;
        v_object_category_id = null;
      if x.homeowner_id is not null then
        select oc.id
        into v_object_category_id
        from flow.object_category oc
        where object_category_code = 'NEW_HOMEOWNER';
        insert into flow.contact(contact_type_id, first_name, last_name, street1, street2, city, postal_code,
                                 phone, email, mobile, date_created, date_modified,
                                 created_by_id, modified_by_id, company_id, archived,
                                 company_state_id,
                                 company_country_id, nw_migration_id, object_category_id)
        values (1, x.account_name, null, x.billing_street, null, x.billing_city, substr(x.billing_postal_code,1,10), x.phone, x.email_c,
                x.phone, now(), now(), 2384850, 2384850, 3, false,
                x.company_state_id, 1, x.homeowner_id,v_object_category_id) returning id into v_contact_id;
      else
        v_contact_id = x.builder_contact_id;
      end if;
        insert into flow.project(contact_id, company_process_id, project_name, date_created, date_modified,
                                 created_by_id, modified_by_id, company_project_status_type_id,
                                street1, street2, city, postal_code,
                                company_state_id, company_country_id,
                                 archived, cancelled_date, nw_migration_id,object_category_id,parent_id)
      values(v_contact_id,27,x.name,now(),now(),2384850,2384850,
             case when x.status_c is null then 223
                  when x.status_c = 'Hold' then 224
                  when x.status_c = 'On Hold' then 224
                  when x.status_c = 'Active' then 223
                  when x.status_c = 'At Risk' then 230
                  when x.status_c = 'Pending Cancellation' then 229
                  when x.status_c = 'Cancelled' then 225
                  when x.status_c = 'Completed' then 228 end,
             coalesce(x.billing_street,x.builder_billing_street),null,coalesce(x.billing_city,x.builder_billing_city),
             coalesce(substr(x.billing_postal_code,1,10),substr(x.builder_billing_postal_code,1,10)),x.company_state_id,1,false,null,x.id,
             v_object_category_project_id,x.community_project_id
             ) returning id into v_project_id;

        perform flow.set_project_cfv(v_project_id , 2384850,28122,x.record_type_id::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28675,x.project_number_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28127,x.lot_number_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28128,x.elevation_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28129,x.enhancements_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28130,x.structural_option_c::text, true);
       -- perform flow.set_project_cfv(v_project_id , 2384850,28131,x.activation_coordinator_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28132,x.pto_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28133,x.ntp_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28134,x.esd_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28135,x.sales_order_complete_date_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28136,x.phase_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28138,x.closed_won_date_nh_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28139,x.est_escrow_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28141,x.lines_ready_to_submit_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28142,x.sales_order_number_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28144,x.escrow_date_ho_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28146,x.auto_booked_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28148,x.ho_provided_escrow_response_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28149,x.historical_sales_order_number_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28151,x.scheduled_installation_date_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28169,x.oracle_order_header_id_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28153,x.first_scheduled_installation_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28159,x.amendment_reconciled_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28161,x.unblock_quote_amendment_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28174,x.solar_access_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28176,x.scheduled_ahj_inspection_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28185,x.milestone_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28186,x.rev_rec_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28188,x.misc_notes_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28191,x.forecasted_unblock_date_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28192,x.hoa_submission_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28835,x.escrow_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28194,x.number_of_panels_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28196,x.inverter_quantity_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28197,x.system_wattage_ac_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28200,x.system_wattage_dc_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28206,x.requested_delivery_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28209,x.scheduled_arrival_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28211,x.material_shipped_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28243,x.material_delivery_date_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28244,x.storage_system_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28252,x.roof_1_system_orientation_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28253,x.design_required_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28255,x.roof_1_no_of_modules_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28257,x.actual_time_hours_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28260,x.roof_2_system_orientation_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28263,x.roof_2_no_of_modules_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28265,x.total_number_of_sets_proj_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28267,x.roof_3_system_orientation_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28268,x.number_of_split_arrays_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28269,x.roof_3_no_of_modules_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28270,x.design_notes_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28272,x.roof_4_system_orientation_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28273,x.permit_execution_fees_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28274,x.roof_4_no_of_modules_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28275,x.permit_eta_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28277,x.previous_permit_eta_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28278,x.sun_power_permit_override_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28279,x.builder_wo_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28280,x.builder_wo_date_of_receipt_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28281,x.storage_size_discrepancy_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28282,x.wo_price_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28283,x.wo_system_size_w_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28284,x.storage_price_discrepancy_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28285,x.wo_storage_price_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28286,x.module_count_discrepancy_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28287,x.builder_wo_value_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28288,x.builder_wo_value_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28289,x.additional_builder_services_wo_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28291,x.wrap_insurance_amount_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28292,x.addtl_builder_services_wodateof_receipt_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28293,x.total_sovalue_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28294,x.additional_builder_services_wo_value_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28295,x.further_discount_amount_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28296,x.builder_incentive_value_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28297,x.further_discount_rationale_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28298,x.model_discount_percent_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28301,x.model_discount_amount_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28303,x.sunvault_model_discount_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28304,x.sunvault_model_discount_amount_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28213,x.trim_labor_pricing_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28215,x.pv_trim_po_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28216,x.rough_wire_wo_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28217,x.trench_date_promised_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28219,x.rough_wire_wo_date_receipt_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28222,x.trench_started_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28225,x.rough_wire_wo_value_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28227,x.trench_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28230,x.rough_labor_pricing_c::text, true);
        --perform flow.set_project_cfv(v_project_id , 2384850,28232,x.trench_completed_by_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28235,x.pv_rough_po_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28238,x.rough_wire_promised_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28240,x.roofer_labor_pricing_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28241,x.pv_install_promised_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28242,x.roofer_inset_po_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28246,x.trim_promised_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28248,x.ready_for_rough_wire_checkbox_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28251,x.ready_for_install_checkbox_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28254,x.ready_for_rough_wire_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28256,x.ready_for_install_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28290,x.roughwire_complete_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28266,x.pv_install_complete_c::text, true);
       -- perform flow.set_project_cfv(v_project_id , 2384850,28299,x.rough_wire_completed_by_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28302,x.pv_install_completed_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28261,x.rough_wire_completed_c::text, true);
        --perform flow.set_project_cfv(v_project_id , 2384850,28306,x.pv_install_completed_by_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28307,x.rough_wire_pull_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28308,x.trim_install_complete_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28309,x.pre_coe_commissioning_pricing_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28310,x.trim_install_completed_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28312,x.trim_install_pull_date_c::text, true);
       -- perform flow.set_project_cfv(v_project_id , 2384850,28314,x.trim_install_completed_by_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28316,x.install_complete_c::text, true);
       -- perform flow.set_project_cfv(v_project_id , 2384850,28318,x.install_completed_by_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28320,x.install_completed_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28321,x.pre_coe_comm_notes_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28322,x.install_pull_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28323,x.utility_meter_confirmation_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28324,x.inspection_price_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28325,x.serial_number_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28326,x.permit_cost_actual_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28329,x.wi_fi_connected_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28330,x.adders_value_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28333,x.follow_up_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28335,x.commitment_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28336,x.storage_rough_po_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28337,x.site_id_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28339,x.storage_trim_po_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28340,x.storage_rough_wire_promised_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28341,x.storage_install_promised_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28342,x.storage_rough_complete_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28343,x.storage_rough_complete_date_c::text, true);
      --  perform flow.set_project_cfv(v_project_id , 2384850,28344,x.storage_rough_completed_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28345,x.storage_rough_complete_pull_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28346,x.storage_install_complete_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28347,x.storage_install_complete_date_c::text, true);
       -- perform flow.set_project_cfv(v_project_id , 2384850,28348,x.storage_install_completed_by_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28349,x.storage_install_complete_pull_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28165,x.rebate_reservation_expiry_date_lot_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28166,x.hers_inspection_notes_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28167,x.solar_rebate_actual_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28168,x.pv_id_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28170,x.solar_rebate_expected_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28171,x.rebate_reservation_confirmation_lot_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28173,x.rebate_claim_notes_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28175,x.cf_2_r_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28178,x.energy_efficiency_code_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28180,x.rebate_claim_submitted_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28181,x.hers_inspection_completed_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28184,x.rebate_claim_approved_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28187,x.utility_application_id_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28190,x.t_24_notes_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28193,x.utility_account_number_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28195,x.utility_meter_number_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28201,x.hers_certificate_received_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28204,x.interconnection_notes_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28208,x.rebate_claim_expiry_date_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28137,x.gate_code_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28147,x.roof_material_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28150,x.hoa_name_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28734,x.hoa_contact_phone_email_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28156,x.age_of_roof_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28158,x.intake_notes_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28160,x.age_of_home_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28123,x.lov1_priority_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28124,x.lov2_cancellation_justification_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28125,x.lov3_sun_power_deal_type_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28126,x.lov4_sun_vault_deal_type_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28164,x.lov5_rescheduled_reason_code_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28177,x.lov6_rp_fields_and_builder_files_validated_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,29189,x.lov7_block_reason_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28199,x.lov8_monitoring_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28203,x.lov9_roof_attachment_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28205,x.lov10_smart_thermostat_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28207,x.lov11_thermostat_manufacturer_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28210,x.lov12_thermostat_model_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28212,x.lov13_installation_type_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28249,x.lov14_roof_type_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28250,x.lov15_type_of_design_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28258,x.lov16_roof_1_pitch_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28259,x.lov17_proposed_solar_breaker_installed_in_msp_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28262,x.lov18_pdf_copy_only_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28264,x.lov19_roof_2_pitch_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28271,x.lov20_roof_3_pitch_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28276,x.lov21_roof_4_pitch_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28300,x.lov22_further_discount_status_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28311,x.lov23_microinverter_status_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28317,x.lov24_pre_coe_comm_failure_reason_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28319,x.lov25_utility_meter_installed_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28327,x.lov26_system_activation_status_c::text , true);
        perform flow.set_project_cfv(v_project_id , 2384850,28331,x.lov27_rse_outcome_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28179,x.lov28_pv_hers_certification_type_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28198,x.lov29_nem_applicability_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28140,x.lov30_internet_access_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28143,x.lov31_preferred_communication_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28145,x.lov32_tree_trim_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28733,x.lov33_attic_crawl_space_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28152,x.lov34_dog_on_site_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28154,x.lov35_customer_construction_project_c::text, true);
        perform flow.set_project_cfv(v_project_id , 2384850,28162,x.lov36_complexity_indicator_c::text , true);
        v_system_adders_c = null;
        if x.system_adders_c is not null then
          select array_agg(lov.id)
          into v_system_adders_c
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) system_adders_c
                 FROM (
                        SELECT STRING_AGG(system_adders_c, ';') AS aggregated_column
                        from brs.residential_project_c r
                        where r.id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.system_adders_c and lov.parent_id = 25442;
          perform flow.set_project_cfv(v_project_id , 2384850,28328,v_system_adders_c::text, true);
        end if;

--         for t in select  distinct on (apc.role_c) apc.role_c,apc.partner_account_c
--                  from brs.alliance_partner_c apc
--                  where apc.COMMUNITY_C is not null and apc.IS_DELETED = false
--                    and apc.RECORD_TYPE_ID = '01234000000UQPXAA4'
--                    and apc.community_c = x.id
--                  order by apc.created_date desc
--           loop
--             case when t.role_c = 'Builder' then
--               perform flow.set_project_cfv(x.community_project_id , 2384850,28877,t.partner_account_c::text, true);
--                  when t.role_c = 'Builder HERS Rater' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28878,t.partner_account_c::text, true);
--                  when t.role_c = 'Commissioning Partner' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28879,t.partner_account_c::text, true);
--                  when t.role_c = 'Customer Service Partner' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28880,t.partner_account_c::text, true);
--                  when t.role_c = 'Dealer' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28881,t.partner_account_c::text, true);
--                  when t.role_c = 'Design Partner' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28882,t.partner_account_c::text, true);
--                  when t.role_c = 'DRIP' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28883,t.partner_account_c::text, true);
--                  when t.role_c = 'EV Electrician' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28884,t.partner_account_c::text, true);
--                  when t.role_c = 'Field Service Representative' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28886,t.partner_account_c::text, true);
--                  when t.role_c = 'Inspection Partner' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28887,t.partner_account_c::text, true);
--                  when t.role_c = 'IP' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28888,t.partner_account_c::text, true);
--                  when t.role_c = 'MPU Electrician' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28889,t.partner_account_c::text, true);
--                  when t.role_c = 'Permitting Partner' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28890,t.partner_account_c::text, true);
--                  when t.role_c = 'PV HERS Provider' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28891,t.partner_account_c::text, true);
--                  when t.role_c = 'Roofer' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28892,t.partner_account_c::text, true);
--                  when t.role_c = 'Storage IP' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28893,t.partner_account_c::text, true);
--                  when t.role_c = 'T24 Energy Consultant' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28894,t.partner_account_c::text, true);
--                  when t.role_c = 'TPS' then
--                    perform flow.set_project_cfv(x.community_project_id , 2384850,28895,t.partner_account_c::text, true);
--               end case;
--           end loop;
      end loop;
  end
$do$;


DO
$do$
  declare
    w record;
v_count bigint;
    v_total bigint;
  v_project_process_step_id bigint;
  BEGIN
    v_count = 0;
    v_total = 0;
    for w in
           select
               distinct on (ptc.residential_project_c)
               ptc.description_c,
               ptc.project_priority_c,
               ptc.comment_c,
               ptc.assigned_to_c,
               ptc.ip_owner_c,
               ptc.role_assignment_c,
               ptc.blocks_c,
               ptc.start_date_time_c,
               ptc.first_complete_end_date_time_c,
               ptc.end_date_time_c,
               ptc.completed_by_c,
               ptc.name,
               lov1.id as lov1_project_priority_c_id,
               lov2.id as lov2_role_assignment_c_id,
               lov3.id as lov3_blocks_c_id,
               p.id as community_project_id,
               ptc.id as project_task_id
             from brs.PROJECT_TASK_C ptc
            inner join flow.project p on p.nw_migration_id = ptc.residential_project_c
             left join flow.list_of_value lov1 on lov1.name = ptc.project_priority_c and  lov1.parent_id = 25516
             left join flow.list_of_value lov2 on lov2.name = ptc.role_assignment_c and lov2.parent_id = 25733
             left join flow.list_of_value lov3 on lov3.name = ptc.blocks_c and lov3.parent_id = 25741
      where
            ptc.status_c != 'Not Started' and
            ptc.record_type_id = '01234000000BmbOAAS' and
            ptc.is_deleted = false and
            upper(ptc.path_type_c) = 'STANDARD'
      order by residential_project_c,ptc.created_date desc
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        v_project_process_step_id = null;
        if v_count = 1000 then
          raise notice 'v_count %',v_count;
          raise notice 'v_total %',v_total;
          v_count = 0;
        end if;
        case
          when w.name = 'Input Promise Dates' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3759, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
            returning id into v_project_process_step_id;

            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29025, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29026, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29027, w.comment_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29028, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29029, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29030, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29031, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29050, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29051, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29052, w.end_date_time_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 29053, w.completed_by_c::text, true);

            perform brs.create_event_sub_tasks(w.project_task_id, 3759, v_project_process_step_id);
          when w.name = 'Obtain Builder Plot Plan' then

            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3760, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29065, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29066, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29067, w.comment_c::text, true);
        --    perform flow.set_pps_cfv(w.community_project_id, 2384850, 29068, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29069, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29070, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29071, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29072, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29073, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29074, w.end_date_time_c::text, true);
            --perform flow.set_pps_cfv(w.community_project_id, 2384850, 29075, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3760, v_project_process_step_id);

          when w.name = 'Complete Design Package' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3761, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28977, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28978, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28979, w.comment_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 28980, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28981, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28982, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28983, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28984, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28985, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28986, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 28987, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3761, v_project_process_step_id);
          when w.name = 'Provide Stamping' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3762, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28977, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28978, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28979, w.comment_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 28980, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28981, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28982, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28983, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28984, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28985, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28986, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 28987, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3762, v_project_process_step_id);
          when w.name = 'Complete BOM' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3763, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28955, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28956, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28957, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 28958, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28959, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28960, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28961, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28962, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28963, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28964, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 28965, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3763, v_project_process_step_id);
          when w.name = 'Preliminary IC Submission w/Utility' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3764, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29076, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29077, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29078, w.comment_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 29079, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29080, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29081, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29082, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29083, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29084, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29085, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29086, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3764, v_project_process_step_id);
          when w.name = 'Upload Design' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3765, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29087, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29088, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29089, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29090, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29091, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29092, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29093, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29094, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29095, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29096, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29097, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3765, v_project_process_step_id);
          when w.name = 'Apply for Permit' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3766, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28932, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28933, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28935, w.comment_c::text, true);
            --perform flow.set_pps_cfv(w.community_project_id, 2384850, 28936, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28937, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28938, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28939, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28940, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28941, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28942, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 28943, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3766, v_project_process_step_id);
          when w.name = 'Designs Distributed' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3767, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29018, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29019, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29020, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29021, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29022, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29023, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29024, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29046, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29047, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29048, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29049, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3767, v_project_process_step_id);
          when w.name = 'Permit Pickup' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3768, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29098, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29099, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29100, w.comment_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 29101, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29102, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29103, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29104, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29105, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29106, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29107, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29108, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3768, v_project_process_step_id);
          when w.name = 'Complete Rough Wire' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3769, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28988, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28989, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28990, w.comment_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 28991, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28992, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28993, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28994, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28995, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28996, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29032, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29033, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3769, v_project_process_step_id);
          when w.name = 'Complete Storage Rough' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3770, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28997, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28998, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28999, w.comment_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 29000, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29001, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29002, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29003, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29034, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29035, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29036, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29037, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3770, v_project_process_step_id);
          when w.name = 'Obtain Builder WO' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3771, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29109, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29110, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29111, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29112, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29113, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29114, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29115, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29116, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29117, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29118, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29119, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3771, v_project_process_step_id);
          when w.name = 'Create Material Lines & PO/SO' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3772, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29004, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29005, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29006, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29007, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29008, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29009, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29010, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29038, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29039, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29040, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29041, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3772, v_project_process_step_id);
          when w.name = 'Preliminary IC Approval' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3773, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29120, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29121, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29122, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29123, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29124, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29125, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29126, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29127, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29128, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29129, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29130, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3773, v_project_process_step_id);
          when w.name = 'Complete CF-2R in Registry' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3774, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28966, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28967, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28968, w.comment_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 28969, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28970, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28971, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28972, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28973, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28974, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28975, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 28976, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3774, v_project_process_step_id);
          when w.name = 'System Installation' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3775, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29131, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29132, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29133, w.comment_c::text, true);
        --    perform flow.set_pps_cfv(w.community_project_id, 2384850, 29134, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29135, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29136, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29137, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29138, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29139, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29140, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29141, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3775, v_project_process_step_id);
          when w.name = 'Installation Checklist Uploaded' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3776, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29054, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29055, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29056, w.comment_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29057, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29058, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29059, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29060, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29061, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29062, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29063, w.end_date_time_c::text, true);
        --    perform flow.set_pps_cfv(w.community_project_id, 2384850, 29064, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3776, v_project_process_step_id);
          when w.name = 'Storage Installation' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3777, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29142, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29143, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29144, w.comment_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29145, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29146, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29147, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29148, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29149, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29150, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29151, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29152, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3777, v_project_process_step_id);
          when w.name = 'Storage Checklist Completed' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3778, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29153, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29154, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29155, w.comment_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 29156, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29157, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29158, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29159, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29160, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29161, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29162, w.end_date_time_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29163, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3778, v_project_process_step_id);
          when w.name = 'Affirm AHJ Inspection Complete' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3779, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28910, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28911, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28912, w.comment_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 28913, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28914, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28915, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28916, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28917, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28918, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28919, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 28920, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3779, v_project_process_step_id);
          when w.name = 'AHJ Storage Inspection' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3780, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28921, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28922, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28923, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 28924, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28925, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28926, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28927, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28928, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28929, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28930, w.end_date_time_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 28931, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3780, v_project_process_step_id);
          when w.name = 'Closure of RevRec' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3781, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28944, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28945, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28946, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 28947, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28948, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28949, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28950, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28951, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28952, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 28953, w.end_date_time_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 28954, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3781, v_project_process_step_id);
          when w.name = 'Upload Final Building Permit' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3782, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29164, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29165, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29166, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29167, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29168, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29169, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29170, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29171, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29172, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29173, w.end_date_time_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 29174, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3782, v_project_process_step_id);
          when w.name = 'Invoice Packet Complete and Sent' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3783, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29175, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29176, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29177, w.comment_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29178, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29179, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29180, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29181, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29182, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29183, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29184, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29185, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3783, v_project_process_step_id);
          when w.name = 'Obtain HO Utility Information' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3784, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29186, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29187, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29188, w.comment_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29189, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29190, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29191, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29192, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29193, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29194, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29195, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29196, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3784, v_project_process_step_id);
          when w.name = 'Submit Documents for PTO' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3785, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29197, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29198, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29199, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29200, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29201, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29202, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29203, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29204, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29205, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29206, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29207, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3785, v_project_process_step_id);
          when w.name = 'Receive PTO from Utility' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3786, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29208, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29209, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29210, w.comment_c::text, true);
         --   perform flow.set_pps_cfv(w.community_project_id, 2384850, 29211, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29212, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29213, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29214, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29215, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29216, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29217, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29218, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3786, v_project_process_step_id);
          when w.name = 'Customer System Activation' then
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id)
            values (w.community_project_id, 3787, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)returning id into v_project_process_step_id;
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29011, w.description_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29012, w.lov1_project_priority_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29013, w.comment_c::text, true);
           -- perform flow.set_pps_cfv(w.community_project_id, 2384850, 29014, w.assigned_to_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29015, w.ip_owner_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29016, w.lov2_role_assignment_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29017, w.lov3_blocks_c_id::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29042, w.start_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29043, w.first_complete_end_date_time_c::text, true);
            perform flow.set_pps_cfv(w.community_project_id, 2384850, 29044, w.end_date_time_c::text, true);
          --  perform flow.set_pps_cfv(w.community_project_id, 2384850, 29045, w.completed_by_c::text, true);
            perform brs.create_event_sub_tasks(w.project_task_id, 3787, v_project_process_step_id);
            else
              null;
            end case;

      end loop;
end
$do$;


DO
$do$
  declare
    x       record;
    v_count bigint;
  BEGIN
    v_count = 0;
    for x in select p.id             as project_id,
                    ccrc.auth_token_c,
                    ccrc.comments_c,
                    ccrc.credit_application_url_c,
                    ccrc.credit_check_approval_date_c,
                    ccrc.credit_check_decision_date_c,
                    ccrc.credit_check_expiration_date_c,
                    ccrc.credit_check_message_c,
                    ccrc.credit_check_submission_date_c,
                    ccrc.decision_reason_c,
                    ccrc.error_message_c,
                    ccrc.external_id_c,
                    ccrc.first_name_c,
                    ccrc.govt_id_upload_time_c,
                    ccrc.last_name_c,
                    ccrc.mortgage_pre_approval_letter_upload_time_c,
                    ccrc.mortgage_pre_approval_letter_url_c,
                    ccrc.offer_id_c,
                    ccrc.phone_c,
                    ccrc.send_lease_credit_check_failure_email_c,
                    ccrc.share_id_c,
                    ccrc.status_c,
                    ccrc.successful_invite_c,
                    lov1.id          as lov1_application_type_c_id,
                    lov2.id          as lov2_bureau_c_id,
                    lov3.id          as lov3_credit_beureu_c_id,
                    lov4.id          as lov4_lender_c_id,
                    CASE
                      WHEN row_number() OVER (PARTITION BY account_c ORDER BY ccrc.created_date desc) = 1 THEN TRUE
                      ELSE FALSE END AS is_last_row
             from brs.CREDIT_CHECK_REQUEST_C ccrc
                    inner join flow.contact c on c.nw_migration_id = ccrc.account_c
                    inner join flow.project p on p.contact_id = c.id
                    left join flow.list_of_value lov1 on lov1.name = ccrc.application_type_c and lov1.parent_id = 25709
                    left join flow.list_of_value lov2 on lov2.name = ccrc.bureau_c and lov2.parent_id = 25711
                    left join flow.list_of_value lov3 on lov3.name = ccrc.credit_beureu_c and lov3.parent_id = 25713
                    left join flow.list_of_value lov4 on lov4.name = ccrc.lender_c and lov4.parent_id = 25715
             order by ccrc.account_c,ccrc.created_date
      loop
      v_count = v_count + 1;
      if v_count = 1000 then
        raise notice 'v_count = %',v_count;
        v_count = 0;
      end if;
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3792, null, case when x.is_last_row is true then 1 else 2 end, null, now(), now(),
                2384850, 2384850, false,
                case when x.is_last_row is true then true else false end, null, null, null);

        perform flow.set_pps_cfv(x.project_id, 2384850, 28786, x.auth_token_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28788, x.comments_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28789, x.credit_application_url_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28791, x.credit_check_approval_date_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28792, x.credit_check_decision_date_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28793, x.credit_check_expiration_date_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28794, x.credit_check_message_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28796, x.credit_check_submission_date_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28797, x.decision_reason_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28798, x.error_message_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28799, x.external_id_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28800, x.first_name_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28801, x.govt_id_upload_time_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28802, x.last_name_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28804, x.mortgage_pre_approval_letter_upload_time_c::text,
                                 true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28805, x.mortgage_pre_approval_letter_url_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28806, x.offer_id_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28807, x.phone_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28808, x.send_lease_credit_check_failure_email_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28809, x.share_id_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28810, x.status_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28811, x.successful_invite_c::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28785, x.lov1_application_type_c_id::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28790, x.lov2_bureau_c_id::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28795, x.lov3_credit_beureu_c_id::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850, 28803, x.lov4_lender_c_id::text, true);
      end loop;

  end
$do$;

DO
$do$
  declare
    x record;
  v_count bigint;
  BEGIN
    v_count = 0;
    for x in select p.id as project_id,
                    tcc.alternate_apn_c,
                    tcc.apn_c,
                    tcc.census_block_c,
                    tcc.census_block_group_c,
                    tcc.census_tract_c,
                    tcc.comments_c,
                    tcc.external_property_id_c,
                    tcc.county_c,
                    tcc.county_use_c,
                    tcc.county_use_code_c,
                    tcc.land_use_c,
                    tcc.land_use_code_c,
                    tcc.legal_block_c,
                    tcc.legal_description_c,
                    tcc.legal_lot_c,
                    tcc.mailing_city_state_c,
                    tcc.mailing_street_c,
                    tcc.mailing_zip_c,
                    tcc.map_reference_c,
                    tcc.map_reference_2_c,
                    tcc.municipality_c,
                    tcc.owner_first_name_c,
                    tcc.owner_last_name_c,
                    tcc.owner_name_c,
                    tcc.property_city_c,
                    tcc.property_state_c,
                    tcc.property_street_c,
                    tcc.property_zip_c,
                    tcc.recording_date_c,
                    tcc.sale_date_c,
                    tcc.secondary_owner_c,
                    tcc.seller_name_c,
                    tcc.state_use_c,
                    tcc.state_use_code_c,
                    tcc.subdivision_c,
                    tcc.township_c,
                    tcc.township_range_section_c,
                    tcc.vesting_code_c,
                    lov1.id as lov1_action_taken_c_id,
                    CASE WHEN row_number() OVER (PARTITION BY tcc.account_c ORDER BY tcc.created_date desc) = 1 THEN TRUE ELSE FALSE END AS is_last_row
             from brs.title_check_c tcc
                    inner join flow.contact c on c.nw_migration_id = tcc.account_c
                    inner join flow.project p on p.contact_id = c.id
                    left join flow.list_of_value lov1 on lov1.name = tcc.action_taken_c and lov1.parent_id = 25729
             order by tcc.account_c,tcc.created_date

      loop
        v_count = v_count + 1;
        if v_count = 1000 then
          raise notice 'v_count = %',v_count;
          v_count = 0;
        end if;
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3794, null, case when x.is_last_row is true then 1 else 2 end,
                null, now(), now(), 2384850, 2384850, false, case when x.is_last_row is true then true else false end, null, null, null);

        perform flow.set_pps_cfv(x.project_id , 2384850,28838,x.lov1_action_taken_c_id::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28839,x.alternate_apn_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28840,x.apn_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28841,x.census_block_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28842,x.census_block_group_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28843,x.census_tract_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28844,x.comments_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28845,x.external_property_id_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28846,x.county_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28847,x.county_use_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28848,x.county_use_code_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28849,x.land_use_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28850,x.land_use_code_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28851,x.legal_block_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28852,x.legal_description_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28853,x.legal_lot_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28855,x.mailing_city_state_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28856,x.mailing_street_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28857,x.mailing_zip_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28858,x.map_reference_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28859,x.map_reference_2_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28860,x.municipality_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28861,x.owner_first_name_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28862,x.owner_last_name_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28863,x.owner_name_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28864,x.property_city_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28865,x.property_state_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28866,x.property_street_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28867,x.property_zip_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28868,x.recording_date_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28869,x.sale_date_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28870,x.secondary_owner_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28871,x.seller_name_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28872,x.state_use_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28873,x.state_use_code_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28885,x.subdivision_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28874,x.township_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28875,x.township_range_section_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,28876,x.vesting_code_c::text, true);
      end loop;

  end
$do$;

DO
$do$
  declare
    x record;

  BEGIN
    for x in select p.id as project_id,
                    o.id,
                    o.opportunity_owner_s_manager_c,
                    o.close_date,
                    o.lead_qualification_notes_c,
                    o.APPOINTMENT_TIME_C,
                    o.APPOINTMENT_DATE_C,
                    o.first_contacted_date_time_c,
                    o.description,
                    o.reason_won_lost_comments_c,
                    lov1.id as lov1_stage_name_id,
                    lov2.id as lov2_sub_stage_c_id,
                    lov3.id as lov3_reason_won_lost_c_id
             from brs.opportunity o
                  inner join brs.residential_project_c rpc on rpc.opportunity_c = o.id
                    inner join flow.project p on rpc.id = p.nw_migration_id
                    left join flow.list_of_value lov1 on lov1.name = o.stage_name and lov1.parent_id = 25746
                    left join flow.list_of_value lov2 on lov2.name = o.sub_stage_c and lov1.parent_id =25796
                    left join flow.list_of_value lov3 on lov3.name = o.reason_won_lost_c and lov1.parent_id =25798

      loop
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3795, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null);

        perform flow.set_pps_cfv(x.project_id , 2384850,29221,x.opportunity_owner_s_manager_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29228,x.close_date::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29233,x.lead_qualification_notes_c::text, true);
        if x.appointment_date_c is not null and x.APPOINTMENT_TIME_C is not null then
          begin
            perform flow.set_pps_cfv(x.project_id , 2384850,29234, TO_TIMESTAMP(CONCAT(x.APPOINTMENT_DATE_C, ' ', x.APPOINTMENT_TIME_C), 'YYYY-MM-DD HH12:MI PM')::text, true);
          exception when others then
            raise notice 'opportunity id = % APPOINTMENT_DATE_C = %, APPOINTMENT_TIME_C = %',x.id,x.APPOINTMENT_DATE_C,x.APPOINTMENT_TIME_C;
          end;
        end if;
        perform flow.set_pps_cfv(x.project_id , 2384850,29235,x.first_contacted_date_time_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29240,x.description::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29239,x.reason_won_lost_comments_c::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29222,x.lov1_stage_name_id::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29236,x.lov2_sub_stage_c_id::text, true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29238,x.lov3_reason_won_lost_c_id::text, true);
       end loop;

  end
$do$;

DO
$do$
  declare
    x                               record;
    v_project_process_step_id       bigint;
    v_project_process_step_event_id bigint;
  BEGIN
    for x in select
                    c.sub_categories_c,
                    c.subject,
                    c.jira_ticket_number_c,
                    c.resolution_comment_c,
                    p.id as project_id,
                    lov1.id as lov1_category_c_id,
                    lov3.id as lov3_status_id

             from brs."case" c
                    inner join flow.project p on c.residential_project_c = p.nw_migration_id
                    left join flow.list_of_value lov1 on lov1.name = c.category_c and lov1.parent_id =25546
                    left join flow.list_of_value lov3 on lov3.name = c.status and lov3.parent_id =25684

      loop
        v_project_process_step_event_id = null;
        v_project_process_step_id = null;

        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and
              pps.process_step_id = 3788;

        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id)
          values (x.project_id, 3788, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version)
        values (v_project_process_step_id, 238, null, 3, null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1)
        returning id into v_project_process_step_event_id;

        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28351, x.lov1_category_c_id::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 29237, x.sub_categories_c::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28350, x.subject::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28731, x.lov3_status_id::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28352, x.jira_ticket_number_c::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28353, x.resolution_comment_c::text, true);
      end loop;

  end
$do$;

DO
$do$
  declare
    x                               record;
    v_project_process_step_id       bigint;
    v_project_process_step_event_id bigint;
  BEGIN
    for x in select
                    c.sub_categories_c,
                    c.subject,

                    c.jira_ticket_number_c,
                    c.resolution_comment_c, p.id as project_id,
                    lov1.id as lov1_category_c_id,
                    lov3.id as lov3_status_id
             from brs."case" c
                   inner join flow.contact c1 on c1.nw_migration_id = c.account_id
                   inner join flow.project p on p.contact_id = c1.id
                   left join flow.list_of_value lov1 on lov1.name = c.category_c and lov1.parent_id =25546
                   left join flow.list_of_value lov3 on lov3.name = c.status and lov3.parent_id =25684
             where account_id is not null and c.residential_project_c is null

      loop
        v_project_process_step_event_id = null;
        v_project_process_step_id = null;

        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and
          pps.process_step_id = 3788;

        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id)
          values (x.project_id, 3788, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version)
        values (v_project_process_step_id, 238, null, 3, null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1)
        returning id into v_project_process_step_event_id;

        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28351, x.lov1_category_c_id::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 29237, x.sub_categories_c::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28350, x.subject::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28731, x.lov3_status_id::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28352, x.jira_ticket_number_c::text, true);
        perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28353, x.resolution_comment_c::text, true);
      end loop;

  end
$do$;

DO
$do$
  declare
    x record;

  BEGIN
    for x in
            select
              created_date,
              created_by_id,
              action_required_c,
              end_date_time_c,
              open_date_time_c,
              rework_quality_tag_c,
              severity_c,
              rca_tag_c,
              explanation_c,
              rework_reason_c,
              rework_reason_2_c,
              rework_reason_3_c,
              row_type,
              residential_project_c,
              project_id,
              lov1_action_required_c_id,
              lov2_rework_quality_tag_c_id,
              lov3_severity_c_id,
              lov4_rca_tag_c_id,
              lov5_rework_reason_c_id,
              lov6_rework_reason_2_c_id,
              lov7_rework_reason_3_c_ID,
              CASE WHEN row_number() OVER (PARTITION BY residential_project_c ORDER BY created_date desc ) = 1 THEN TRUE ELSE FALSE END AS is_last_row
              from (
            select trr.created_date,
                   trr.created_by_id,
                   null as action_required_c,
                   trr.end_date_time_c,
                   null as open_date_time_c,
                   trr.rework_quality_tag_c,
                   trr.severity_c,
                   trr.rca_tag_c,
                   trr.explanation_c,
                   null as rework_reason_c,
                   null as rework_reason_2_c,
                   null as rework_reason_3_c,
                   'TASK_REWORK_REQUEST_C' as row_type,
                   trr.residential_project_c,
                   p.id as project_id,
                   lov3.id as lov3_severity_c_id,
                   lov4.id as lov4_rca_tag_c_id,
                   null as lov1_action_required_c_id,
                   null as lov2_rework_quality_tag_c_id,
                   null as lov5_rework_reason_c_id,
                   null as lov6_rework_reason_2_c_id,
                   null as lov7_rework_reason_3_c_ID
            from flow.project p
            inner join brs.residential_project_c rpc on rpc.id = p.nw_migration_id
            inner join  brs.TASK_REWORK_REQUEST_C trr on trr.residential_project_c = rpc.id
                left join flow.list_of_value lov3 on lov3.name = severity_c and lov3.parent_id = 25801
                left join flow.list_of_value lov4 on lov4.name = rca_tag_c and lov4.parent_id = 25802
            union
             select rrc.created_date,
                    rrc.created_by_id,
                    rrc.action_required_c,
                    rrc.end_date_time_c,
                    rrc.open_date_time_c,
                    rrc.rework_quality_tag_c,
                    null as severity_c,
                    null as rca_tag_c,
                    null as explanation_c,
                    rrc.rework_reason_c,
                    rrc.rework_reason_2_c,
                    rrc.rework_reason_3_c,
                    'REWORK_REQUESTS_C' as row_type,
                    rrc.residential_project_c,
                    p.id as project_id,
                    null,
                null,
                lov1.id as lov1_action_required_c_id,
                lov2.id as lov2_rework_quality_tag_c_id,
                lov5.id as lov5_rework_reason_c_id,
                lov6.id as lov6_rework_reason_2_c_id,
                lov7.id as lov7_rework_reason_3_c_ID
             from flow.project p
            inner join brs.residential_project_c rpc on rpc.id = p.nw_migration_id
            inner join  brs.REWORK_REQUESTS_C rrc on rrc.residential_project_c = rpc.id
                left join flow.list_of_value lov1 on lov1.name = action_required_c and lov1.parent_id = 25799
                left join flow.list_of_value lov2 on lov2.name = rework_quality_tag_c and lov2.parent_id = 25800
                left join flow.list_of_value lov5 on lov5.name = rework_reason_c and lov5.parent_id = 25803
                left join flow.list_of_value lov6 on lov6.name = rework_reason_2_c and lov6.parent_id = 25804
                left join flow.list_of_value lov7 on lov7.name = rework_reason_3_c and lov7.parent_id = 25805) as foo
            order by residential_project_c,created_date

      loop

        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3796, null,  2 , null, now(), now(), 2384850, 2384850, false,
                case when x.is_last_row is true then true else false end, null, null, null);


        --perform flow.set_project_cfv(x.project_id , 2384850,29241,x.created_by_id::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29242,x.lov1_action_required_c_id::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29243,x.end_date_time_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29244,x.open_date_time_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29245,x.lov2_rework_quality_tag_c_id::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29246,x.lov3_severity_c_id::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29247,x.lov4_rca_tag_c_id::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29248,x.explanation_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29249,x.lov5_rework_reason_c_id::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29250,x.lov6_rework_reason_2_c_id::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29251,x.lov7_rework_reason_3_c_ID::text , true);
      end loop;

end
$do$;

DO
$do$
  declare
    x record;
    v_project_process_step_id bigint;
  v_project_process_step__event_id bigint;
  v_lov_scope_of_work bigint[];
  BEGIN
    for x in select wo.*,p.id as project_id,
                    lov1.id as  lov1_priority_id,
                    lov2.id as  lov2_service_type_c_id,
                    lov3.id as  lov3_disposition_reason_c_id,
                    lov4.id as  lov4_inspection_type_c_id,
                    lov5.id as  lov5_follow_up_reason_c_id
      from brs.work_order wo
      inner join flow.project p on p.nw_migration_id = wo.residential_project_c
      left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25526
      left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
      left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 225812
      left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
      left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
      where wo.record_type_id in ('0122T000000HtKlQAK','0122T000000HtKkQAK')
      and wo.residential_project_c is not null

      loop
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3797;

        if v_project_process_step_id is null then
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3797, null,  1 , null, now(), now(), 2384850, 2384850, false,
                true , null, null, null)
        returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version)
        values (v_project_process_step_id, 273, null,
          case when x.status = 'New' then 119
           when x.status = 'Assigned' then 111
           when x.status = 'In Progress' then 106
           when x.status = 'Closed' then 115
           when x.status = 'Action Completed' then 112
           when x.status = 'Closed - Unresolved' then 113
           when x.status = 'Closed - Duplicate' then 114
           when x.status = 'Scheduled' then 120
           when x.status = 'Dispatched' then 116
           when x.status = 'Completed' then 3
           when x.status = 'Canceled' then 2
           when x.status = 'Pending Customer' then 117
           when x.status = 'Cannot Complete' then 118 else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1)
        returning id into v_project_process_step__event_id;

        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29252, x.completed_date_c::text,true);
       -- perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29253, x.owner_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29254, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29255, x.lov2_service_type_c_id::text,true);
        v_lov_scope_of_work = null;
        if x.scope_of_work_c is not null then
          select array_agg(lov.id)
          into v_lov_scope_of_work
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
                 FROM (
                        SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
                        from brs.work_order w
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
          perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
        end if;

        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29257, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29258, x.lov3_disposition_reason_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29270, x.additional_comments_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29269, x.lov4_inspection_type_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29260, x.scheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29261, x.rescheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29262, x.canceled_by_self_service_user_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29263, x.follow_up_work_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29264, x.lov5_follow_up_reason_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29265, x.follow_up_reason_details_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29266, x.subject::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29267, x.description::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29268, x.intake_notes_c::text,true);



    end loop;

end
$do$;

DO
$do$
  declare
    x                                record;
    v_project_process_step_id        bigint;
    v_project_process_step__event_id bigint;
    v_lov_scope_of_work bigint[];
  BEGIN
    for x in select wo.completed_date_c,
                    wo.scope_of_work_c,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.sss_sent_date_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    wo.intake_notes_c,
                    wo.status,
                    p.id as project_id,
                    lov1.id as  lov1_priority_id,
                    lov2.id as  lov2_service_type_c_id,
                    lov3.id as  lov3_disposition_reason_c_id,
                    lov4.id as  lov4_inspection_type_c_id,
                    lov5.id as  lov5_follow_up_reason_c_id
             from brs.work_order wo
                    inner join brs.residential_project_c rpc on rpc.account_c = wo.account_id
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
                    left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
                    left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 25812
                    left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
                    left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
             where wo.record_type_id in ('0122T000000HtKlQAK', '0122T000000HtKkQAK')
               and wo.residential_project_c is null
               and wo.account_id is not null

      loop
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3797;
        if v_project_process_step_id is null then
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3797, null, 1, null, now(), now(), 2384850, 2384850, false,
                true, null, null, null)
        returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version)
        values (v_project_process_step_id, 273, null,
                case
                  when x.status = 'New' then 119
                  when x.status = 'Assigned' then 111
                  when x.status = 'In Progress' then 106
                  when x.status = 'Closed' then 115
                  when x.status = 'Action Completed' then 112
                  when x.status = 'Closed - Unresolved' then 113
                  when x.status = 'Closed - Duplicate' then 114
                  when x.status = 'Scheduled' then 120
                  when x.status = 'Dispatched' then 116
                  when x.status = 'Completed' then 3
                  when x.status = 'Canceled' then 2
                  when x.status = 'Pending Customer' then 117
                  when x.status = 'Cannot Complete' then 118
                  else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1)
        returning id into v_project_process_step__event_id;
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29252, x.completed_date_c::text,true);
        -- perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29253, x.owner_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29254, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29255, x.lov2_service_type_c_id::text,true);
        v_lov_scope_of_work = null;
        if x.scope_of_work_c is not null then
          select array_agg(lov.id)
          into v_lov_scope_of_work
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
                 FROM (
                        SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
                        from brs.work_order w
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
          perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
        end if;

        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29257, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29258, x.lov3_disposition_reason_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29270, x.additional_comments_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29269, x.lov4_inspection_type_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29260, x.scheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29261, x.rescheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29262, x.canceled_by_self_service_user_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29263, x.follow_up_work_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29264, x.lov5_follow_up_reason_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29265, x.follow_up_reason_details_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29266, x.subject::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29267, x.description::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29268, x.intake_notes_c::text,true);


      end loop;

  end
$do$;

DO
$do$
  declare
    x                                record;
    v_project_process_step_id        bigint;
    v_project_process_step__event_id bigint;
    v_lov_scope_of_work bigint[];
  BEGIN
    for x in select wo.completed_date_c,
                    wo.scope_of_work_c,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.sss_sent_date_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    wo.intake_notes_c,
                    wo.status,
                    p.id as project_id,
                    lov1.id as  lov1_priority_id,
                    lov2.id as  lov2_service_type_c_id,
                    lov3.id as  lov3_disposition_reason_c_id,
                    lov4.id as  lov4_inspection_type_c_id,
                    lov5.id as  lov5_follow_up_reason_c_id
             from brs.work_order wo
                    inner join brs.case c on c.id = wo.case_id
                    inner join brs.residential_project_c rpc on rpc.id = c.residential_project_c
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
                    left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
                    left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 25812
                    left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
                    left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
             where wo.record_type_id in ('0122T000000HtKlQAK','0122T000000HtKkQAK')
               and wo.residential_project_c is null and wo.account_id is  null and wo.case_id is not null

      loop
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3797;
        if v_project_process_step_id is null then
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3797, null, 1, null, now(), now(), 2384850, 2384850, false,
                true, null, null, null)
        returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version)
        values (v_project_process_step_id, 273, null,
                case
                  when x.status = 'New' then 119
                  when x.status = 'Assigned' then 111
                  when x.status = 'In Progress' then 106
                  when x.status = 'Closed' then 115
                  when x.status = 'Action Completed' then 112
                  when x.status = 'Closed - Unresolved' then 113
                  when x.status = 'Closed - Duplicate' then 114
                  when x.status = 'Scheduled' then 120
                  when x.status = 'Dispatched' then 116
                  when x.status = 'Completed' then 3
                  when x.status = 'Canceled' then 2
                  when x.status = 'Pending Customer' then 117
                  when x.status = 'Cannot Complete' then 118
                  else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1)
        returning id into v_project_process_step__event_id;
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29252, x.completed_date_c::text,true);
        -- perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29253, x.owner_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29254, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29255, x.lov2_service_type_c_id::text,true);
        v_lov_scope_of_work = null;
        if x.scope_of_work_c is not null then
          select array_agg(lov.id)
          into v_lov_scope_of_work
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
                 FROM (
                        SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
                        from brs.work_order w
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
          perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
        end if;

        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29257, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29258, x.lov3_disposition_reason_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29270, x.additional_comments_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29269, x.lov4_inspection_type_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29260, x.scheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29261, x.rescheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29262, x.canceled_by_self_service_user_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29263, x.follow_up_work_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29264, x.lov5_follow_up_reason_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29265, x.follow_up_reason_details_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29266, x.subject::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29267, x.description::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29268, x.intake_notes_c::text,true);


      end loop;

  end
$do$;




DO
$do$
  declare
    x                                record;
    v_project_process_step_id        bigint;
    v_project_process_step__event_id bigint;
  BEGIN
    for x in select wo.completed_date_c,
                    wo.scope_of_work_c,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.sss_sent_date_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    wo.intake_notes_c,
                    wo.status,
                    wo.response_comments_c,
                    wo.appointment_cancellation_c,
                    wo.appointment_cancellation_notes_c,
                    wo.sales_order_c,
                    wo.payment_reference_c,
                    wo.customer_po_c,
                    wo.payment_date_c,
                    wo.amount_c,
                    wo.commitment_date_c,
                    p.id as project_id,
                    lov1.id as lov1_priority_id,
                    lov2.id as lov2_service_request_type_c_id,
                    lov3.id as lov3_cancellation_reasons_c_id,
                    lov4.id as lov4_cancellation_details_c_id
             from brs.work_order wo
                    inner join brs.residential_project_c rpc on rpc.account_c = wo.account_id
                inner join flow.project p on p.nw_migration_id = rpc.id
             left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
              left join flow.list_of_value lov2 on lov2.name = wo.service_request_type_c and lov2.parent_id = 25818
              left join flow.list_of_value lov3 on lov3.name = wo.cancellation_reasons_c and lov3.parent_id = 25820
              left join flow.list_of_value lov4 on lov4.name = wo.cancellation_details_c and lov4.parent_id = 25822
             where wo.record_type_id = '01234000000M5IcAAK'

      loop
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3788;
        if v_project_process_step_id is null then
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3788, null, 1, null, now(), now(), 2384850, 2384850, false,
                true, null, null, null)
        returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version)
        values (v_project_process_step_id, 274, null,
                case
                  when x.status = 'New' then 119
                  when x.status = 'Assigned' then 111
                  when x.status = 'In Progress' then 106
                  when x.status = 'Closed' then 115
                  when x.status = 'Closed - Unresolved' then 113
                  when x.status = 'Closed - Duplicate' then 114
                  else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1)
        returning id into v_project_process_step__event_id;

        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29275, x.completed_date_c::text,true);
        --perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29271, x.owner_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29272, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29273, x.lov2_service_request_type_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29283, x.lov3_cancellation_reasons_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29284, x.lov4_cancellation_details_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29274, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29276, x.commitment_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29277, x.subject::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29278, x.description::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29290, x.intake_notes_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29280, x.response_comments_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29281, x.appointment_cancellation_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29282, x.appointment_cancellation_notes_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29285, x.sales_order_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29286, x.payment_reference_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29287, x.customer_po_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29288, x.payment_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29289, x.amount_c::text,true);

      end loop;

  end
$do$;


DO
$do$
  declare
    x                                record;
    v_project_process_step_id        bigint;
    v_project_process_step__event_id bigint;
  BEGIN
    for x in select wo.completed_date_c,
                    wo.scope_of_work_c,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.sss_sent_date_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    wo.intake_notes_c,
                    wo.status,
                    wo.response_comments_c,
                    wo.appointment_cancellation_c,
                    wo.appointment_cancellation_notes_c,
                    wo.sales_order_c,
                    wo.payment_reference_c,
                    wo.customer_po_c,
                    wo.payment_date_c,
                    wo.amount_c,
                    wo.commitment_date_c,
                    p.id as project_id,
                    lov1.id as lov1_priority_id,
                    lov2.id as lov2_service_request_type_c_id,
                    lov3.id as lov3_cancellation_reasons_c_id,
                    lov4.id as lov4_cancellation_details_c_id
             from brs.work_order wo
                    inner join brs.case c on c.id = wo.case_id
                    inner join brs.residential_project_c rpc on rpc.id = c.residential_project_c
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
                    left join flow.list_of_value lov2 on lov2.name = wo.service_request_type_c and lov2.parent_id = 25818
                    left join flow.list_of_value lov3 on lov3.name = wo.cancellation_reasons_c and lov3.parent_id = 25820
                    left join flow.list_of_value lov4 on lov4.name = wo.cancellation_details_c and lov4.parent_id = 25822
             where wo.record_type_id = '01234000000M5IcAAK'
               and wo.case_id is not null and wo.account_id is null

      loop
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3788;
        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3788, null, 1, null, now(), now(), 2384850, 2384850, false,
                true, null, null, null)
        returning id into v_project_process_step_id;
          end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version)
        values (v_project_process_step_id, 274, null,
                case
                  when x.status = 'New' then 119
                  when x.status = 'Assigned' then 111
                  when x.status = 'In Progress' then 106
                  when x.status = 'Closed' then 115
                  when x.status = 'Closed - Unresolved' then 113
                  when x.status = 'Closed - Duplicate' then 114
                  else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1)
        returning id into v_project_process_step__event_id;

        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29275, x.completed_date_c::text,true);
        --perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29271, x.owner_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29272, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29273, x.lov2_service_request_type_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29283, x.lov3_cancellation_reasons_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29284, x.lov4_cancellation_details_c_id::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29274, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29276, x.commitment_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29277, x.subject::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29278, x.description::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29290, x.intake_notes_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29280, x.response_comments_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29281, x.appointment_cancellation_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29282, x.appointment_cancellation_notes_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29285, x.sales_order_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29286, x.payment_reference_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29287, x.customer_po_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29288, x.payment_date_c::text,true);
        perform flow.set_pps_event_cfv(v_project_process_step__event_id, 2384850, 29289, x.amount_c::text,true);


      end loop;

  end
$do$;


DO
$do$
  declare
    x record;

  BEGIN
    for x in  select q.module_c,
                     q.Module_Brand_c,
                     q.module_quantity_c,
                     q.inverter_model_c,
                     q.inverter_quantity_c,
                     q.racking_quantity_c,
                     q.storage_model_c,
                     q.storage_count_c,
                     q.storage_size_k_wh_c,
                     q.storage_backup_type_c,
                     q.finance_charge_c,
                     q.non_ach_interest_rate_c,
                     q.ach_opt_in_c,
                     q.apr_type_c,
                     q.date_sent_to_my_sun_power_c,
                     q.total_sales_price_c,
                     q.non_ach_total_sales_price_c,
                     q.applied_rebate_rate_c,
                     q.Voluntary_Loan_Payment_c,
                     q.external_proposal_url_c,
                     q.selected_quote_in_my_sun_power_c,
                     q.quote_selected_date_c,
                     q.quote_number,
                     q.Leesee_Co_Leesee_c,
                     q.lessee_c,
                     q.lessee_2_c,
                     q.lease_number_c,
                     q.consolidated_lease_number_dup_c,
                     q.final_lease_number_c,
                     q.description,
                     q.Total_Lease_Payments_Pre_NSHP_Rebate_c,
                     q.RoundOff_First_Monthly_Payment_c,
                     q.RoundOff_Total_Monthly_Payments_c,
                     q.RoundOff_First_Monthly_Payment_Base_Amo_c,
                     q.RoundOff_First_Monthly_Payment_Estimate_c,
                     q.Final_First_Base_Monthly_Pay_c,
                     q.Final_Total_Yearly_Page_2_c,
                     q.Final_Total_Yearly_Page_4_c,
                     q.system_production_year_1_c,
                     q.system_price_c,
                     q.storage_price_c,
                     q.Installation_Fee_c,
                     q.Total_of_Payments_c,
                     q.Monthly_Payments_with_Estimated_Tax_c,
                     q.dealer_fees_c,
                     q.storage_commission_c,
                     q.adder_fee_c,
                     q.discount_c,
                     q.sun_power_discount_c,
                     q.tps_fee_c,
                     q.ip_fee_c,
                     q.system_cost_c,
                     q.lease_doc_created_date_c,
                     q.lease_doc_sent_out_for_signature_c,
                     q.lease_doc_signed_c,
                     q.lease_doc_signed_date_c,
                     q.Termination_Lease_doc_Date_c,
                     q.total_energy_c,
                     q.proposal_document_link_c,
                     q.power_used_before_solar_k_wh_year_c,
                     q.price_to_customer_c,
                     q.sent_welcome_email_c,
                     q.expiration_date,
                     q.contract_signed_date_c,
                     q.quote_expiration_date_c,
                     q.date_sent_to_customer_c,
                     q.dealer_contractor_license_number_c,
                     q.first_monthly_payment_c,
                     q.first_monthly_payment_base_amount_c,
                     q.first_monthly_payment_estimated_payment_c,
                     q.first_monthly_payment_est_tax_on_payme_c,
                     q.full_prepaid_lease_c,
                     q.full_pre_payment_amount_base_amount_c,
                     q.full_pre_payment_amount_estimated_paymen_c,
                     q.full_pre_payment_amount_estimated_tax_on_c,
                     q.full_prepayment_of_lease_amount_c,
                     q.System_Size_c,
                     q.Net_Cost_c,
                    p.id as project_id,
                      lov1.id as lov1_inverter_brand_c,
                     lov2.id as lov2_mounting_description_c,
                     lov3.id as lov3_monitoring_system_c,
                     lov4.id as lov4_non_backup_storage_acknowledged_c,
                     lov5.id as lov5_credit_bureau_c,
                     lov6.id as lov6_lease_doc_reviewed_c,
      CASE WHEN row_number() OVER (PARTITION BY rpc.id ORDER BY q.created_date desc) = 1 THEN TRUE ELSE FALSE END AS is_last_row
      from brs.quote q
      inner join brs.account a on a.id = q.account_c
      inner join brs.residential_project_c rpc on rpc.account_c = a.id
      inner join flow.project p on p.nw_migration_id = rpc.id
      left join flow.list_of_value lov1 on lov1.name = q.inverter_brand_c and lov1.parent_id = 25826
      left join flow.list_of_value lov2 on lov2.name = q.mounting_description_c and lov2.parent_id = 25828
      left join flow.list_of_value lov3 on lov3.name = q.monitoring_system_c and lov3.parent_id = 25830
      left join flow.list_of_value lov4 on lov4.name = q.non_backup_storage_acknowledged_c and lov4.parent_id = 25832
      left join flow.list_of_value lov5 on lov5.name = q.credit_bureau_c and lov5.parent_id = 25715
      left join flow.list_of_value lov6 on lov6.name = q.lease_doc_reviewed_c and lov6.parent_id = 25834
              order by rpc.id,q.created_date --todo carlin wants to fix this

      loop
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3798, null, 1, null, now(), now(), 2384850, 2384850, false,
                case when x.is_last_row is true then true else false end, null, null, null);

        perform flow.set_project_cfv(x.project_id , 2384850,29291,x.module_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,27998,x.Module_Brand_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29293,x.module_quantity_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29294,x.inverter_model_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29295,x.lov1_inverter_brand_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29296,x.inverter_quantity_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29297,x.lov2_mounting_description_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29298,x.racking_quantity_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29299,x.lov3_monitoring_system_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29300,x.storage_model_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29301,x.storage_count_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29302,x.storage_size_k_wh_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29303,x.storage_backup_type_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29304,x.finance_charge_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29305,x.non_ach_interest_rate_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29306,x.ach_opt_in_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29307,x.apr_type_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29308,x.date_sent_to_my_sun_power_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29309,x.total_sales_price_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29310,x.non_ach_total_sales_price_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29311,x.applied_rebate_rate_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29312,x.Voluntary_Loan_Payment_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29313,x.external_proposal_url_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29314,x.selected_quote_in_my_sun_power_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29315,x.lov4_non_backup_storage_acknowledged_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29316,x.quote_selected_date_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29317,x.quote_number::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29318,x.lov5_credit_bureau_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29319,x.Leesee_Co_Leesee_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29320,x.lessee_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29321,x.lessee_2_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29322,x.lease_number_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29323,x.consolidated_lease_number_dup_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29324,x.final_lease_number_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29325,x.description::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29326,x.Total_Lease_Payments_Pre_NSHP_Rebate_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29327,x.RoundOff_First_Monthly_Payment_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29328,x.RoundOff_Total_Monthly_Payments_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29329,x.RoundOff_First_Monthly_Payment_Base_Amo_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29330,x.RoundOff_First_Monthly_Payment_Estimate_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29331,x.Final_First_Base_Monthly_Pay_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29332,x.Final_Total_Yearly_Page_2_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29333,x.Final_Total_Yearly_Page_4_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29334,x.system_production_year_1_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29335,x.system_price_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29336,x.storage_price_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29337,x.Installation_Fee_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29338,x.Total_of_Payments_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29339,x.Monthly_Payments_with_Estimated_Tax_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29340,x.dealer_fees_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29341,x.storage_commission_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29342,x.adder_fee_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29343,x.discount_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29344,x.sun_power_discount_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29345,x.tps_fee_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29346,x.ip_fee_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29347,x.system_cost_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29348,x.lease_doc_created_date_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29349,x.lov6_lease_doc_reviewed_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29350,x.lease_doc_sent_out_for_signature_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29351,x.lease_doc_signed_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29352,x.lease_doc_signed_date_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29353,x.Termination_Lease_doc_Date_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29354,x.total_energy_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29355,x.proposal_document_link_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29356,x.power_used_before_solar_k_wh_year_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29357,x.price_to_customer_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29358,x.sent_welcome_email_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29359,x.expiration_date::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29360,x.contract_signed_date_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29361,x.quote_expiration_date_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29362,x.date_sent_to_customer_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29363,x.dealer_contractor_license_number_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29364,x.first_monthly_payment_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29365,x.first_monthly_payment_base_amount_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29366,x.first_monthly_payment_estimated_payment_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29367,x.first_monthly_payment_est_tax_on_payme_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29368,x.full_prepaid_lease_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29369,x.full_pre_payment_amount_base_amount_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29370,x.full_pre_payment_amount_estimated_paymen_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29371,x.full_pre_payment_amount_estimated_tax_on_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29372,x.full_prepayment_of_lease_amount_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29373,x.System_Size_c::text , true);
        perform flow.set_project_cfv(x.project_id , 2384850,29374,x.Net_Cost_c::text , true);

  end loop;

end
$do$;

DO
$do$
  declare
    x record;
  v_on_hold_reason_s_c bigint[];
    v_sub_category_c bigint[];
  BEGIN
    for x in select
                    dac.name,
                    dac.docu_sign_envelope_c,
                    dac.docu_sign_status_c,
                    dac.contract_type_c,
                    dac.document_url_c,
                    dac.ready_to_sign_c,
                    dac.owner_id,
                    dac.reviewer_c,
                    dac.record_type_id,
                    dac.adhoc_create_lda_requested_c,
                    dac.migrated_from_adobe_c,
                    dac.on_hold_reason_s_c,
                    dac.sub_category_c,
                    dac.notes_c,
                    dac.countersignatory_notes_c,
                    dac.cancellation_reason_c,
                    dac.hold_notes_c,
                    dac.id,
                    p.id as project_id,
                    lov1.id as lov1_cancellation_reason_c,
                    lov2.id as lov2_contract_type_c,
                    CASE WHEN row_number() OVER (PARTITION BY rpc.id ORDER BY dac.created_date desc) = 1 THEN TRUE ELSE FALSE END AS is_last_row
              from brs.ds_agreement_c dac
                     inner join brs.account a on a.id = dac.account_c
                     inner join brs.residential_project_c rpc on rpc.account_c = a.id
                     inner join flow.project p on p.nw_migration_id = rpc.id
                      left join flow.list_of_value lov1 on lov1.name = dac.cancellation_reason_c and lov1.parent_id =25850
                      left join flow.list_of_value lov2 on lov2.name = dac.contract_type_c and lov2.parent_id = 25842
              order by rpc.id,dac.created_date
      loop
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3799, null, case when x.docu_sign_envelope_c = 'Cancelled' then 3
                                              when x.status = 'Draft', null, now(), now(), 2384850, 2384850, false,
                case when x.is_last_row is true then true else false end, null, null, null);
        perform flow.set_pps_cfv(x.project_id , 2384850,,x.Name::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29379,x.contract_number_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29380,x.docu_sign_envelope_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29381,x.docu_sign_status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29382,x.lender_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29383,x.lov2_contract_type_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29384,x.finance_type_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29385,x.document_url_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29386,x.storage_only_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29387,x.ready_to_sign_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29388,x.owner_id::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29389,x.reviewer_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29390,x.record_type_id::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29391,x.Date_Sent_Formula_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29392,x.Date_Completed_Formula_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29393,x.Last_Status_Update_Formula_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29394,x.adhoc_create_lda_requested_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29395,x.migrated_from_adobe_c::text , true);
        v_on_hold_reason_s_c = null;
        if x.on_hold_reason_s_c is not null then
          select array_agg(lov.id)
          into v_on_hold_reason_s_c
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) on_hold_reason_s_c
                 FROM (
                        SELECT STRING_AGG(on_hold_reason_s_c, ';') AS aggregated_column
                        from brs.ds_agreement_c d
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.on_hold_reason_s_c and lov.parent_id = ;
          perform flow.set_pps_cfv(x.project_id , 2384850,29396,v_on_hold_reason_s_c::text , true);
        end if;
        v_sub_category_c = null;
        if x.sub_category_c is not null then
          select array_agg(lov.id)
          into v_sub_category_c
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) sub_category_c
                 FROM (
                        SELECT STRING_AGG(sub_category_c, ';') AS aggregated_column
                        from brs.ds_agreement_c d
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.sub_category_c and lov.parent_id = ;
          perform flow.set_pps_cfv(x.project_id , 2384850,29397,v_sub_category_c::text , true);
        end if;
        perform flow.set_pps_cfv(x.project_id , 2384850,29398,x.notes_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29399,x.countersignatory_notes_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29400,x.lov1_cancellation_reason_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29401,x.hold_notes_c::text , true);

      end loop;

end
$do$;


DO
$do$
  declare
    x record;

  BEGIN
    for x in select lpc.*,
              p.id as project_id,
              lov1.id as lov1_X1603_Financier_c,
              lov2.id as lov2_X1603_Status_c,
              lov3.id as lov3_DevCo_c,
              lov4.id as lov4_Funding_Tranche_c,
              lov5.id as lov5_Lease_1_or_2_c,
              lov6.id as lov6_Lease_Change_Hold_Disposition_c,
              lov7.id as lov7_Mosaic_Status_c,
              lov8.id as lov8_Oracle_Cancellation_Status_c,
              lov9.id as lov9_Reason_for_Cancellation_c,
              lov10.id as lov10_Rebate_Authority_c,
              lov11.id as lov11_SPVT_Result_c,
              lov12.id as lov12_Stage_c, --Status_c
              lov13.id as lov13_Tranche_1_Response_c,
              lov14.id as lov14_Tranche_2_Response_c,
              lov15.id as lov15_Tranche_3_Response_c,
              lov16.id as lov16_Tranching_Status_c,
               CASE WHEN row_number() OVER (PARTITION BY rpc.id ORDER BY lpc.created_date desc) = 1 THEN TRUE ELSE FALSE END AS is_last_row
             from brs.LEASE_PAYMENT_C lpc
                    inner join brs.account a on a.id = lpc.account_c
                    inner join brs.residential_project_c rpc on rpc.account_c = a.id
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name =   lpc.x_1603_financier_c  and lov1.parent_id =25861
                    left join flow.list_of_value lov2 on lov2.name =   lpc.x_1603_status_c  and lov2.parent_id =25863
                    left join flow.list_of_value lov3 on lov3.name =   lpc.dev_co_c  and lov3.parent_id =25865
                    left join flow.list_of_value lov4 on lov4.name =   lpc.Funding_Tranche_c  and lov4.parent_id =25867
                    left join flow.list_of_value lov5 on lov5.name =   lpc.Lease_1_or_2_c  and lov5.parent_id =25869
                    left join flow.list_of_value lov6 on lov6.name =   lpc.Lease_Change_Hold_Disposition_c  and lov6.parent_id =25871
                    left join flow.list_of_value lov7 on lov7.name =   lpc.Mosaic_Status_c  and lov7.parent_id =25873
                    left join flow.list_of_value lov8 on lov8.name =   lpc.Oracle_Cancellation_Status_c  and lov8.parent_id =25875
                    left join flow.list_of_value lov9 on lov9.name =   lpc.Reason_for_Cancellation_c  and lov9.parent_id =25877
                    left join flow.list_of_value lov10 on lov10.name = lpc.Rebate_Authority_c  and lov10.parent_id =25879
                    left join flow.list_of_value lov11 on lov11.name = lpc.SPVT_Result_c  and lov11.parent_id =25881
                    left join flow.list_of_value lov12 on lov12.name = lpc.Stage_c  and lov12.parent_id =25923 --Status_c
                    left join flow.list_of_value lov13 on lov13.name = lpc.Tranche_1_Response_c  and lov13.parent_id =25883
                    left join flow.list_of_value lov14 on lov14.name = lpc.Tranche_2_Response_c  and lov14.parent_id =25885
                    left join flow.list_of_value lov15 on lov15.name = lpc.Tranche_3_Response_c  and lov15.parent_id =25887
                    left join flow.list_of_value lov16 on lov16.name = lpc.Tranching_Status_c  and lov16.parent_id =25889

             order by rpc.id,lpc.created_date
      loop
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3800, null, 1, null, now(), now(), 2384850, 2384850, false,  --todo carlin to figure out status
                case when x.is_last_row is true then true else false end, null, null, null);

        perform flow.set_pps_cfv(x.project_id , 2384850,29402,x.lov1_X1603_Financier_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29403,x.US_Cash_Grant_Submission_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29404,x.X_1603_Notes_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29405,x.X_1603_Placed_In_Service_Submission_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29406,x.lov2_X1603_Status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29407,x.X_1603_Status_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29408,x.Acceptance_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29409,x.Acceptance_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29410,x.ACH_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29411,x.Note_to_Dealer_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29412,x.Add_Equipment_Qty_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29413,x.Additional_Equipment_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29414,x.Addendum_Countersigned_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29415,x.Addendum_Sent_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29416,x.Addendum_Signed_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29417,x.Annual_Escalation_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29418,x.annual_prod_report_yr_1_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29419,x.annual_prod_report_yr_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29420,x.annual_prod_report_yr_3_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29421,x.annual_prod_report_yr_4_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29422,x.Approved_Install_Docs_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29423,x.Auto_Amendment_Hold_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29424,x.Award_Amount_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29425,x.Base_Mon_Pymnt_Yr1_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29426,x.Base_Monthly_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29427,x.Base_PrePaid_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29428,x.Batch_01_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29429,x.Batch_02_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29430,x.Batch_03_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29431,x.Batch_04_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29432,x.Billing_Notes_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29433,x.Booked_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29434,x.Booking_Template_Sent_to_LD_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29435,x.Bypass_Energy_Start_Date_Update_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29436,x.Cash_Grant_Package_Complete_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29437,x.Lease_Change_Hold_Applied_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29456,x.Lease_Change_Hold_Released_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29457,x.Citi_Acceptance_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29458,x.Lease_Close_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29459,x.Closing_Request_Batch_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29460,x.Closing_Request_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29462,x.Closing_Request_Resp_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29463,x.Cmpltd_ICF_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29464,x.CM_Pymnt_Posted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29465,x.CM_Pymnt_Reference_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29466,x.CM_Pymnt_Rqustd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29467,x.CM_Pymnt_Submitted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29468,x.Cmsng_Rpt_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29469,x.Cnfrmd_ICF_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29470,x.Cnfrmd_Mon_Prvsnd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29471,x.Cmsng_Rpt_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29472,x.Cmpltd_ICF_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29473,x.Cond_Fin_LW_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29474,x.Cond_Fin_LW_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29475,x.Cond_Fin_LW_Rcvd_YN_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29476,x.Cond_Prog_LW_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29477,x.Cond_Prog_LW_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29478,x.Cnfrmd_ICF_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29479,x.Lease_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29480,x.Cost_Basis_Amount_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29481,x.Create_Lease_Summary_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29482,x.Credit_Check_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29483,x.Credit_Check_Status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29484,x.Current_Stage_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29485,x.Customer_Promise_Date_Inverter_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29486,x.Customer_Promise_Date_Mounting_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29487,x.Customer_Promise_Date_PV_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29488,x.Date_Countersigned_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29489,x.Date_Countersigned_old_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29490,x.Date_in_PTO_Letter_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29491,x.Date_Lease_Document_signed_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29492,x.Date_of_Commissioning_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29493,x.Date_Tranche_1_Submitted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29494,x.Date_Tranche_2_Submitted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29495,x.Date_Tranche_3_Submitted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29496,x.Note_to_Dealer_Install_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29497,x.Dealer_Lease_Contact_Email_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29498,x.Dealer_Lease_Contact_Name_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29499,x.Dealer_Fee_PO_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29500,x.Dealer_Fee_Total_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29501,x.Dealer_Fee_Total_old_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29502,x.Dealer_Name_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29503,x.Dealer_Rebate_Reservation_Confirmation_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29504,x.Des_Plan_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29505,x.lov3_DevCo_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29506,x.Devco_Batch_1_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29507,x.Devco_Batch_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29508,x.Devco_Batch_3_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29509,x.Devco_Batch_4_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29510,x.Docs_Gen_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29511,x.Down_Payment_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29512,x.Early_Buyout_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29513,x.Early_Buyout_Price_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29514,x.Email_1_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29515,x.Email_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29516,x.End_Customer_Account_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29517,x.Energy_Start_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29518,x.EV_Charger_Commission_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29519,x.EV_Charger_Model_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29520,x.EV_Charger_Price_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29521,x.EV_Charger_Quantity_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29522,x.EV_Outlet_Model_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29523,x.EV_Outlet_Price_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29524,x.EV_Outlet_Quantity_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29525,x.Expected_Rebate_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29526,x.Expected_Rebate_old_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29527,x.Expected_Release_of_NTP_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29528,x.Expiration_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29529,x.Fair_Market_Value_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29530,x.Fair_Market_Value_acctg_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29531,x.Final_Permits_Entered_By_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29532,x.Fin_Permits_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29533,x.lov4_Funding_Tranche_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29534,x.Financier_Change_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29535,x.Financing_Completion_Payment_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29536,x.Financing_Prepayment_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29537,x.FinancingType_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29538,x.Fin_Permits_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29539,x.Install_Acculmage_Confirmed_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29540,x.First_Name_1_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29541,x.First_Name_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29542,x.FMV_Purchase_Price_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29543,x.FMV_Rate_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29544,x.Revised_Items_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29545,x.Full_Prepaid_Lease_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29546,x.Full_Prepayment_Amt_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29547,x.Guarantee_Start_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29548,x.Hold_Back_Hannon_Mezz_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29549,x.Holdback_NTP_B_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29550,x.Hold_Back_Sr_Debt_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29551,x.Hold_Back_Sunpower_Mezz_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29552,x.Hold_Back_TE_Cash_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29553,x.Home_Phone_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29554,x.Incentive_Interconnect_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29555,x.PIS_Estimation_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29556,x.Inspection_Waiver_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29557,x.Inspection_Waiver_Received_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29558,x.Install_Doc_Count_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29559,x.Install_Documents_Remaining_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29560,x.Dealer_Fee_90_PO_Receipt_Complete_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29561,x.Dealer_Fee_90_PO_Receipt_Number_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29562,x.Install_Inv_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29563,x.Install_Inv_Amount_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29564,x.Install_Inv_Number_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29565,x.Install_Inv_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29566,x.Install_URL_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29567,x.Install_Pymnt_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29568,x.Payment_Date_Installation_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29569,x.Install_Pymnt_Sent_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29570,x.Integration_History_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29571,x.Interconnect_Documents_Remaining_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29572,x.Interconnection_Acculmaged_Confirmed_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29573,x.Interconnection_Email_Sent_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29574,x.Interconnect_URL_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29575,x.Payment_Date_Interconnect_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29576,x.Intrcnct_Pymnt_Sent_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29577,x.Intrcnct_Doc_Count_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29578,x.Dealer_Fee_10_PO_Receipt_Complete_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29579,x.Dealer_Fee_10_PO_Receipt_Number_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29580,x.Intrcnct_Inv_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29581,x.Intrcnct_Inv_Amount_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29582,x.Intrcnct_Inv_Number_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29583,x.Intrcnct_Inv_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29584,x.Intrcnct_Ltr_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29585,x.Intrcnct_Ltr_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29586,x.Intrcnct_Pymnt_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29587,x.Inverter_Brand_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29588,x.Inverter_Brand_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29589,x.Inverter_Model_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29590,x.Inverter_Model_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29591,x.Inverter_Qty_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29592,x.Inverter_Qty_2_c::text , true);
        --perform flow.set_pps_cfv(x.project_id , 2384850,,x.Inverter_Model_3_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29593,x.Invoice_Admin_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29594,x.invoice_admin_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29595,x.Invoice_Document_Email_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29596,x.LastCommaFirst_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29597,x.Last_Install_Doc_Submission_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29598,x.Last_Interconnect_Doc_Submission_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29599,x.Last_Name_1_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29600,x.Last_Name_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29601,x.lov5_Lease_1_or_2_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29602,x.lov6_Lease_Change_Hold_Disposition_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29603,x.Lease_Change_Notes_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29604,x.Lease_Cost_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29605,x.Lease_Cost_AU_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29606,x.Lease_Phase_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29607,x.Lease_Stage_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29608,x.Lease_Type_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29609,x.lov7_Mosaic_Status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29610,x.Mat_Inv_Amount_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29611,x.Mat_Inv_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29612,x.Mat_Inv_Lien_Waiver_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29613,x.Mat_Inv_LW_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29614,x.Mat_Inv_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29615,x.Mat_Pymnt_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29616,x.Mat_Pymnt_Sent_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29617,x.Mat_Pymnt_Submitted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29618,x.Module_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29619,x.Module_Qty_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29620,x.Monitoring_Type_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29621,x.Multiple_Meters_c::text , true);
        --perform flow.set_pps_cfv(x.project_id , 2384850,,x.New_Homeowner_Account_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29622,x.New_Homeowner_Contact_c::text , true);
        --perform flow.set_pps_cfv(x.project_id , 2384850,,x.New_Homeowner_Primary_Contact_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29623,x.New_Home_Owner_Email_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29624,x.New_Home_Owner_Phone_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29625,x.Note_to_Dealer_Final_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29626,x.Note_to_Dealer_Origination_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29627,x.Notice_to_Proceed_Sent_c::text , true);
       -- perform flow.set_pps_cfv(x.project_id , 2384850,,x.Opportunity_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29628,x.lov8_Oracle_Cancellation_Status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29629,x.LPS_Notes_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29630,x.Partial_prepayment_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29631,x.Partner_Account_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29632,x.Partner_Oracle_Vendor_Email_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29633,x.Payment_Received_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29634,x.Payment_Request_Submitted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29635,x.Pending_Interconnection_Email_Sent_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29636,x.Performance_Acceptance_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29637,x.Install_Pymnt_Submitted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29638,x.Photos_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29639,x.Photos_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29640,x.PIS_Deadline_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29641,x.PIS_Entry_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29642,x.Placed_In_Service_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29643,x.PO_Created_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29644,x.Preflight_Batch_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29645,x.Preflight_Batch_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29646,x.Preflight_Response_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29647,x.Presentment_1_Payment_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29648,x.Presentment_2_Payment_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29649,x.Pricing_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29650,x.Proj_Admin_Status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29651,x.Projected_Interconnect_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29652,x.Project_Type_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29653,x.Proj_Install_Compete_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29654,x.PSR_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29655,x.PTO_Letter_Issuance_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29656,x.PTO_Ltr_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29657,x.PTO_Ltr_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29658,x.Intrcnct_Pymnt_Submitted_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29659,x.Purchase_Hannon_Mezz_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29660,x.Purchase_NTP_B_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29661,x.Purchase_Price_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29662,x.Purchase_Sr_Debt_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29663,x.purchase_sun_power_mezz_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29664,x.Purchase_TE_Cash_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29665,x.Pymnt_Cert_Month_c::text , true);
        --perform flow.set_pps_cfv(x.project_id , 2384850,,x.Quote_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29666,x.Racking_Model_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29667,x.Racking_Qty_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29668,x.lov9_Reason_for_Cancellation_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29669,x.lov10_Rebate_Authority_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29670,x.Rebate_Reserved_c::text , true);
        --perform flow.set_pps_cfv(x.project_id , 2384850,,x.Residential_Project_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29671,x.rev_rec_entry_date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29672,x.RSM_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29673,x.Sales_Tax_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29674,x.Sales_Tax_Formula_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29675,x.Settlement_Hannon_Mezz_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29676,x.Settlement_NTP_B_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29677,x.Settlement_Price_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29678,x.Settlement_Sr_Debt_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29679,x.settlement_sun_power_mezz_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29680,x.Settlement_TE_Cash_c::text , true);
       -- perform flow.set_pps_cfv(x.project_id , 2384850,,x.Size_KW_c::text , true);
       -- perform flow.set_pps_cfv(x.project_id , 2384850,,x.Size_Wdc_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29681,x.SLA_Interconnect_Status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29682,x.SMS_ID_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29683,x.SMS_Installation_Checklist_Approv_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29684,x.SMS_Installation_Checklist_Received_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29685,x.SPEB_SO_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29686,x.SP_Invoice_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29687,x.SP_Invoice_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29688,x.SP_Invoice_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29689,x.spvt_case_to_sun_power_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29690,x.spvt_measurement_date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29691,x.lov11_SPVT_Result_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29692,x.SPVT_Result_Pass_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29693,x.SREC_Financier_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29694,x.SREC_Financiers_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29784,x.lov12_Stage_c::text , true);
       -- perform flow.set_pps_cfv(x.project_id , 2384850,,x.Status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29695,x.Storage_Model_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29696,x.Storage_Count_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29697,x.Storage_Commission_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29698,x.Storage_Expansion_Model_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29699,x.Storage_Expansion_Quantity_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29700,x.Storage_Price_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29701,x.Storage_Size_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29702,x.Storage_System_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29703,x.Substitute_Report_Submitted_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29704,x.Sales_order_number_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29705,x.System_Price_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29706,x.TAN_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29707,x.Tot_Monthly_Payments_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29708,x.Tranche_1_Batch_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29709,x.lov13_Tranche_1_Response_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29710,x.Tranche_1_Response_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29711,x.Tranche_1_Type_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29712,x.Tranche_2_Batch_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29713,x.lov14_Tranche_2_Response_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29714,x.Tranche_2_Response_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29715,x.Tranche_2_Type_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29716,x.Tranche_3_Batch_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29717,x.lov15_Tranche_3_Response_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29718,x.Tranche_3_Response_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29719,x.Tranche_3_Type_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29720,x.Tranche_Notes_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29721,x.lov16_Tranching_Status_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29722,x.Uncond_Fin_LW_Approved_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29723,x.Uncond_Fin_LW_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29724,x.US_Cash_Grant_Received_Date_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29725,x.Warr_SNs_Rcvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29726,x.Warr_SNs_Apprvd_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29727,x.Wattage_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29728,x.Watts_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29729,x.Welcome_Call_Complete_c::text , true);
        perform flow.set_pps_cfv(x.project_id , 2384850,29730,x.With_SH_Inventory_c::text , true);

      end loop;

  end
$do$;

SET session_replication_role = default;
