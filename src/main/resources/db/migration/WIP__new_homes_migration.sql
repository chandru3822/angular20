drop table if exists brs.RESIDENTIAL_PROJECT_C;
create table if not exists brs.RESIDENTIAL_PROJECT_C
(
  ID                                          VARCHAR(18),
  OWNER_ID                                    VARCHAR(18),
  IS_DELETED                                  BOOLEAN,
  NAME                                        VARCHAR(240),
  CURRENCY_ISO_CODE                           VARCHAR(9),
  RECORD_TYPE_ID                              VARCHAR(18),
  CREATED_DATE                                TIMESTAMPTZ,
  CREATED_BY_ID                               VARCHAR(18),
  LAST_MODIFIED_DATE                          TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID                         VARCHAR(18),
  SYSTEM_MODSTAMP                             TIMESTAMPTZ,
  LAST_ACTIVITY_DATE                          DATE,
  LAST_VIEWED_DATE                            TIMESTAMPTZ,
  LAST_REFERENCED_DATE                        TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID                      VARCHAR(18),
  CONNECTION_SENT_ID                          VARCHAR(18),
  ACCOUNT_C                                   VARCHAR(18),
  AHJ_SPECIFIC_EQUIPMENT_C                    VARCHAR(765),
  AHJ_C                                       VARCHAR(765),
  BATTERY_STORAGE_SYSTEM_DETAILS_C            VARCHAR(98304),
  BATTERY_STORAGE_C                           VARCHAR(765),
  CAN_SOLAR_BREAKER_BE_INSTALLED_IN_MSP_C     VARCHAR(765),
  CANCELLATION_JUSTIFICATION_C                VARCHAR(765),
  CONSUMPTION_MONITORING_COMPATIBLE_C         VARCHAR(765),
  HOA_CONTACT_NUMBER_C                        VARCHAR(120),
  HOA_NAME_C                                  VARCHAR(765),
  HOLD_JUSTIFICATION_C                        VARCHAR(765),
  DESIGN_REQUIRED_C                           DATE,
  HOMEOWNER_UTILITY_ACCOUNT_NO_C              VARCHAR(765),
  HOMEOWNER_UTILITY_METER_NO_C                VARCHAR(765),
  INSTALLATION_TYPE_C                         VARCHAR(765),
  MAIN_BREAKER_LOCATION_C                     VARCHAR(765),
  MAIN_BREAKER_RATING_AMPS_C                  VARCHAR(765),
  MAIN_SERVICE_PANEL_LOCATION_C               VARCHAR(765),
  MAIN_SERVICE_PANEL_MANUFACTURER_C           VARCHAR(765),
  MULTI_LEVEL_HOME_C                          VARCHAR(765),
  OPPORTUNITY_C                               VARCHAR(18),
  OTHER_MAIN_BREAKER_LOCATION_C               VARCHAR(765),
  OTHER_MAIN_SERVICE_PANEL_LOCATION_C         VARCHAR(765),
  OTHER_MAIN_SERVICE_PANEL_MANUFACTURER_C     VARCHAR(765),
  PERMITTING_AUTHORITY_C                      VARCHAR(765),
  PRIMARY_CONTACT_C                           VARCHAR(18),
  PRIORITY_C                                  VARCHAR(765),
  PROJECT_NUMBER_C                            VARCHAR(90),
  QUOTE_C                                     VARCHAR(18),
  SALES_ORDER_NUMBER_C                        VARCHAR(765),
  CURRENT_RATE_PLAN_C                         VARCHAR(765),
  SECONDARY_CONTACT_C                         VARCHAR(18),
  SMART_THERMOSTAT_C                          VARCHAR(765),
  STATUS_C                                    VARCHAR(765),
  THERMOSTAT_MANUFACTURER_C                   VARCHAR(765),
  THERMOSTAT_MODEL_C                          VARCHAR(765),
  YARD_SIGN_APPROVED_C                        BOOLEAN,
  HOA_C                                       VARCHAR(765),
  INSTALLATION_PARTNER_C                      VARCHAR(18),
  OPPORTUNITY_OWNER_EMAIL_C                   VARCHAR(240),
  PROJECT_TEMPLATE_C                          VARCHAR(18),
  ROOF_AGE_C                                  VARCHAR(765),
  SCHEDULED_SITE_SURVEY_DATE_C                TIMESTAMPTZ,
  PROPOSED_RATE_PLAN_C                        VARCHAR(765),
  SCHEDULED_AHJ_INSPECTION_C                  TIMESTAMPTZ,
  FLAT_ROOF_C                                 VARCHAR(765),
  HOME_SURVEY_C                               VARCHAR(765),
  INSTALLATION_MODEL_C                        VARCHAR(18),
  METER_COMBINERS_C                           VARCHAR(765),
  WAS_HOUSE_BUILT_BEFORE_1985_C               VARCHAR(765),
  WAS_HOUSE_BUILT_BEFORE_1987_C               VARCHAR(765),
  ACTUAL_TIME_HOURS_C                         numeric,
  BUILDER_WO_DATE_OF_RECEIPT_C                DATE,
  BUILDER_WO_VALUE_C                          numeric(9, 2),
  BUILDER_WO_C                                VARCHAR(765),
  CLOSED_WON_DATE_NH_C                        DATE,
  COMMUNITY_C                                 VARCHAR(18),
  CUSTOMER_STATE_TEXT_C                       VARCHAR(765),
  CUSTOMER_STREET_TEXT_C                      VARCHAR(765),
  CUSTOMER_ZIP_TEXT_C                         VARCHAR(765),
  ESCROW_DATE_C                               DATE,
  HERS_C                                      VARCHAR(765),
  INSPECTION_PRICE_C                          numeric(18, 2),
  INVERTER_MODEL_C                            VARCHAR(765),
  INVERTER_QUANTITY_C                         numeric,
  LOT_NUMBER_C                                VARCHAR(765),
  MATERIAL_SHIPPED_DATE_C                     DATE,
  MONITORING_C                                VARCHAR(765),
  MOUNTING_TYPE_C                             VARCHAR(765),
  NUMBER_OF_PANELS_C                          numeric,
  PDF_COPY_ONLY_C                             VARCHAR(765),
  PV_ID_C                                     VARCHAR(765),
  PV_INSTALL_PROMISED_C                       DATE,
  PV_MODULE_MODEL_C                           VARCHAR(765),
  PLAN_TYPE_C                                 VARCHAR(18),
  PROPOSED_SOLAR_BREAKER_INSTALLED_IN_MSP_C   VARCHAR(765),
  PURCHASE_ORDER_NUMBER_C                     VARCHAR(765),
  REBATE_CLAIM_NOTES_C                        VARCHAR(765),
  REBATE_RESERVATION_CONFIRMATION_LOT_C       VARCHAR(765),
  REBATE_RESERVATION_EXPIRY_DATE_LOT_C        DATE,
  SDGE_UTILITY_APPLICATION_ID_C               VARCHAR(765),
  ROOF_1_PITCH_C                              VARCHAR(765),
  ROOF_1_SYSTEM_ORIENTATION_C                 numeric,
  ROOF_2_PITCH_C                              VARCHAR(765),
  ROOF_2_SYSTEM_ORIENTATION_C                 numeric,
  ROOF_3_PITCH_C                              VARCHAR(765),
  ROOF_3_SYSTEM_ORIENTATION_C                 numeric,
  ROOF_4_PITCH_C                              VARCHAR(765),
  ROOF_4_SYSTEM_ORIENTATION_C                 numeric,
  ROOF_TYPE_C                                 VARCHAR(765),
  ROUGH_LABOR_PRICING_C                       numeric(18, 2),
  ROUGH_WIRE_PROMISED_C                       DATE,
  ROUGH_WIRE_WO_DATE_RECEIPT_C                DATE,
  ROUGH_WIRE_WO_VALUE_C                       numeric(9, 2),
  ROUGH_WIRE_WO_C                             VARCHAR(765),
  SOLAR_REBATE_ACTUAL_C                       numeric(12, 2),
  SOLAR_REBATE_EXPECTED_C                     numeric(12, 2),
  SUN_POWER_DEAL_TYPE_C                       VARCHAR(765),
  SYSTEM_ADDERS_C                             VARCHAR(4099),
  SYSTEM_WATTAGE_AC_C                         numeric,
  SYSTEM_WATTAGE_DC_C                         numeric,
  TRACKING_NUMBER_C                           VARCHAR(765),
  TRIM_LABOR_PRICING_C                        numeric(18, 2),
  TRIM_PROMISED_C                             DATE,
  TYPE_OF_DESIGN_C                            VARCHAR(765),
  EV_CHARGER_AVAILABLE_C                      VARCHAR(765),
  MATERIALS_SHIP_TO_LOCATION_C                VARCHAR(765),
  PTA_BLDG_INSPECTION_DATE_C                  DATE,
  PHASE_C                                     VARCHAR(300),
  PROJECT_CLOSE_DATE_C                        TIMESTAMPTZ,
  REQUESTED_DELIVERY_DATE_C                   DATE,
  WITNESS_TEST_DATE_C                         DATE,
  ORACLE_ORDER_HEADER_ID_C                    VARCHAR(114),
  ADDERS_VALUE_C                              numeric(18, 2),
  ADDITIONAL_BUILDER_SERVICES_WO_C            VARCHAR(765),
  ADDITIONAL_BUILDER_SERVICES_WO_VALUE_C      numeric(18, 2),
  ADDTL_BUILDER_SERVICES_WODATEOF_RECEIPT_C   DATE,
  PREVIOUS_PERMIT_ETA_C                       DATE,
  INVERTER_CONFIGURATION_C                    VARCHAR(18),
  MODULE_CONFIGURATION_C                      VARCHAR(18),
  MONITORING_INCLUDED_C                       VARCHAR(765),
  PERMIT_COST_ACTUAL_C                        numeric(18, 2),
  PURCHASE_ORDER_C                            VARCHAR(18),
  ROOF_ATTACHMENT_C                           VARCHAR(765),
  STORAGE_CONFIGURATION_C                     VARCHAR(18),
  TOTAL_SOVALUE_C                             numeric(18, 2),
  SHEET_SIZE_PROJ_C                           VARCHAR(765),
  TOTAL_NUMBER_OF_SETS_PROJ_C                 numeric,
  MATERIAL_DELIVERY_DATE_C                    DATE,
  SCHEDULED_ARRIVAL_DATE_C                    DATE,
  CF_2_R_C                                    DATE,
  DESIGN_NOTES_C                              VARCHAR(765),
  ENERGY_EFFICIENCY_CODE_C                    VARCHAR(300),
  EST_ESCROW_DATE_C                           DATE,
  HERS_INSPECTION_NOTES_C                     VARCHAR(765),
  INTERCONNECTION_NOTES_C                     VARCHAR(393216),
  NUMBER_OF_SPLIT_ARRAYS_C                    VARCHAR(15),
  PV_HERS_CERTIFICATION_TYPE_C                VARCHAR(765),
  DRIP_FEE_C                                  numeric(18, 2),
  DEALER_FEES_C                               numeric(18, 2),
  IP_FEE_C                                    numeric(18, 2),
  SPWR_RECLAIMABLE_REBATE_C                   numeric(18, 2),
  TPS_FEE_C                                   numeric(18, 2),
  LINES_READY_TO_SUBMIT_C                     VARCHAR(98304),
  SALES_ORDER_COMPLETE_DATE_C                 DATE,
  AMENDED_C                                   BOOLEAN,
  AMENDMENT_RECONCILED_C                      BOOLEAN,
  HISTORICAL_SALES_ORDER_NUMBER_C             VARCHAR(765),
  REBATE_CLAIM_APPROVED_C                     DATE,
  REBATE_CLAIM_SUBMITTED_C                    DATE,
  HERS_CERTIFICATE_RECEIVED_C                 DATE,
  HERS_INSPECTION_COMPLETED_C                 DATE,
  ROOF_1_NO_OF_MODULES_C                      numeric,
  ROOF_2_NO_OF_MODULES_C                      numeric,
  ROOF_3_NO_OF_MODULES_C                      numeric,
  ROOF_4_NO_OF_MODULES_C                      numeric,
  BUILDER_INCENTIVE_VALUE_C                   numeric(18, 2),
  CUSTOMER_CITY_TEXT_C                        VARCHAR(765),
  MIGRATED_FROM_NA_2_C                        BOOLEAN,
  NA_2_INVERTER_MODEL_ACTUAL_C                VARCHAR(765),
  NA_2_MODULE_MODEL_NUMBER_C                  VARCHAR(765),
  ROOFER_LABOR_PRICING_C                      numeric(18, 2),
  REV_REC_LINE_C                              numeric,
  REBATE_CLAIM_EXPIRY_DATE_C                  DATE,
  PRE_COE_COMMISSIONING_PRICING_C             numeric(8, 2),
  FURTHER_DISCOUNT_AMOUNT_C                   numeric(18, 2),
  AC_PRE_PLUMB_C                              numeric(18, 2),
  FURTHER_DISCOUNT_RATIONALE_C                VARCHAR(765),
  WO_PRICE_C                                  numeric(9, 2),
  WO_SYSTEM_SIZE_W_C                          numeric,
  DEAL_TYPE_DISCREPANCY_C                     BOOLEAN,
  FURTHER_DISCOUNT_PERCENT_C                  numeric,
  FURTHER_DISCOUNT_STATUS_C                   VARCHAR(765),
  HIDDEN_CALCULATED_BUILDER_WO_VALUE_C        numeric(9, 2),
  MODEL_DISCOUNT_AMOUNT_C                     numeric(18, 2),
  MODEL_DISCOUNT_PERCENT_C                    numeric,
  NET_CONTRACTED_PRICE_C                      numeric(18, 2),
  PRICE_DISCREPANCY_C                         BOOLEAN,
  SYSTEM_SIZE_DISCREPANCY_C                   BOOLEAN,
  WRAP_INSURANCE_AMOUNT_C                     numeric(18, 2),
  BUILDER_INVOICE_AMOUNT_MO_HISTORY_C         BOOLEAN,
  AC_ROUGH_WIRE_C                             numeric(18, 2),
  AC_WIRE_INSTALLATION_AFTER_PRE_PLUMB_C      numeric(18, 2),
  CUSTOM_ADDER_DISTANCE_C                     numeric(18, 2),
  CUSTOM_ADDER_STEEP_ROOF_C                   numeric(18, 2),
  MODULE_INSTALLATION_C                       numeric(18, 2),
  PERMITTING_LABOR_ONLY_C                     numeric(18, 2),
  X_3_STORY_ROOF_C                            numeric(18, 2),
  SALES_ADDERS_C                              VARCHAR(3072),
  ROOFER_PARTNER_C                            VARCHAR(18),
  PERMIT_ETA_C                                DATE,
  SCHEDULED_INSTALLATION_DATE_C               TIMESTAMPTZ,
  PERMIT_AHJ_FEES_C                           numeric(18, 2),
  PERMIT_EXECUTION_FEES_C                     numeric(18, 2),
  READY_FOR_INSTALL_C                         DATE,
  READY_FOR_ROUGH_WIRE_C                      DATE,
  UTILITY_APPLICATION_ID_C                    numeric,
  READY_FOR_INSTALL_CHECKBOX_C                BOOLEAN,
  READY_FOR_ROUGH_WIRE_CHECKBOX_C             BOOLEAN,
  TRENCH_DATE_PROMISED_C                      DATE,
  LENGTH_OF_INSTALLATION_C                    VARCHAR(765),
  SERIAL_NUMBER_C                             VARCHAR(765),
  SOLAR_ACCESS_C                              numeric,
  TIME_ZONE_NAME_C                            VARCHAR(765),
  REMOTE_HOME_SURVEY_STATUS_C                 VARCHAR(765),
  NH_STORAGE_SIZE_C                           VARCHAR(765),
  BUILDER_WO_STORAGE_PRICE_C                  numeric(18, 2),
  STORAGE_PRICE_DISCREPANCY_C                 BOOLEAN,
  WO_STORAGE_PRICE_C                          numeric(18, 2),
  AHJNAME_C                                   VARCHAR(18),
  EV_CHARGER_COMMISSION_C                     numeric(16, 2),
  EV_CHARGER_MODEL_C                          VARCHAR(765),
  MPU_INVOICE_APPROVED_DATE_C                 DATE,
  MPU_INVOICE_AMOUNT_C                        numeric(18, 2),
  MPU_NEW_BUSBAR_VALUE_C                      VARCHAR(765),
  MPU_NEW_MAIN_BREAKER_VALUE_C                VARCHAR(765),
  MPU_PO_NUMBER_C                             VARCHAR(765),
  MPU_SCOPE_OF_WORK_C                         VARCHAR(765),
  MPU_SERVICE_TYPE_C                          VARCHAR(765),
  REROOF_INVOICE_APPROVED_DATE_C              DATE,
  REROOF_INVOICE_AMOUNT_C                     numeric(18, 2),
  REROOF_PO_NUMBER_C                          VARCHAR(765),
  REROOF_PROPOSAL_TYPE_C                      VARCHAR(765),
  REROOF_SCOPE_OF_WORK_C                      VARCHAR(765),
  REROOF_PROPOSAL_AMOUNT_C                    numeric(18, 2),
  SCHEDULED_MPU_DATE_C                        DATE,
  SCHEDULED_MPU_INSPECTION_DATE_C             DATE,
  SCHEDULED_REROOF_DATE_C                     DATE,
  SCHEDULED_REROOF_INSPECTION_DATE_C          DATE,
  MPU_NOTES_C                                 VARCHAR(98304),
  REROOF_NOTES_C                              VARCHAR(98304),
  REROOF_SQUARES_C                            numeric,
  SCHEDULED_HOME_ENERGY_AUDIT_DATE_C          TIMESTAMPTZ,
  SCHEDULED_PARALLEL_SITE_SURVEY_DATE_C       TIMESTAMPTZ,
  SUN_POWER_PERMIT_OVERRIDE_C                 BOOLEAN,
  EVSE_IP_FEE_C                               numeric(18, 2),
  EVSE_NOTES_C                                VARCHAR(98304),
  SCHEDULED_EV_INSTALLATION_DATE_C            DATE,
  EV_ELECTRICIAN_PARTNER_C                    VARCHAR(18),
  MPU_ELECTRICIAN_PARTNER_C                   VARCHAR(18),
  SUN_VAULT_DEAL_TYPE_C                       VARCHAR(765),
  RP_FIELDS_AND_BUILDER_FILES_VALIDATED_C     VARCHAR(765),
  COMMITMENT_DATE_C                           DATE,
  NTP_DATE_C                                  DATE,
  PTO_DATE_C                                  DATE,
  RSE_OUTCOME_C                               VARCHAR(765),
  SITE_ID_C                                   VARCHAR(765),
  SYSTEM_ACTIVATION_STATUS_C                  VARCHAR(765),
  WI_FI_CONNECTED_C                           BOOLEAN,
  ESD_DATE_C                                  DATE,
  EVSE_COUNT_C                                VARCHAR(765),
  EVSE_NAME_C                                 VARCHAR(765),
  EVSE_TYPE_C                                 VARCHAR(765),
  EV_CHARGER_RETAIL_AMOUNT_C                  numeric(18, 2),
  PV_ROUGH_PO_C                               VARCHAR(765),
  PV_TRIM_PO_C                                VARCHAR(765),
  ROOFER_INSET_PO_C                           VARCHAR(765),
  STORAGE_ROUGH_PO_C                          VARCHAR(765),
  STORAGE_TRIM_PO_C                           VARCHAR(765),
  TRENCH_COMPLETED_BY_C                       VARCHAR(18),
  TRENCH_DATE_C                               DATE,
  TRENCH_STARTED_C                            BOOLEAN,
  STORAGE_INSTALL_COMPLETE_C                  BOOLEAN,
  STORAGE_INSTALL_PROMISED_C                  DATE,
  STORAGE_ROUGH_COMPLETE_C                    BOOLEAN,
  STORAGE_ROUGH_WIRE_PROMISED_C               DATE,
  EV_CHARGER_PRICE_C                          numeric(18, 2),
  EV_CHARGER_QUANTITY_C                       numeric,
  EV_OUTLET_MODEL_C                           VARCHAR(765),
  EV_OUTLET_PRICE_C                           numeric(18, 2),
  EV_OUTLET_QUANTITY_C                        numeric,
  REV_REC_DATE_C                              DATE,
  UTILITY_TEXT_C                              VARCHAR(765),
  SUN_VAULT_EC_GUIDE_COMPLEXITY_C             VARCHAR(765),
  SUN_VAULT_INSTALLATION_COMPLEXITY_C         VARCHAR(765),
  ACTIVATION_COORDINATOR_C                    VARCHAR(18),
  SUNVAULT_MODEL_DISCOUNT_AMOUNT_C            numeric(18, 2),
  SUNVAULT_MODEL_DISCOUNT_C                   numeric,
  BLOCK_REASON_C                              VARCHAR(765),
  FORECASTED_UNBLOCK_DATE_C                   DATE,
  FORECASTED_INSTALL_START_C                  DATE,
  FORECASTED_INSTALL_COMPLETION_C             DATE,
  HOA_SUBMISSION_DATE_C                       DATE,
  ESCROW_DATE_HO_C                            DATE,
  FOLLOW_UP_DATE_C                            DATE,
  PERMIT_APPROVED_C                           DATE,
  PERMIT_ETA_REWORK_REASON_C                  VARCHAR(765),
  PERMIT_FEES_PAID_C                          VARCHAR(765),
  PERMIT_FEES_PAID_IN_FULL_C                  BOOLEAN,
  SOLAR_APP_ELIGIBLE_C                        BOOLEAN,
  SUBMITTED_THROUGH_SOLAR_APP_C               BOOLEAN,
  FIRST_QUOTE_LOCK_DATE_C                     DATE,
  FIRST_SCHEDULED_INSTALLATION_DATE_C         TIMESTAMPTZ,
  INCENTIVE_STATUS_C                          VARCHAR(765),
  PROJECT_COORDINATOR_C                       VARCHAR(18),
  RESCHEDULED_REASON_CODE_C                   VARCHAR(765),
  RESCHEDULED_REASON_OTHER_C                  VARCHAR(765),
  FORECASTED_INSTALLATION_COMPLETE_C          TIMESTAMPTZ,
  FORECASTED_INSTALLATION_START_C             TIMESTAMPTZ,
  INTERCONNECTION_ETA_DATE_C                  DATE,
  RA_ONLY_DATE_C                              DATE,
  TWILIO_HO_ESCROW_DATE_STATUS_C              VARCHAR(765),
  BETA_LAUNCH_ESCROW_C                        BOOLEAN,
  CT_CATEGORY_DESIGN_C                        VARCHAR(765),
  CT_CATEGORY_DISCREPANCY_C                   VARCHAR(765),
  CT_CATEGORY_FIELD_QUALITY_C                 VARCHAR(765),
  CT_COMMENTS_C                               VARCHAR(765),
  CT_SHOULD_BE_INSTALLED_C                    VARCHAR(765),
  HO_PROVIDED_ESCROW_RESPONSE_C               VARCHAR(765),
  WAS_CT_INSTALLED_C                          VARCHAR(765),
  EXISTING_INSTALL_C                          BOOLEAN,
  _FIVETRAN_SYNCED                            TIMESTAMPTZ,
  SUN_VAULT_PART_NUMBER_C                     VARCHAR(54),
  NEW_CONSTRUCTION_ADU_C                      BOOLEAN,
  HOLD_RELEASE_DATE_C                         DATE,
  PERMIT_APPLICATION_NUMBER_C                 VARCHAR(765),
  UTILITY_INFO_EMAIL_SENT_C                   DATE,
  SITE_BETA_C                                 BOOLEAN,
  NEM_APPLICABILITY_C                         VARCHAR(765),
  UTILITY_METER_NUMBER_C                      VARCHAR(765),
  UTILITY_ACCOUNT_NUMBER_C                    VARCHAR(765),
  SITE_LAUNCH_TYPE_C                          VARCHAR(765),
  SITE_PRODUCT_LINE_C                         VARCHAR(765),
  PRE_INSTALL_SUBMITTED_C                     BOOLEAN,
  DEEMED_COMPLETED_C                          BOOLEAN,
  ESTIMATED_INSTALL_LABOR_HOURS_C             numeric,
  _FIVETRAN_DELETED                           BOOLEAN,
  PCS_C                                       BOOLEAN,
  RISK_RECORD_C                               BOOLEAN,
  RISK_RECORD_DATE_C                          DATE,
  IS_NEM_2_0_C                                BOOLEAN,
  STORAGE_SYSTEM_C                            VARCHAR(765),
  AC_SYSTEM_SIZE_C                            numeric,
  APPLICATION_DATE_SUBMISSION_DATE_C          TIMESTAMPTZ,
  STORAGE_SYSTEM_K_WH_C                       numeric,
  APPLICATION_REVISION_NUMBER_C               VARCHAR(765),
  INTERCONNECTION_APPLICATION_REVISION_DATE_C DATE,
  HOA_NAME_2_C                                VARCHAR(765),
  STORAGE_PARTNER_C                           VARCHAR(18),
  AMOUNT_CONTRIBUTED_BY_SPWR_C                numeric(18, 2),
  EXISTING_PV_SYSTEM_SIZE_C                   numeric,
  EXISTING_INVERTER_TYPE_C                    VARCHAR(765),
  CHANGE_ORDER_TRANSACTED_DATE_C              DATE,
  INSTALL_COMPLETED_C                         DATE,
  DOG_ON_SITE_C                               VARCHAR(765),
  EXISTING_PV_FINANCIAL_OFFERING_C            VARCHAR(765),
  REASON_LEVEL_1_C                            VARCHAR(765),
  INSTALL_COMPLETED_BY_C                      VARCHAR(18),
  CREDIT_MEMO_TRANSACTED_DATE_C               DATE,
  AGE_OF_HOME_C                               VARCHAR(765),
  TRIM_INSTALL_COMPLETED_C                    DATE,
  CHANGE_ORDER_TOTAL_COST_C                   numeric(18, 2),
  ATTIC_CRAWL_SPACE_C                         VARCHAR(765),
  TRIM_INSTALL_COMPLETED_BY_C                 VARCHAR(18),
  ELAPSED_DATE_TIME_C                         TIMESTAMPTZ,
  CHANGE_ORDER_TRANSACTED_BY_C                VARCHAR(18),
  EXISTING_INVERTER_QUANTITY_C                numeric,
  PV_INSTALL_COMPLETED_BY_C                   VARCHAR(18),
  INSTALL_COMPLETE_C                          BOOLEAN,
  STRUCTURAL_OPTION_C                         VARCHAR(765),
  ROUGH_WIRE_COMPLETED_C                      DATE,
  AGE_OF_ROOF_C                               VARCHAR(765),
  ENHANCEMENTS_C                              VARCHAR(765),
  ELEVATION_C                                 VARCHAR(765),
  PREFERRED_COMMUNICATION_C                   VARCHAR(765),
  AMOUNT_CONTRIBUTED_BY_DEALER_C              numeric(18, 2),
  UNBLOCK_QUOTE_AMENDMENT_C                   BOOLEAN,
  UTILITY_METER_CONFIRMATION_DATE_C           DATE,
  COMPLEXITY_INDICATOR_C                      VARCHAR(765),
  UTILITY_METER_INSTALLED_C                   VARCHAR(765),
  AMOUNT_CONTRIBUTED_BY_CUSTOMER_C            numeric(18, 2),
  TRIM_INSTALL_COMPLETE_C                     BOOLEAN,
  MILESTONE_C                                 VARCHAR(765),
  PV_INSTALL_COMPLETE_C                       BOOLEAN,
  EXISTING_MONITORING_DEVICE_C                VARCHAR(765),
  TREE_TRIM_C                                 VARCHAR(765),
  INTAKE_NOTES_C                              VARCHAR(98304),
  ROUGHWIRE_COMPLETE_C                        BOOLEAN,
  CHANGE_ORDER_ENTERED_BY_C                   VARCHAR(18),
  ROUGH_WIRE_COMPLETED_BY_C                   VARCHAR(18),
  CHANGE_ORDER_ENTERED_DATE_C                 DATE,
  EXISTING_PV_PANEL_TYPE_C                    VARCHAR(765),
  EXISTING_PV_PANEL_QUANTITY_C                numeric,
  STORAGE_RW_C                                numeric(18, 2),
  INVERTER_STATUS_C                           VARCHAR(765),
  WO_STORAGE_SIZE_C                           VARCHAR(765),
  STORAGE_SIZE_DISCREPANCY_C                  BOOLEAN,
  STORAGE_INSTALL_C                           numeric(18, 2),
  INVOICE_NUMBER_C                            numeric,
  GATE_CODE_C                                 VARCHAR(765),
  REASON_LEVEL_2_C                            VARCHAR(765),
  PRE_COE_COMM_FAILURE_REASON_C               VARCHAR(765),
  ADDERS_VALUE_QUOTE_C                        numeric(18, 2),
  CUSTOMER_CONSTRUCTION_PROJECT_C             VARCHAR(765),
  MICROINVERTER_STATUS_C                      VARCHAR(765),
  ESCALATION_C                                BOOLEAN,
  TIME_DIFFERENTIAL_C                         numeric,
  VIP_C                                       BOOLEAN,
  ROOF_MATERIAL_C                             VARCHAR(765),
  CREDIT_MEMO_NUMBER_C                        numeric,
  HOA_CONTACT_PHONE_EMAIL_C                   VARCHAR(765),
  PRE_COE_COMM_NOTES_C                        VARCHAR(765),
  PV_INSTALL_COMPLETED_C                      DATE,
  LINKED_RP_C                                 VARCHAR(18),
  STORAGE_INSTALL_COMPLETE_PULL_DATE_C        TIMESTAMPTZ,
  ROUGH_WIRE_PULL_DATE_C                      TIMESTAMPTZ,
  INSTALL_PULL_DATE_C                         TIMESTAMPTZ,
  TRIM_INSTALL_PULL_DATE_C                    TIMESTAMPTZ,
  STORAGE_ROUGH_COMPLETE_PULL_DATE_C          TIMESTAMPTZ,
  SITE_SURVEY_COMPLETE_DATE_C                 DATE,
  AT_RISK_TO_PENDING_CANCELLATION_DATE_C      DATE,
  PAYMENT_PRE_AUTH_OUTCOME_C                  VARCHAR(765),
  PERMIT_APPROVED_NOTIFICATION_C              VARCHAR(765),
  READY_TO_SCHEDULE_NOTIFICATION_C            VARCHAR(765),
  PTO_DATE_NOTIFICATION_C                     VARCHAR(765),
  INSTALL_COMPLETE_NOTIFICATION_C             VARCHAR(765),
  DESIGN_COMPLETED_NOTIFICATION_C             VARCHAR(765),
  INSPECTION_PASSED_NOTIFICATION_C            VARCHAR(765),
  SCHEDULED_INSTALL_DATE_NOTIFICATION_C       VARCHAR(765),
  OK_TO_SCHEDULE_NOTIFICATION_C               VARCHAR(765),
  OK_TO_SCHEDULE_C                            TIMESTAMPTZ,
  EV_SITE_SURVEY_C                            numeric(18, 2),
  STORAGE_CONFIGURATION_GROUP_C               VARCHAR(18),
  EV_WORKMANSHIP_WARRANTY_C                   TIMESTAMPTZ,
  ESTIMATED_HARDWARE_DELIVERY_DATE_C          DATE,
  HARDWARE_DELIVERED_DATE_C                   DATE,
  DESIGN_REJECTED_DETAILS_C                   VARCHAR(1500),
  DESIGN_VERIFICATION_C                       VARCHAR(765),
  TRIGGER_DESIGN_VERIFICATION_C               BOOLEAN,
  DESIGN_STATUS_C                             VARCHAR(765),
  SHARE_WITH_GUEST_USER_C                     BOOLEAN,
  DESIGN_STATUS_DATE_C                        TIMESTAMPTZ,
  DESIGN_REJECTED_REASON_C                    VARCHAR(765),
  INSTALLATION_PHOTO_CIRCLE_LINK_C            VARCHAR(765),
  OM_PHOTO_CIRCLE_LINK_C                      VARCHAR(765),
  AUTO_BOOKED_C                               BOOLEAN,
  SITE_SURVEY_PHOTO_CIRCLE_LINK_C             VARCHAR(765),
  INSPECTION_PHOTO_CIRCLE_LINK_C              VARCHAR(765),
  T_24_NOTES_C                                VARCHAR(393216),
  STORAGE_ROUGH_COMPLETE_DATE_C               DATE,
  STORAGE_INSTALL_COMPLETE_DATE_C             DATE,
  STORAGE_ROUGH_COMPLETED_BY_C                VARCHAR(18),
  STORAGE_INSTALL_COMPLETED_BY_C              VARCHAR(18),
  OWNING_TEAM_C                               VARCHAR(765),
  CUSTOMER_CONTACT_UPDATE_DATE_C              DATE,
  INTEGRATION_STATUS_C                        VARCHAR(765),
  TIGER_TEAM_C                                BOOLEAN,
  CUSTOMER_CONTACT_UPDATE_C                   VARCHAR(765),
  MISC_NOTES_C                                VARCHAR(765),
  MODULE_COUNT_DISCREPANCY_C                  BOOLEAN,
  ACTIVATE_INSTALL_TRACKER_TIMESTAMP_C        TIMESTAMPTZ,
  EMAILS_SENT_C                               VARCHAR(4099),
  DAYLIGHT_SAVINGS_OFFSET_C                   numeric,
  OPP_TEAM_COMPLETE_C                         BOOLEAN,
  UPDATE_SHARING_C                            BOOLEAN,
  INTERNET_ACCESS_C                           VARCHAR(765),
  TIME_ZONE_ID_C                              VARCHAR(765),
  WO_STORAGE_C                                VARCHAR(18),
  TIME_ZONE_RAW_OFFSET_C                      numeric
);

drop table if exists brs.ACCOUNT;
create table if not exists brs.ACCOUNT
(
  ID                                                  VARCHAR(18),
  IS_DELETED                                          BOOLEAN,
  MASTER_RECORD_ID                                    VARCHAR(18),
  NAME                                                VARCHAR(765),
  LAST_NAME                                           VARCHAR(240),
  FIRST_NAME                                          VARCHAR(120),
  SALUTATION                                          VARCHAR(120),
  TYPE                                                VARCHAR(765),
  RECORD_TYPE_ID                                      VARCHAR(18),
  PARENT_ID                                           VARCHAR(18),
  BILLING_STREET                                      VARCHAR(765),
  BILLING_CITY                                        VARCHAR(120),
  BILLING_STATE                                       VARCHAR(240),
  BILLING_POSTAL_CODE                                 VARCHAR(60),
  BILLING_COUNTRY                                     VARCHAR(240),
  BILLING_LATITUDE                                    numeric,
  BILLING_LONGITUDE                                   numeric,
  BILLING_GEOCODE_ACCURACY                            VARCHAR(120),
  SHIPPING_STREET                                     VARCHAR(765),
  SHIPPING_CITY                                       VARCHAR(120),
  SHIPPING_STATE                                      VARCHAR(240),
  SHIPPING_POSTAL_CODE                                VARCHAR(60),
  SHIPPING_COUNTRY                                    VARCHAR(240),
  SHIPPING_LATITUDE                                   numeric,
  SHIPPING_LONGITUDE                                  numeric,
  SHIPPING_GEOCODE_ACCURACY                           VARCHAR(120),
  PHONE                                               VARCHAR(120),
  FAX                                                 VARCHAR(120),
  ACCOUNT_NUMBER                                      VARCHAR(120),
  WEBSITE                                             VARCHAR(765),
  PHOTO_URL                                           VARCHAR(765),
  SIC                                                 VARCHAR(60),
  INDUSTRY                                            VARCHAR(765),
  ANNUAL_REVENUE                                      numeric(18),
  NUMBER_OF_EMPLOYEES                                 numeric,
  OWNERSHIP                                           VARCHAR(765),
  TICKER_SYMBOL                                       VARCHAR(60),
  DESCRIPTION                                         VARCHAR(96000),
  RATING                                              VARCHAR(765),
  SITE                                                VARCHAR(240),
  CURRENCY_ISO_CODE                                   VARCHAR(9),
  OWNER_ID                                            VARCHAR(18),
  CREATED_DATE                                        TIMESTAMPTZ,
  CREATED_BY_ID                                       VARCHAR(18),
  LAST_MODIFIED_DATE                                  TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID                                 VARCHAR(18),
  SYSTEM_MODSTAMP                                     TIMESTAMPTZ,
  LAST_ACTIVITY_DATE                                  DATE,
  LAST_VIEWED_DATE                                    TIMESTAMPTZ,
  LAST_REFERENCED_DATE                                TIMESTAMPTZ,
  IS_PARTNER                                          BOOLEAN,
  IS_CUSTOMER_PORTAL                                  BOOLEAN,
  PERSON_CONTACT_ID                                   VARCHAR(18),
  IS_PERSON_ACCOUNT                                   BOOLEAN,
  CHANNEL_PROGRAM_NAME                                VARCHAR(765),
  CHANNEL_PROGRAM_LEVEL_NAME                          VARCHAR(765),
  PERSON_MAILING_STREET                               VARCHAR(765),
  PERSON_MAILING_CITY                                 VARCHAR(120),
  PERSON_MAILING_STATE                                VARCHAR(240),
  PERSON_MAILING_POSTAL_CODE                          VARCHAR(60),
  PERSON_MAILING_COUNTRY                              VARCHAR(240),
  PERSON_MAILING_LATITUDE                             numeric,
  PERSON_MAILING_LONGITUDE                            numeric,
  PERSON_MAILING_GEOCODE_ACCURACY                     VARCHAR(120),
  PERSON_OTHER_STREET                                 VARCHAR(765),
  PERSON_OTHER_CITY                                   VARCHAR(120),
  PERSON_OTHER_STATE                                  VARCHAR(240),
  PERSON_OTHER_POSTAL_CODE                            VARCHAR(60),
  PERSON_OTHER_COUNTRY                                VARCHAR(240),
  PERSON_OTHER_LATITUDE                               numeric,
  PERSON_OTHER_LONGITUDE                              numeric,
  PERSON_OTHER_GEOCODE_ACCURACY                       VARCHAR(120),
  PERSON_MOBILE_PHONE                                 VARCHAR(120),
  PERSON_HOME_PHONE                                   VARCHAR(120),
  PERSON_OTHER_PHONE                                  VARCHAR(120),
  PERSON_ASSISTANT_PHONE                              VARCHAR(120),
  PERSON_EMAIL                                        VARCHAR(240),
  PERSON_TITLE                                        VARCHAR(240),
  PERSON_DEPARTMENT                                   VARCHAR(240),
  PERSON_ASSISTANT_NAME                               VARCHAR(120),
  PERSON_LEAD_SOURCE                                  VARCHAR(765),
  PERSON_BIRTHDATE                                    DATE,
  PERSON_HAS_OPTED_OUT_OF_EMAIL                       BOOLEAN,
  PERSON_DO_NOT_CALL                                  BOOLEAN,
  PERSON_LAST_CUREQUEST_DATE                          TIMESTAMPTZ,
  PERSON_LAST_CUUPDATE_DATE                           TIMESTAMPTZ,
  PERSON_EMAIL_BOUNCED_REASON                         VARCHAR(765),
  PERSON_EMAIL_BOUNCED_DATE                           TIMESTAMPTZ,
  PERSON_INDIVIDUAL_ID                                VARCHAR(18),
  JIGSAW                                              VARCHAR(60),
  JIGSAW_COMPANY_ID                                   VARCHAR(60),
  ACCOUNT_SOURCE                                      VARCHAR(765),
  SIC_DESC                                            VARCHAR(240),
  CONNECTION_RECEIVED_ID                              VARCHAR(18),
  CONNECTION_SENT_ID                                  VARCHAR(18),
  ACBPARANET_ID_C                                     VARCHAR(75),
  ALLIANCE_PROGRAM_PARTNER_C                          BOOLEAN,
  ANALYSIS_YEAR_C                                     VARCHAR(15),
  ASSIGNED_TSE_C                                      VARCHAR(18),
  SIGNED_RESIDENTIAL_INSTALLER_AGREEMENT_C            BOOLEAN,
  AUTHORIZED_PARTNER_DATE_C                           DATE,
  AUTHORIZED_TO_ORDER_C                               BOOLEAN,
  COMPLETED_AND_SIGNED_CREDIT_APPLICATION_C           BOOLEAN,
  COUNTRY_DOMAIN_C                                    VARCHAR(765),
  CREDIT_CHECK_C                                      BOOLEAN,
  CREDIT_HOLD_C                                       BOOLEAN,
  CREDIT_LIMIT_DATE_C                                 DATE,
  CREDIT_LIMIT_C                                      numeric(10, 2),
  FEDERAL_AGENCY_C                                    BOOLEAN,
  FORECASTING_TOOL_ACCESS_C                           BOOLEAN,
  INTEGRATION_ID_C                                    VARCHAR(60),
  LAST_OPPORTUNITY_ASSIGNED_DATE_C                    DATE,
  MANAGE_OPPORTUNITIES_C                              BOOLEAN,
  NEXT_CREDIT_REVIEW_C                                DATE,
  NUM_OPEN_OPPORTUNITIES_C                            numeric,
  OPPORTUNITY_CLOSE_RATE_C                            numeric,
  ORACLE_ACCOUNT_CREATED_C                            BOOLEAN,
  OVERRIDE_DUPLICATE_CHECK_C                          BOOLEAN,
  PARTICIPATE_IN_CUSTOMER_SURVEY_C                    BOOLEAN,
  PARTICIPATE_IN_INSPECTION_SURVEY_C                  BOOLEAN,
  PARTNER_ACTIVATED_DATE_TIME_C                       TIMESTAMPTZ,
  PARTNER_APPLICATION_C                               VARCHAR(18),
  PARTNER_FACTS_C                                     VARCHAR(96000),
  PARTNER_LOGO_C                                      VARCHAR(765),
  PARTNER_PORTAL_ACCESS_C                             BOOLEAN,
  PAYBACK_PLAN_C                                      BOOLEAN,
  PREFERRED_AGENT_C                                   VARCHAR(18),
  PRIMARY_CONTACT_C                                   VARCHAR(18),
  PROMOTED_PREMIER_DATE_C                             DATE,
  RSM_C                                               VARCHAR(18),
  RESALE_CERTIFICATE_C                                BOOLEAN,
  REVIEW_CYCLE_C                                      VARCHAR(765),
  SENT_PARTNER_PACKAGE_C                              BOOLEAN,
  SIGNED_AUTHORIZED_PARTNER_AGREEMENT_C               BOOLEAN,
  SIGNED_NON_DISCLOSURE_AGREEMENT_C                   BOOLEAN,
  SIGNED_PREMIER_PARTNER_AGREEMENT_C                  BOOLEAN,
  SIGNED_AND_NOTARIZED_PERSONAL_GUARANTY_C            BOOLEAN,
  SMART_STORE_ACCESS_C                                BOOLEAN,
  SOURCE_REFERENCE_C                                  VARCHAR(150),
  STATUS_C                                            VARCHAR(765),
  SUN_POWER_UNIVERSITY_ACCESS_C                       BOOLEAN,
  TERMINATED_DATE_C                                   DATE,
  TERRITORY_ASSIGNED_C                                BOOLEAN,
  TOTAL_EXPERIENCE_IN_SOLAR_BUSINESS_C                VARCHAR(765),
  WELCOME_COMMUNICATION_CUSTOMER_TEAM_C               BOOLEAN,
  WELCOME_KIT_ORDERED_C                               BOOLEAN,
  ASSIGNED_PSR_IDS_C                                  VARCHAR(765),
  ASSIGNED_PSR_S_C                                    VARCHAR(765),
  TERRITORY_C                                         VARCHAR(300),
  THEATER_C                                           VARCHAR(765),
  RESIDENTIAL_INSTALLER_SINCE_DATE_C                  DATE,
  ORACLE_ACCOUNT_NUMBER_C                             VARCHAR(120),
  PROMOTED_AUTHORIZED_PARTNER_DATE_C                  DATE,
  OPPORTUNITY_RECIPIENT_C                             VARCHAR(18),
  SIGNED_AUTHORIZED_SR_2_PARTNER_AGREEMENT_C          BOOLEAN,
  EMAIL_C                                             VARCHAR(240),
  PARTNER_CLASS_C                                     VARCHAR(765),
  REFERRAL_PROGRAM_STATUS_C                           VARCHAR(765),
  REFERRAL_REWARD_COMPLETE_C                          BOOLEAN,
  EXECUTIVES_VIEW_ALL_OPPORTUNITIES_C                 BOOLEAN,
  ALLOW_ALL_TO_VIEW_OPPORTUNITIES_C                   BOOLEAN,
  ONLINE_ORDER_ACCESS_C                               BOOLEAN,
  ORACLE_OPERATING_UNIT_C                             VARCHAR(765),
  PRIMARY_PSR_C                                       VARCHAR(18),
  RESIDENTIAL_INSTALLER_DATE_C                        DATE,
  AUTHORIZED_SUNRISE_2_PARTNER_DATE_C                 DATE,
  APNS_C                                              VARCHAR(297),
  ACCOUNT_ACRONYM_C                                   VARCHAR(30),
  ACCOUNT_CODE_C                                      VARCHAR(60),
  ACCOUNT_POTENTIAL_C                                 VARCHAR(765),
  ACTIVE_IN_THE_FOLLOWING_U_S_STATES_C                VARCHAR(360),
  AVG_LOCATION_SIZE_K_WP_C                            VARCHAR(765),
  BANK_GUARANTEE_C                                    BOOLEAN,
  BEST_TIME_TO_CALL_C                                 VARCHAR(765),
  PRIMARY_RMA_SPECIALIST_C                            VARCHAR(18),
  CONTRACT_WITH_AN_ENERGY_OFFTAKER_C                  VARCHAR(765),
  CURRENT_ENERGY_PROJECT_DESCRIPTION_C                VARCHAR(765),
  DAS_ID_C                                            VARCHAR(180),
  D_U_N_S_C                                           VARCHAR(60),
  DO_YOU_HAVE_AN_INTERCONNECTION_AGREEMENT_C          VARCHAR(765),
  ELITE_PARTNER_SINCE_DATE_C                          DATE,
  ELITE_PARTNER_DATE_C                                DATE,
  ENTITY_FILE_NUMBER_C                                VARCHAR(45),
  ENTITY_TYPE_C                                       VARCHAR(765),
  EQUITY_INVESTOR_A_OWNERSHIP_C                       numeric,
  EQUITY_INVESTOR_A_C                                 VARCHAR(18),
  EQUITY_INVESTOR_B_OWNERSHIP_C                       numeric,
  EQUITY_INVESTOR_B_C                                 VARCHAR(18),
  INTERNAL_CLIENT_NAME_C                              VARCHAR(360),
  INVESTOR_CATEGORY_C                                 VARCHAR(765),
  KEY_VERTICAL_C                                      VARCHAR(765),
  LEAD_QUALIFICATION_NOTES_C                          VARCHAR(96000),
  MW_POTENTIAL_AVAILABLE_INCENTIVES_C                 VARCHAR(765),
  MW_POTENTIAL_NO_CURRENT_INCENTIVES_C                VARCHAR(765),
  NEAREST_CITY_OR_TOWN_C                              VARCHAR(120),
  NUMBER_OF_EMPLOYEES_C                               numeric,
  NUMBER_OF_HOMES_BUILT_YEAR_C                        numeric,
  NUMBER_OF_SITES_C                                   numeric,
  OSKEY_ID_C                                          VARCHAR(48),
  PLATINUM_ACCOUNT_C                                  BOOLEAN,
  PERCENTAGE_MULTI_FAMILY_HOMES_C                     numeric,
  PERCENTAGE_OTHER_TYPE_OF_HOMES_C                    numeric,
  PERCENTAGE_SINGLE_FAMILY_HOMES_C                    numeric,
  PINNACLE_PASSWORD_C                                 VARCHAR(75),
  PINNACLE_USERNAME_C                                 VARCHAR(75),
  OPERATIONS_COORDINATOR_C                            VARCHAR(18),
  WIND_C                                              BOOLEAN,
  IMAGE_C                                             VARCHAR(98304),
  ROOF_TYPE_C                                         VARCHAR(4099),
  RUGOSITE_C                                          VARCHAR(765),
  PRIOR_SOLAR_USER_C                                  VARCHAR(765),
  PRIOR_ENERGY_PROJECT_EXPERIENCE_C                   VARCHAR(765),
  PROJECT_ROLE_C                                      VARCHAR(765),
  PROMOTED_ELITE_PARTNER_DATE_C                       DATE,
  RSM_2_C                                             VARCHAR(18),
  REBATE_C                                            numeric,
  SERVICE_LEVEL_C                                     VARCHAR(765),
  SIGNED_AGREEMENT_C                                  VARCHAR(765),
  SIGNED_ELITE_PARTNER_AGREEMENT_C                    BOOLEAN,
  SOLAR_PROCUREMENT_STRUCTURE_C                       VARCHAR(765),
  SOLAR_C                                             BOOLEAN,
  SNOW_TOPOGRAPHY_C                                   VARCHAR(765),
  LOCATION_MATCH_STATUS_C                             VARCHAR(765),
  STATE_QUALIFICATIONS_PENDING_C                      VARCHAR(4099),
  STATE_QUALIFICATIONS_C                              VARCHAR(4099),
  CUSTOMER_PORTAL_PING_USER_C                         VARCHAR(18),
  TEST_PARTNER_FACTS_C                                VARCHAR(765),
  TOTAL_ACREAGE_OF_SITE_C                             numeric,
  CASH_PARTNER_C                                      BOOLEAN,
  UTILITY_TYPE_C                                      VARCHAR(765),
  WHICH_UTILITY_SERVICE_AREA_S_C                      VARCHAR(4099),
  WILLING_TO_SIGN_MASTER_AGREEMENT_C                  VARCHAR(765),
  LOCATION_MATCH_STATUS_TEXT_C                        VARCHAR(765),
  SUN_POWER_PRODUCTS_AND_SERVICES_CONTACT_C           VARCHAR(765),
  NOTES_C                                             VARCHAR(765),
  CRSM_C                                              VARCHAR(18),
  SECOND_LEVEL_SIC_NAME_C                             VARCHAR(750),
  ACCOUNT_STATUS_C                                    VARCHAR(765),
  AREAS_OF_EXPERTISE_C                                VARCHAR(4099),
  BUSINESS_UNIT_C                                     VARCHAR(765),
  CONTACT_NAME_C                                      VARCHAR(750),
  FIRST_LEVEL_SIC_NAME_C                              VARCHAR(750),
  HD_LEAD_STATUS_C                                    VARCHAR(765),
  LEAD_APPROVAL_C                                     VARCHAR(765),
  NUMBER_OF_ACTIVE_SITES_C                            numeric,
  NUMBER_OF_INACTIVE_SITES_C                          numeric,
  REASON_FOR_INACTIVE_C                               VARCHAR(765),
  SPWR_INDUSTRY_TYPE_C                                VARCHAR(765),
  SPWR_RELATIONSHIP_TYPE_C                            VARCHAR(4099),
  THIRD_LEVEL_SIC_NAME_C                              VARCHAR(750),
  X_ACCOUNT_OWNER_C                                   VARCHAR(18),
  BUSINESS_UNIT_1_C                                   VARCHAR(765),
  LOYALTY_PARTNER_C                                   BOOLEAN,
  MEGAWATT_C                                          VARCHAR(48),
  SAME_AS_CASH_PROGRAM_PARTNER_C                      BOOLEAN,
  LEASE_PROGRAM_PARTNER_C                             BOOLEAN,
  WOMAN_OWNED_BUSINESS_C                              BOOLEAN,
  UNDERREPRESENTED_MINORITY_OWNED_BUSINESS_C          BOOLEAN,
  CERTIFICATION_NUMBER_FOR_WOMAN_OWNED_C              VARCHAR(150),
  CERTIFICATION_NUMBER_FOR_MINORITY_OWNED_C           VARCHAR(150),
  CERTIFYING_AGENCY_FOR_WOMAN_OWNED_C                 VARCHAR(300),
  CERTIFYING_AGENCY_FOR_MINORITY_OWNED_C              VARCHAR(300),
  FACILITY_ADDRESS_C                                  VARCHAR(765),
  FACILITY_ADDRESS_2_C                                VARCHAR(765),
  FACILITY_CITY_C                                     VARCHAR(765),
  FACILITY_STATE_C                                    VARCHAR(765),
  FACILITY_ZIP_C                                      VARCHAR(180),
  AVAILABLE_CREDIT_C                                  numeric(10, 2),
  OPEN_BALANCE_C                                      numeric(10, 2),
  REQUEST_CONNECTION_CODE_C                           VARCHAR(45),
  REQUEST_CONNECTION_TITLE_OWNER_1_C                  VARCHAR(297),
  INTERCONNECTION_REQUEST_FILED_C                     DATE,
  INTERCONNECTION_AGREEMENT_EXECUTED_C                DATE,
  PHASE_I_STUDY_RECEIVED_C                            DATE,
  PHASE_I_STUDY_ACCEPTED_C                            DATE,
  EXPECTED_DATE_CONNECTION_BUILDING_C                 DATE,
  ACCEPTING_PHASE_I_VALID_UNTIL_C                     DATE,
  INTERCONNECTION_APPLICATION_SUBMITTED_C             DATE,
  INTERCONNECTION_APPROVED_C                          DATE,
  EXPECTED_DATE_SUBSTATION_BUILDING_C                 DATE,
  TRANSMISSION_CAPACITY_USED_C                        numeric,
  TRANSMISSION_CAPACITY_C                             numeric,
  AMOUNT_PAST_DUE_C                                   numeric,
  CONTACT_LANGUAGE_C                                  VARCHAR(765),
  HOOVERS_ID_C                                        VARCHAR(60),
  MULTI_QUARTER_CONTRACT_PARTICIPANT_C                BOOLEAN,
  SEND_PDF_NOTIFICATION_C                             BOOLEAN,
  SUBSCRIPTION_DATE_C                                 TIMESTAMPTZ,
  ADDITIONAL_OPPORTUNITY_EMAIL_RECIPIENT_C            VARCHAR(240),
  ONLINE_ORDER_ACCESS_DATE_C                          DATE,
  ORACLE_ACCOUNT_CREATED_DATE_C                       DATE,
  LOCATION_C                                          VARCHAR(18),
  SMS_SITE_ID_C                                       VARCHAR(60),
  PE_GU_START_DATE_C                                  DATE,
  EXPECTED_PERFORMANCE_YEAR_1_K_WH_C                  numeric,
  PE_GU_PROGRAM_C                                     VARCHAR(765),
  MODULE_CATEGORY_C                                   VARCHAR(765),
  TILT_C                                              numeric,
  AZIMUTH_DEGREES_C                                   numeric,
  GENERAL_DE_RATE_PERCENT_C                           numeric,
  IS_PREMIER_CANDIDATE_C                              BOOLEAN,
  MQC_1_MULTI_QUARTER_CONTRACT_PARTICIPANT_C          BOOLEAN,
  MQC_2_MULTI_QUARTER_CONTRACT_PARTICIPANT_C          BOOLEAN,
  CSAT_CYCLE_CODE_C                                   VARCHAR(765),
  CAN_SELL_SUN_POWER_20_YR_LOAN_C                     BOOLEAN,
  MONITOR_PROMOTION_PARTICIPANT_C                     BOOLEAN,
  STUDY_DEPOSIT_AMT_C                                 numeric(18, 2),
  STUDY_DEPOSIT_REMAINING_C                           numeric(18, 2),
  SITE_CONTROL_AMOUNT_C                               numeric(18, 2),
  SITE_CONTROL_REMAINING_C                            numeric(18, 2),
  EUC_C                                               BOOLEAN,
  ACH_OPT_IN_C                                        BOOLEAN,
  NH_SSE_TYPE_C                                       VARCHAR(4099),
  WARRANTY_SIGNED_ITALY_C                             BOOLEAN,
  CONTRACTORS_LICENSE_C                               VARCHAR(150),
  INSURANCE_CARRIER_C                                 VARCHAR(150),
  INSURANCE_POLICY_C                                  VARCHAR(150),
  REQUESTED_CREDIT_AMOUNT_C                           numeric(18),
  CREDIT_AMOUNT_APPROVED_C                            numeric(18),
  CLUSTER_STATUS_C                                    VARCHAR(98304),
  CREDIT_CHECK_REQUIRED_C                             VARCHAR(765),
  ARE_RECENT_FINANCIALS_OR_LINK_ATTACHED_C            VARCHAR(765),
  NET_TERMS_C                                         VARCHAR(297),
  PARTNER_PORTAL_REGISTRATION_C                       BOOLEAN,
  LEASE_C                                             BOOLEAN,
  LEASE_2_0_PROGRAM_PARTNER_C                         BOOLEAN,
  ORACLE_VENDOR_NUMBER_C                              VARCHAR(90),
  ORACLE_CUSTOMER_CLASSIFICATION_C                    VARCHAR(765),
  ORACLE_VENDOR_SITE_CODE_C                           VARCHAR(90),
  ORACLE_WAREHOUSE_C                                  VARCHAR(765),
  ORACLE_ACCOUNT_TYPE_C                               VARCHAR(765),
  ORACLE_ORDER_TYPE_C                                 VARCHAR(765),
  ORACLE_SALES_CHANNEL_C                              VARCHAR(765),
  ORACLE_COUNTY_C                                     VARCHAR(765),
  RENEWAL_COMMERCIAL_10_C                             VARCHAR(150),
  RENEWAL_RESIDENTIAL_10_C                            VARCHAR(150),
  LEASE_CUSTOMER_C                                    BOOLEAN,
  LEASE_ORDER_PLACED_C                                BOOLEAN,
  ORACLE_PAYMENT_TERMS_C                              VARCHAR(765),
  ORACLE_RELATED_ACCOUNT_C                            VARCHAR(18),
  CUSTOMER_INTERFACE_ERROR_C                          VARCHAR(6000),
  CUSTOMER_INTERFACE_STATUS_C                         BOOLEAN,
  TEAM_LEAD_C                                         VARCHAR(18),
  ORACLE_RELATED_ACCOUNT_BILL_TO_C                    VARCHAR(765),
  ORACLE_RELATED_ACCOUNT_SHIPTO_C                     VARCHAR(765),
  ORACLE_RELATED_ACCOUNT_RECIPROCAL_C                 VARCHAR(765),
  ORACLE_SHIPPING_COUNTY_C                            VARCHAR(765),
  COM_OPP_RECIPIENT_PRIMARY_C                         VARCHAR(18),
  FORD_PROGRAM_PARTNER_C                              BOOLEAN,
  PENDING_LITIGATION_C                                BOOLEAN,
  ORACLE_VENDOR_EMAIL_C                               VARCHAR(240),
  ACCOUNT_CATEGORY_C                                  VARCHAR(765),
  AREA_SALES_MANAGER_C                                VARCHAR(18),
  NEW_TYPE_REQUEST_C                                  VARCHAR(765),
  NEW_TYPE_REQUEST_STATUS_C                           VARCHAR(765),
  ADMIN_NOTES_C                                       VARCHAR(297),
  CPR_ID_C                                            VARCHAR(60),
  CPR_COMPANY_ID_C                                    VARCHAR(120),
  CREDIT_CHECK_APPROVAL_DATE_C                        DATE,
  CREDIT_CHECK_STATUS_C                               VARCHAR(765),
  CREDIT_CHECK_SUBMISSION_DATE_C                      DATE,
  CREDIT_CHECK_PASSED_C                               BOOLEAN,
  LEASE_DOC_CREATED_C                                 BOOLEAN,
  ORACLE_VENDOR_EMAIL_FIELD_VALUE_C                   VARCHAR(240),
  PARTNER_ACCOUNT_C                                   VARCHAR(18),
  QUOTE_TYPE_IS_LEASE_C                               BOOLEAN,
  CREDIT_CHECK_ERROR_MESSAGE_C                        VARCHAR(765),
  DEALER_LOCATOR_PHONE_C                              VARCHAR(120),
  VENDOR_SUBORDINATE_C                                BOOLEAN,
  CONTACT_LAST_MODIFIED_DATE_C                        TIMESTAMPTZ,
  DEALER_LOCATOR_OPT_OUT_C                            BOOLEAN,
  MULTIPLE_METERS_C                                   BOOLEAN,
  CONTRACTORS_LIC_EXPIRY_C                            DATE,
  INSURANCE_POL_EXPIRY_C                              DATE,
  MARKETING_ZONE_C                                    VARCHAR(765),
  SUN_POWER_DEALER_WEB_PAGE_URL_C                     VARCHAR(765),
  INVOICE_DOCUMENT_EMAIL_C                            VARCHAR(240),
  XXXXX_C                                             VARCHAR(210000),
  GEO_LATITUDE_S                                      numeric,
  GEO_LONGITUDE_S                                     numeric,
  LAT_C                                               numeric,
  LEAD_FLOW_OPT_OUT_C                                 BOOLEAN,
  LOG_C                                               numeric,
  OPPORTUNITY_CLOSE_C                                 numeric,
  COMMERCIAL_PSR_C                                    VARCHAR(18),
  BUSINESS_HOURS_C                                    VARCHAR(18),
  REVIEW_PROPOSAL_DESIGN_C                            BOOLEAN,
  CONTACT_SLA_C                                       numeric,
  DEALER_SCORE_PERCENT_C                              numeric,
  LEASE_STATUS_EMAIL_OPT_OUT_C                        VARCHAR(765),
  VERTICAL_C                                          VARCHAR(765),
  SUB_VERTICAL_C                                      VARCHAR(765),
  RATING_COMMENTS_C                                   VARCHAR(98304),
  SALES_TAX_RATE_C                                    numeric,
  FILING_STATUS_C                                     VARCHAR(765),
  INCOME_C                                            numeric(18),
  CREDIT_CUSTOMER_ID_C                                VARCHAR(108),
  CREDIT_CUSTOMER_NUMBER_C                            VARCHAR(108),
  CURRENT_RATE_C                                      VARCHAR(765),
  DEFAULT_IMAGE_C                                     BOOLEAN,
  ON_MARKUP_ONLY_C                                    BOOLEAN,
  GENERAL_LIABILITY_EXP_C                             DATE,
  AUTOMOTIVE_EXP_C                                    DATE,
  BUILDERS_RISK_EXP_C                                 DATE,
  WORKERS_COMP_EXP_C                                  DATE,
  DEALER_SCORE_SUMMARY_C                              VARCHAR(98304),
  DEALER_SCORE_TOTAL_C                                numeric,
  GEOLOCATION_LATITUDE_S                              numeric,
  GEOLOCATION_LONGITUDE_S                             numeric,
  IS_ADDRESS_UPDATED_C                                BOOLEAN,
  OPP_CONVERT_RATE_C                                  numeric,
  RSM_DISCRETIONARY_ADJ_C                             numeric,
  SFDC_TIMELY_UPDATES_C                               numeric,
  ALTITUDE_C                                          VARCHAR(765),
  ANNUAL_ELECTRICITY_C                                numeric(18),
  ANNUAL_ENERGY_CONSUMPTION_KWH_C                     numeric,
  APPROVAL_APPROVED_C                                 DATE,
  CLOSE_DATE_C                                        DATE,
  CUSTOMER_ONBOARDING_STATUS_C                        VARCHAR(765),
  DISTANCE_FROM_OCEAN_C                               VARCHAR(765),
  INTERFACE_STATUS_C                                  VARCHAR(765),
  INVALID_DEPARTMENT_C                                BOOLEAN,
  IS_PARTY_TRULY_HOMEOWNER_C                          VARCHAR(765),
  LAST_NAME_C                                         VARCHAR(90),
  MAXIMUM_CELL_TEMPERATURE_C                          VARCHAR(765),
  MINIMUM_CELL_TEMPERATURE_C                          VARCHAR(765),
  ORIGINATION_APPROVED_C                              DATE,
  PROTECTED_AREA_C                                    VARCHAR(765),
  RUN_ORIGINATION_DOCS_TRIGGER_C                      BOOLEAN,
  STAGE_C                                             VARCHAR(765),
  UCC_FILED_DATE_C                                    DATE,
  PORTAL_PASSWORD_C                                   VARCHAR(525),
  PORTAL_URL_C                                        VARCHAR(765),
  CHATTER_GROUP_NAME_C                                VARCHAR(150),
  ADMIRAL_PROGRAM_PARTNER_C                           BOOLEAN,
  ADMIRAL_PROGRAM_TYPE_C                              VARCHAR(4099),
  BUSINESS_FUNCTION_C                                 VARCHAR(4099),
  CERTIFIED_C                                         BOOLEAN,
  FEE_CAL_LATITUDE_C                                  VARCHAR(60),
  FEE_CAL_LONGITUDE_C                                 VARCHAR(60),
  SPECIALIZED_INSTALLER_C                             VARCHAR(765),
  SPECIALIZED_SELLER_C                                VARCHAR(765),
  COUNTRIES_OF_INTEREST_C                             VARCHAR(4099),
  PARTNER_OPT_OUT_OK_TO_SHIP_COMM_C                   BOOLEAN,
  NAME_OF_PAST_DEALS_C                                VARCHAR(98304),
  TYPE_OF_CAPITAL_C                                   VARCHAR(4099),
  HQ_DUNS_NUMBER_C                                    VARCHAR(765),
  LOCATION_OWNERSHIP_C                                VARCHAR(765),
  LOCATION_TYPE_C                                     VARCHAR(765),
  REPORTING_LOCATIONS_C                               numeric,
  SITE_NO_EMPLOYEES_C                                 numeric,
  PORTAL_USERNAME_C                                   VARCHAR(765),
  REASON_FOR_TERMINATION_C                            VARCHAR(4099),
  MILESTONE_C                                         VARCHAR(765),
  SSO_USER_C                                          VARCHAR(18),
  AVAILABLE_LENDER_C                                  VARCHAR(4099),
  DSE_CUSTOMER_TYPE_C                                 VARCHAR(765),
  DSE_IS_CUSTOMER_C                                   BOOLEAN,
  DSE_SITE_C                                          VARCHAR(765),
  ANNUAL_NPS_REPORT_LINK_C                            VARCHAR(765),
  PARTNER_ACCESS_ID_C                                 VARCHAR(120),
  IS_SPECTRUM_PARTNER_C                               BOOLEAN,
  LAST_ASSIGNED_DATE_C                                DATE,
  LEAD_ASSIGNMENT_COUNT_C                             numeric,
  LEAD_PRIORITY_MAXIMUM_C                             numeric,
  LEAD_PRIORITY_MINIMUM_C                             numeric,
  PRIORITY_ASSIGNMENT_C                               VARCHAR(765),
  OPTED_OUT_OF_OK_TO_SHIP_ONCE_C                      BOOLEAN,
  PARTNER_OPT_OUT_OK_TO_SHIP_C                        BOOLEAN,
  SUNRISE_C                                           VARCHAR(765),
  EXTERNAL_DESIGN_PROJECT_ID_C                        VARCHAR(765),
  DEFAULT_DEALER_WAREHOUSE_SHIPPING_SITE_C            VARCHAR(18),
  SHIPPING_SITE_C                                     VARCHAR(18),
  ORIGINATION_FEE_PARTICIPANT_C                       BOOLEAN,
  RESIDENTIAL_FIELD_SUPERVISOR_C                      VARCHAR(18),
  RLCPA_NOTES_C                                       VARCHAR(765),
  S_P_500_C                                           VARCHAR(240),
  PHONE_US_PREFIX_C                                   VARCHAR(120),
  LOCATION_SIZE_C                                     numeric,
  BUSINESS_REGISTRATION_C                             VARCHAR(18),
  FORTUNE_1000_RANKING_C                              numeric,
  CO_BRAND_PARTNER_C                                  VARCHAR(300),
  LOAN_PARTNER_C                                      BOOLEAN,
  REFERENCE_SHEET_C                                   VARCHAR(30000),
  SPECIAL_PROGRAMS_C                                  VARCHAR(4099),
  F_500_LIST_C                                        VARCHAR(765),
  ERS_ENROLLMENT_DATE_C                               DATE,
  MONITORING_COMMISSIONING_DATE_C                     DATE,
  TOTAL_ENERGY_PRODUCED_C                             numeric,
  TOTAL_ENERGY_USED_C                                 numeric,
  CHANNEL_C                                           VARCHAR(765),
  SECTOR_CASH_C                                       VARCHAR(4099),
  SECTOR_LEASE_C                                      VARCHAR(4099),
  SECTOR_LOAN_C                                       VARCHAR(4099),
  VAT_NUMBER_C                                        VARCHAR(48),
  ENGAGEMENT_PRIORITY_C                               VARCHAR(765),
  PAIRED_DESIGN_EXISTS_C                              BOOLEAN,
  PARTNER_LOGO_URL_C                                  VARCHAR(150),
  SUB_REGION_C                                        VARCHAR(765),
  I_SUPPLIER_C                                        BOOLEAN,
  DESIGN_PROJECT_ID_C                                 VARCHAR(765),
  DESIGN_TOOL_ORGANIZATION_ID_C                       VARCHAR(765),
  SEGMENT_C                                           VARCHAR(765),
  CUSTOMER_GROUP_C                                    VARCHAR(90),
  SUB_CONTRACTOR_C                                    VARCHAR(765),
  BACKGROUND_CHECK_C                                  BOOLEAN,
  ENGAGIO_ENGAGED_PEOPLE_C                            numeric,
  ENGAGIO_ENGAGEMENT_MINUTES_LAST_3_MONTHS_C          numeric,
  ENGAGIO_ENGAGEMENT_MINUTES_LAST_7_DAYS_C            numeric,
  ENGAGIO_FIRST_ENGAGEMENT_DATE_C                     TIMESTAMPTZ,
  ENGAGIO_MQADATE_C                                   TIMESTAMPTZ,
  ENGAGIO_STATUS_C                                    VARCHAR(120),
  ENGAGIO_WEB_VISITS_LAST_3_MONTHS_C                  numeric,
  GENABILITY_ACCOUNT_ID_C                             VARCHAR(765),
  GOOGLE_PIN_ADJUSTED_C                               BOOLEAN,
  NEW_PARTNER_AGREEMENT_2017_DATE_C                   DATE,
  SINGED_NEW_PARTNER_AGREEMENT_2017_C                 BOOLEAN,
  OPT_OUT_PREFERENCE_C                                VARCHAR(765),
  SPWR_CASH_PARTNER_C                                 BOOLEAN,
  SECTOR_SPWR_CASH_C                                  VARCHAR(4099),
  COMMERCIAL_DEALER_TIER_C                            VARCHAR(765),
  AES_SYSTEM_ID_C                                     VARCHAR(765),
  PURGE_BY_C                                          VARCHAR(18),
  PURGE_REASON_C                                      VARCHAR(765),
  PURGE_RECORD_C                                      BOOLEAN,
  LOYALTY_TIER_C                                      VARCHAR(765),
  RETROFIT_TERRITORY_C                                VARCHAR(765),
  CALL_ATTEMPT_C                                      numeric,
  SCHEDULED_CALL_DATE_C                               DATE,
  MY_SUN_POWER_FEATURES_C                             VARCHAR(4099),
  FUSION_CUSTOMER_ID_C                                VARCHAR(45),
  FUSION_CUSTOMER_PARTY_ID_C                          VARCHAR(45),
  FUSION_VENDOR_ID_C                                  VARCHAR(384),
  FUSION_VENDOR_SITE_ID_C                             VARCHAR(384),
  CVAR_LEAD_FLOW_OPT_OUT_C                            BOOLEAN,
  PARTNER_RECORD_TYPE_C                               VARCHAR(150),
  PARTNER_STATUS_C                                    VARCHAR(765),
  ALLOWED_FINANCE_TYPE_FOR_STORAGE_C                  VARCHAR(4099),
  FINANCE_ACCOUNTING_CONTACT_PERSON_C                 VARCHAR(765),
  PHONE_CALL_OTHER_THAN_LEAD_CONTACT_C                VARCHAR(4099),
  PHONE_NUMBER_C                                      VARCHAR(120),
  PHYSICAL_MEETING_VALIDATED_BY_SALES_C               BOOLEAN,
  WEBSITE_VERIFIED_C                                  VARCHAR(765),
  ORACLE_VENDOR_NAME_C                                VARCHAR(765),
  DEALER_COUNTERSIGN_CONTACT_C                        VARCHAR(18),
  REMOTE_HOME_SURVEY_ACTIVATION_DATE_C                DATE,
  REMOTE_HOME_SURVEY_STATUS_C                         VARCHAR(765),
  DEAL_CLOSE_STATUS_C                                 VARCHAR(765),
  AHJNAME_C                                           VARCHAR(18),
  APPOINTMENT_REMINDER_OPT_OUT_C                      BOOLEAN,
  INVITATION_SENT_DATE_TIME_C                         TIMESTAMPTZ,
  LENDER_OVERRIDE_C                                   VARCHAR(765),
  LOAN_PAYMENT_CLASSIFICATION_C                       VARCHAR(765),
  CONNECTED_SOLUTIONS_PARTICIPANT_C                   VARCHAR(765),
  DEALER_HIC_C                                        BOOLEAN,
  PPA_PARTNER_C                                       BOOLEAN,
  SECTOR_PPA_C                                        VARCHAR(765),
  SPD_ECEMAIL_C                                       VARCHAR(240),
  ADVOCATE_C                                          VARCHAR(18),
  FIELD_APPLICATIONS_ENGINEER_C                       VARCHAR(18),
  RINGDNA_HAS_OPTED_OUT_OF_SMS_2_C                    BOOLEAN,
  INSTALL_TRACKER_ACTIVATION_DATE_C                   TIMESTAMPTZ,
  OC_C                                                VARCHAR(18),
  PDM_C                                               VARCHAR(18),
  RINGDNA_100_ACTIVE_C                                VARCHAR(765),
  RINGDNA_100_CALL_ATTEMPTS_C                         numeric,
  RINGDNA_100_CUSTOMER_PRIORITY_C                     VARCHAR(765),
  RINGDNA_100_EMAIL_ATTEMPTS_C                        numeric,
  RINGDNA_100_FIRST_INBOUND_CALL_C                    TIMESTAMPTZ,
  RINGDNA_100_FIRST_OUTBOUND_CALL_C                   TIMESTAMPTZ,
  RINGDNA_100_LAST_EMAIL_ATTEMPT_C                    TIMESTAMPTZ,
  RINGDNA_100_LAST_INBOUND_CALL_C                     TIMESTAMPTZ,
  RINGDNA_100_LAST_OUTBOUND_CALL_C                    TIMESTAMPTZ,
  RINGDNA_100_NUMBEROF_LOCATIONS_C                    numeric,
  RINGDNA_100_RESPONSE_TYPE_C                         VARCHAR(765),
  RINGDNA_100_RING_DNA_CONTEXT_C                      BOOLEAN,
  RINGDNA_100_SLAEXPIRATION_DATE_C                    DATE,
  RINGDNA_100_SLASERIAL_NUMBER_C                      VARCHAR(30),
  RINGDNA_100_SLA_C                                   VARCHAR(765),
  RINGDNA_100_TIME_TO_FIRST_DIAL_MINUTES_C            numeric,
  RINGDNA_100_TIME_TO_FIRST_RESPONSE_C                numeric,
  RINGDNA_100_UPSELL_OPPORTUNITY_C                    VARCHAR(765),
  MESSAGE_UNREAD_C                                    BOOLEAN,
  EC_INTRO_SMS_SENT_C                                 BOOLEAN,
  SERVICES_OFFERED_C                                  VARCHAR(4099),
  DLL_CREDIT_C                                        BOOLEAN,
  AGREEMENT_ALIGNED_C                                 BOOLEAN,
  LAST_CHECK_DATE_C                                   DATE,
  BEST_TIME_TO_CALL_PC                                VARCHAR(765),
  INTEGRATION_ID_PC                                   VARCHAR(60),
  IS_ENGINEER_PC                                      BOOLEAN,
  MARKETING_OPT_IN_PC                                 BOOLEAN,
  OVERRIDE_DUPLICATE_CHECK_PC                         BOOLEAN,
  TERMINATED_PC                                       BOOLEAN,
  SALES_COMMUNICATIONS_PC                             BOOLEAN,
  COUNTRY_DOMAIN_PC                                   VARCHAR(765),
  LMS_ROLE_PC                                         VARCHAR(765),
  SUBSCRIPTION_PC                                     VARCHAR(4099),
  PARTNER_PORTAL_USER_PC                              VARCHAR(18),
  PROFILE_TEMP_PC                                     VARCHAR(765),
  ROLE_TEMP_PC                                        VARCHAR(765),
  HIRE_DATE_PC                                        DATE,
  BULLETINS_OPT_OUT_PC                                BOOLEAN,
  REFERRAL_PROGRAM_STATUS_PC                          VARCHAR(765),
  PROMO_CODE_PC                                       VARCHAR(240),
  AUTHORIZED_TO_ORDER_PC                              BOOLEAN,
  CONTACT_METHOD_PC                                   VARCHAR(765),
  DIRECT_MARKETING_OPT_OUT_PC                         BOOLEAN,
  DO_NOT_CALL_OPT_OUT_PC                              BOOLEAN,
  DO_NOT_MARKET_TO_BECAUSE_PC                         VARCHAR(765),
  NEWSLETTER_OPT_OUT_PC                               BOOLEAN,
  PHONE_DIRECT_PC                                     VARCHAR(120),
  SEMINAR_EVENT_OPT_OUT_PC                            BOOLEAN,
  CSAT_LAST_REPONSE_DATE_PC                           TIMESTAMPTZ,
  CSAT_NPS_SCORE_PC                                   numeric,
  CSAT_RANDOM_DISTRIBUTION_PC                         numeric,
  FUSION_CONTACT_ID_PC                                VARCHAR(45),
  CONTACT_LANGUAGE_PC                                 VARCHAR(765),
  D_U_N_S_PC                                          VARCHAR(60),
  PARTNER_PORTAL_REGISTRATION_PC                      BOOLEAN,
  ORACLE_CONTACT_ID_PC                                VARCHAR(765),
  FUNCTION_PC                                         VARCHAR(765),
  MANAGEMENT_LEVEL_PC                                 VARCHAR(765),
  ROLE_PC                                             VARCHAR(765),
  ELOQUA_LEAD_SCORE_IMPLICIT_PC                       numeric,
  ELOQUA_LEAD_SCORE_EXPLICIT_PC                       numeric,
  ELOQUA_LEAD_RATING_COMBINED_PC                      VARCHAR(6),
  REFERRER_PC                                         BOOLEAN,
  REFERRER_ACCOUNT_PC                                 VARCHAR(18),
  CPR_ID_PC                                           VARCHAR(60),
  INCLUDE_IN_LEASE_DOC_PC                             BOOLEAN,
  LEASE_DOC_CREATION_ALLOWED_PC                       BOOLEAN,
  PRIMARY_PC                                          BOOLEAN,
  IS_UPDATED_FROM_ACCOUNT_PC                          BOOLEAN,
  SPWR_REFERENCE_PC                                   VARCHAR(765),
  DATE_REFERENCE_LAST_UPDATED_PC                      DATE,
  REFERENCE_SHEET_PC                                  VARCHAR(765),
  REFERENCE_RATING_PC                                 VARCHAR(765),
  ALLIANCE_CONTACT_PC                                 BOOLEAN,
  LEASE_COURSE_STATUS_PC                              VARCHAR(4099),
  CREDIT_CUSTOMER_ID_PC                               VARCHAR(108),
  CREDIT_CUSTOMER_NUMBER_PC                           VARCHAR(108),
  CONTACT_STATUS_PC                                   VARCHAR(765),
  ISSUE_RESOLUTION_SURVEY_OPT_OUT_PC                  BOOLEAN,
  BIRTH_COUNTRY_PC                                    VARCHAR(72),
  INTERFACE_MESSAGE_PC                                VARCHAR(6000),
  INTERFACE_STATUS_PC                                 VARCHAR(765),
  MARITAL_STATUS_DEL_PC                               VARCHAR(765),
  PROFESSION_PC                                       VARCHAR(72),
  IS_OVER_21_YEARS_OF_AGE_PC                          BOOLEAN,
  CUSTOMER_PORTAL_ACTIVATION_LINK_PC                  VARCHAR(765),
  EMAIL_OPT_OUT_PC                                    BOOLEAN,
  DO_NOT_SYNCH_TO_ELOQUA_PC                           BOOLEAN,
  PHONE_US_PREFIX_PC                                  VARCHAR(120),
  PHONE_UNFORMATTED_PC                                VARCHAR(75),
  UTILITY_ACCOUNT_HOLDER_PC                           BOOLEAN,
  DELEGATION_PC                                       VARCHAR(18),
  MOBILE_US_PREFIX_PC                                 VARCHAR(120),
  LEASE_TRANSFER_WK_PC                                BOOLEAN,
  FUSION_CONTACT_PARTY_ID_PC                          VARCHAR(45),
  E_INVOICE_VALID_RECIPIENT_PC                        BOOLEAN,
  ELOQUA_CONTACT_ID_PC                                VARCHAR(765),
  ORACLE_CONTACT_STATUS_PC                            VARCHAR(765),
  PREFERRED_LANGUAGE_CODE_PC                          VARCHAR(765),
  ENGAGIO_DEPARTMENT_PC                               VARCHAR(384),
  ENGAGIO_ENGAGEMENT_MINUTES_LAST_3_MONTHS_PC         numeric,
  ENGAGIO_ENGAGEMENT_MINUTES_LAST_7_DAYS_PC           numeric,
  ENGAGIO_FIRST_ENGAGEMENT_DATE_PC                    TIMESTAMPTZ,
  ENGAGIO_ROLE_PC                                     VARCHAR(384),
  CAMPAIGN_PC                                         VARCHAR(18),
  ISSUE_RESOLUTION_SURVEY_SENT_DATE_PC                DATE,
  SATISFACTION_SURVEY_OPT_IN_PC                       BOOLEAN,
  TEXT_MESSAGE_OPT_OUT_PC                             BOOLEAN,
  ORACLE_UPDATE_PC                                    BOOLEAN,
  CUSTOMER_PORTAL_ACTIVATION_LINK_LONG_PC             VARCHAR(98304),
  AUTHORIZED_TO_PAY_PC                                BOOLEAN,
  DO_NOT_SELL_MY_DATA_PC                              BOOLEAN,
  SPD_ECEMAIL_PC                                      VARCHAR(240),
  RINGDNA_HAS_OPTED_OUT_OF_SMS_PC                     BOOLEAN,
  RINGDNA_100_CALL_ATTEMPTS_PC                        numeric,
  RINGDNA_100_EMAIL_ATTEMPTS_PC                       numeric,
  RINGDNA_100_FIRST_INBOUND_CALL_PC                   TIMESTAMPTZ,
  RINGDNA_100_FIRST_INBOUND_MESSAGE_PC                TIMESTAMPTZ,
  RINGDNA_100_FIRST_OUTBOUND_CALL_PC                  TIMESTAMPTZ,
  RINGDNA_100_FIRST_OUTBOUND_MESSAGE_PC               TIMESTAMPTZ,
  RINGDNA_100_LANGUAGES_PC                            VARCHAR(300),
  RINGDNA_100_LAST_EMAIL_ATTEMPT_PC                   TIMESTAMPTZ,
  RINGDNA_100_LAST_INBOUND_CALL_PC                    TIMESTAMPTZ,
  RINGDNA_100_LAST_INBOUND_MESSAGE_PC                 TIMESTAMPTZ,
  RINGDNA_100_LAST_OUTBOUND_CALL_PC                   TIMESTAMPTZ,
  RINGDNA_100_LAST_OUTBOUND_MESSAGE_PC                TIMESTAMPTZ,
  RINGDNA_100_LEVEL_PC                                VARCHAR(765),
  RINGDNA_100_MESSAGE_ATTEMPTS_PC                     numeric,
  RINGDNA_100_RESPONSE_TYPE_PC                        VARCHAR(765),
  RINGDNA_100_RING_DNA_CONTEXT_PC                     BOOLEAN,
  RINGDNA_100_TIME_TO_FIRST_DIAL_MINUTES_PC           numeric,
  RINGDNA_100_TIME_TO_FIRST_RESPONSE_PC               numeric,
  _FIVETRAN_SYNCED                                    TIMESTAMPTZ,
  LAST_MODIFIED_BY_PC_C                               VARCHAR(765),
  HOMEOWNER_PREFERRED_NAME_C                          VARCHAR(765),
  RINGDNA_100_LATEST_DISPOSITION_PC                   VARCHAR(765),
  LEGAL_BUSINESS_NAME_C                               VARCHAR(765),
  _FIVETRAN_DELETED                                   BOOLEAN,
  ACCOUNT_FLAG_COMMENT_C                              VARCHAR(30000),
  ACCOUNT_FLAG_C                                      VARCHAR(4099),
  OPERATING_HOURS_ID                                  VARCHAR(18),
  CONSULTATION_CALENDAR_LINK_C                        VARCHAR(765),
  SMS_MANAGER_PC                                      VARCHAR(18),
  PLACEKEY_ID_C                                       VARCHAR(765),
  AD_PROJECT_ID_C                                     VARCHAR(765),
  ORTOO_QRA_Q_ASSIGN_LAST_ASSIGNED_DATE_C             TIMESTAMPTZ,
  ORTOO_QRA_ASSIGNED_FROM_GROUP_PC                    VARCHAR(54),
  ORTOO_QRA_ASSIGNED_FROM_QUEUE_C                     VARCHAR(54),
  ORTOO_QRA_Q_ASSIGN_LAST_ASSIGNED_DATE_PC            TIMESTAMPTZ,
  ORTOO_QRA_ASSIGNED_FROM_QUEUE_PC                    VARCHAR(54),
  ORTOO_QRA_ASSIGNED_FROM_GROUP_C                     VARCHAR(54),
  NET_SETTING_C                                       BOOLEAN,
  EXTERNAL_INSTALLING_PARTNER_PHONE_C                 VARCHAR(120),
  PARTNER_CUSTOMER_ID_C                               VARCHAR(150),
  EXTERNAL_PARTNER_NAME_C                             VARCHAR(765),
  EXTERNAL_INSTALLING_PARTNER_EMAIL_C                 VARCHAR(240),
  PARTNER_SITE_ID_C                                   VARCHAR(150),
  EXTERNAL_INSTALLING_PARTNER_NAME_C                  VARCHAR(450),
  PARTNER_ORDER_ID_C                                  VARCHAR(150),
  PARTNER_CONTACT_ID_PC                               VARCHAR(150),
  TWILIO_SF_LAST_MESSAGE_STATUS_DATE_PC               TIMESTAMPTZ,
  TWILIO_SF_LAST_MESSAGE_STATUS_PC                    VARCHAR(765),
  FSL_VERIFICATION_CODE_PC                            VARCHAR(765),
  ACTIVITY_METRIC_ID                                  VARCHAR(18),
  ACTIVITY_METRIC_ROLLUP_ID                           VARCHAR(18),
  SR_NUMBER_FOR_SSS_PC                                VARCHAR(765),
  IS_PRIORITY_RECORD                                  BOOLEAN,
  SEED_STOCK_RMA_PROGRAM_C                            BOOLEAN,
  PRE_POSITIONED_INVENTORY_PROGRAM_C                  BOOLEAN,
  SPRI_LOCATION_PC                                    VARCHAR(4099),
  TECHNICAL_PROJECT_MANAGER_C                         VARCHAR(18),
  ND_OPERATIONS_SPECIALIST_C                          VARCHAR(18),
  CUSTOMER_ACCOUNT_MANAGER_C                          VARCHAR(18),
  OPERATIONS_MANAGER_C                                VARCHAR(18),
  INSTALLATION_PARTNER_MANAGER_C                      VARCHAR(18),
  PERSON_HAS_OPTED_OUT_OF_FAX                         BOOLEAN,
  RDNACADENCE_LANGUAGES_PC                            VARCHAR(300),
  RDNACADENCE_IS_ACTIVATED_PC                         BOOLEAN,
  RDNACADENCE_NUMBER_OF_SEQUENCE_EMAILS_TO_OPENED_PC  numeric,
  RINGDNA_SLASERIAL_NUMBER_C                          VARCHAR(30),
  RINGDNA_CUSTOMER_PRIORITY_C                         VARCHAR(765),
  RDNACADENCE_NUMBER_OF_DEFERRED_SEQUENCE_ACTIONS_PC  numeric,
  RDNACADENCE_REPLIED_TO_SEQUENCE_EMAIL_PC            BOOLEAN,
  RDNACADENCE_NUMBER_OF_SEQUENCE_EMAILS_TO_REPLY_PC   numeric,
  RDNACADENCE_CADENCE_ID_PC                           VARCHAR(18),
  RDNACADENCE_PENDING_SEQUENCE_PC                     VARCHAR(18),
  RINGDNA_SLA_C                                       VARCHAR(765),
  RDNACADENCE_PRIORITY_PC                             numeric,
  RDNACADENCE_NUMBER_OF_SEQUENCE_EMAILS_SENT_PC       numeric,
  RDNACADENCE_NUMBER_OF_PERFORMED_SEQUENCE_ACTIONS_PC numeric,
  RDNACADENCE_ENTRANCE_CRITERIA_MATCHED_DATE_PC       TIMESTAMPTZ,
  RINGDNA_ACTIVE_C                                    VARCHAR(765),
  RINGDNA_UPSELL_OPPORTUNITY_C                        VARCHAR(765),
  RDNACADENCE_CADENCE_PERFORMED_PC                    BOOLEAN,
  RINGDNA_SLAEXPIRATION_DATE_C                        DATE,
  LMS_JOB_ID_PC                                       VARCHAR(4099),
  RINGDNA_NUMBEROF_LOCATIONS_C                        numeric,
  RDNACADENCE_OPPORTUNITY_ID_PC                       VARCHAR(60),
  RDNACADENCE_OPENED_SEQUENCE_EMAIL_PC                BOOLEAN,
  RDNACADENCE_DRIP_SEQUENCE_PENDING_PC                BOOLEAN
);

drop table if exists brs.ahj_utility_c;
create table if not exists brs.AHJ_UTILITY_C
(
  ID                                     VARCHAR(18),
  OWNER_ID                               VARCHAR(18),
  IS_DELETED                             BOOLEAN,
  NAME                                   VARCHAR(240),
  CURRENCY_ISO_CODE                      VARCHAR(9),
  CREATED_DATE                           TIMESTAMPTZ,
  CREATED_BY_ID                          VARCHAR(18),
  LAST_MODIFIED_DATE                     TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID                    VARCHAR(18),
  SYSTEM_MODSTAMP                        TIMESTAMPTZ,
  LAST_VIEWED_DATE                       TIMESTAMPTZ,
  LAST_REFERENCED_DATE                   TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID                 VARCHAR(18),
  CONNECTION_SENT_ID                     VARCHAR(18),
  AC_DISCONNECT_REQUIRED_C               BOOLEAN,
  AC_DISCONNECT_REQUIREMENT_NOTES_C      VARCHAR(98304),
  AHJ_UTILITY_ID_C                       VARCHAR(240),
  ADDITIONAL_UTILITY_NOTES_C             VARCHAR(98304),
  LAYOUT_REQUIRED_C                      BOOLEAN,
  LINE_DIAGRAM_REQUIRED_C                BOOLEAN,
  OVERSIZING_ALLOWANCE_AND_REQUIREMENT_C VARCHAR(98304),
  PROD_METER_REQUIRED_C                  VARCHAR(765),
  PRODUCTION_METER_NOTES_C               VARCHAR(98304),
  TURN_AROUND_TIME_C                     numeric,
  UTILITY_PLACE_CARD_REQUIREMENT_C       VARCHAR(98304),
  STATE_C                                VARCHAR(765),
  ACTIVATION_TRACKER_ENABLED_C           BOOLEAN,
  _FIVETRAN_DELETED                      BOOLEAN,
  _FIVETRAN_SYNCED                       TIMESTAMPTZ,
  UTILITY_PRE_COMM_NOTES_C               VARCHAR(98304),
  PERMIT_COLLECTION_URL_C                VARCHAR(765),
  UTILITY_POC_C                          VARCHAR(765),
  ADDITIONAL_DOCUMENTS_C                 VARCHAR(765),
  APPLICATION_PORTAL_URL_C               VARCHAR(765),
  GBFS_HANDOFF_C                         BOOLEAN,
  FINAL_PERMIT_REQUIREMENTS_C            VARCHAR(765),
  ESS_URL_C                              VARCHAR(765),
  GBFS_PROCESS_LINK_C                    BOOLEAN,
  SIZE_RESTRICTIONS_C                    VARCHAR(765),
  INSURANCE_COPY_REQUIRED_C              BOOLEAN,
  IC_REQUIREMENTS_DOCUMENTED_C           BOOLEAN,
  INTERCONNECT_FEES_C                    numeric(17, 2),
  LAST_UTILITY_PROCESS_REVIEW_C          DATE,
  PTO_TIMELINE_C                         VARCHAR(765),
  PRE_APPROVAL_PROCESS_C                 VARCHAR(765),
  UTILITY_URL_C                          VARCHAR(765),
  PAYMENT_TYPE_C                         VARCHAR(765),
  ADDITIONAL_PERMIT_IC_NOTES_C           VARCHAR(765),
  DESIGN_FOLDER_C                        VARCHAR(765),
  ESS_REQUIREMENTS_C                     VARCHAR(765),
  PANEL_INVERTER_SPEC_SHEET_REQUIRED_C   BOOLEAN,
  BUILDER_SIGNATURE_REQUIRED_C           BOOLEAN,
  ESS_REQUIREMENTS_DOCUMENTED_C          VARCHAR(765),
  FINAL_PERMIT_COLLECTION_C              VARCHAR(765),
  PRE_APPROVAL_REQUIRED_C                BOOLEAN,
  AC_DISCO_SPEC_SHEET_REQUIRED_C         BOOLEAN,
  SUBMITTAL_C                            VARCHAR(765),
  BUYER_VS_BUILDER_SUBMITTALS_C          VARCHAR(765),
  SIDE_ELEVATION_REQUIRED_C              BOOLEAN
);


drop table if exists brs.ALLIANCE_PARTNER_C;
create table if not exists brs.ALLIANCE_PARTNER_C
(
  ID                            VARCHAR(18),
  OWNER_ID                      VARCHAR(18),
  IS_DELETED                    BOOLEAN,
  NAME                          VARCHAR(240),
  CURRENCY_ISO_CODE             VARCHAR(9),
  RECORD_TYPE_ID                VARCHAR(18),
  CREATED_DATE                  TIMESTAMPTZ,
  CREATED_BY_ID                 VARCHAR(18),
  LAST_MODIFIED_DATE            TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID           VARCHAR(18),
  SYSTEM_MODSTAMP               TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID        VARCHAR(18),
  CONNECTION_SENT_ID            VARCHAR(18),
  RESIDENTIAL_PROJECT_C         VARCHAR(18),
  PARTNER_ACCOUNT_C             VARCHAR(18),
  ROLE_C                        VARCHAR(765),
  COMMUNITY_C                   VARCHAR(18),
  UPDATE_RPON_ICD_C             BOOLEAN,
  LOAN_PAYMENT_CLASSIFICATION_C VARCHAR(150),
  _FIVETRAN_SYNCED              TIMESTAMPTZ,
  _FIVETRAN_DELETED             BOOLEAN,
  CUSTOMER_ACCOUNT_C            VARCHAR(18)
);


drop table if exists brs.BUILDER_PRICING_C;
create table if not exists brs.BUILDER_PRICING_C
(
  ID                            VARCHAR(18),
  OWNER_ID                      VARCHAR(18),
  IS_DELETED                    BOOLEAN,
  NAME                          VARCHAR(240),
  CURRENCY_ISO_CODE             VARCHAR(9),
  CREATED_DATE                  TIMESTAMPTZ,
  CREATED_BY_ID                 VARCHAR(18),
  LAST_MODIFIED_DATE            TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID           VARCHAR(18),
  SYSTEM_MODSTAMP               TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID        VARCHAR(18),
  CONNECTION_SENT_ID            VARCHAR(18),
  COMMUNITY_C                   VARCHAR(18),
  LEASE_INCENTIVE_FEE_C         numeric(9, 2),
  NET_CONTRACTED_PRICE_C        numeric(9, 2),
  NOTES_C                       VARCHAR(765),
  SYSTEM_WATTAGE_DC_C           numeric,
  ACTIVE_C                      BOOLEAN,
  WRAP_INSURANCE_PERCENT_C      numeric,
  CASH_INCENTIVE_FEE_C          numeric(9, 2),
  _FIVETRAN_SYNCED              TIMESTAMPTZ,
  _FIVETRAN_DELETED             BOOLEAN,
  CODE_YEAR_C                   VARCHAR(765),
  STORAGE_SIZE_C                VARCHAR(765),
  STORAGE_PRICE_C               numeric(18, 2),
  NEM_3_0_LEASE_INCENTIVES_C    numeric(9, 2),
  STORAGE_CONFIGURATION_GROUP_C VARCHAR(18)
);



drop table if exists brs.CAMPAIGN;
create table if not exists brs.CAMPAIGN
(
  ID                                         VARCHAR(18),
  IS_DELETED                                 BOOLEAN,
  NAME                                       VARCHAR(240),
  PARENT_ID                                  VARCHAR(18),
  TYPE                                       VARCHAR(765),
  RECORD_TYPE_ID                             VARCHAR(18),
  STATUS                                     VARCHAR(765),
  START_DATE                                 DATE,
  END_DATE                                   DATE,
  CURRENCY_ISO_CODE                          VARCHAR(9),
  EXPECTED_REVENUE                           numeric(18),
  BUDGETED_COST                              numeric(18),
  ACTUAL_COST                                numeric(18),
  EXPECTED_RESPONSE                          numeric,
  NUMBER_SENT                                numeric,
  IS_ACTIVE                                  BOOLEAN,
  DESCRIPTION                                VARCHAR(96000),
  CAMPAIGN_IMAGE_ID                          VARCHAR(18),
  NUMBER_OF_LEADS                            numeric,
  NUMBER_OF_CONVERTED_LEADS                  numeric,
  NUMBER_OF_CONTACTS                         numeric,
  NUMBER_OF_RESPONSES                        numeric,
  NUMBER_OF_OPPORTUNITIES                    numeric,
  NUMBER_OF_WON_OPPORTUNITIES                numeric,
  AMOUNT_ALL_OPPORTUNITIES                   numeric(18),
  AMOUNT_WON_OPPORTUNITIES                   numeric(18),
  HIERARCHY_NUMBER_OF_LEADS                  numeric,
  HIERARCHY_NUMBER_OF_CONVERTED_LEADS        numeric,
  HIERARCHY_NUMBER_OF_CONTACTS               numeric,
  HIERARCHY_NUMBER_OF_RESPONSES              numeric,
  HIERARCHY_NUMBER_OF_OPPORTUNITIES          numeric,
  HIERARCHY_NUMBER_OF_WON_OPPORTUNITIES      numeric,
  HIERARCHY_AMOUNT_ALL_OPPORTUNITIES         numeric(18),
  HIERARCHY_AMOUNT_WON_OPPORTUNITIES         numeric(18),
  HIERARCHY_NUMBER_SENT                      numeric,
  HIERARCHY_EXPECTED_REVENUE                 numeric(18),
  HIERARCHY_BUDGETED_COST                    numeric(18),
  HIERARCHY_ACTUAL_COST                      numeric(18),
  OWNER_ID                                   VARCHAR(18),
  CREATED_DATE                               TIMESTAMPTZ,
  CREATED_BY_ID                              VARCHAR(18),
  LAST_MODIFIED_DATE                         TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID                        VARCHAR(18),
  SYSTEM_MODSTAMP                            TIMESTAMPTZ,
  LAST_ACTIVITY_DATE                         DATE,
  LAST_VIEWED_DATE                           TIMESTAMPTZ,
  LAST_REFERENCED_DATE                       TIMESTAMPTZ,
  CAMPAIGN_MEMBER_RECORD_TYPE_ID             VARCHAR(18),
  BUSINESS_UNIT_C                            VARCHAR(765),
  CAMPAIGN_GOAL_C                            VARCHAR(765),
  CAMPAIGN_ID_C                              VARCHAR(765),
  CAMPAIGN_TARGET_AUDIENCE_C                 VARCHAR(96000),
  EXPECTED_LEADS_C                           numeric,
  EXPECTED_LEADS_PERCENTAGE_C                numeric,
  EXPECTED_OPPORTUNITY_PERCENTAGE_C          numeric,
  INDUSTRY_VERTICAL_C                        VARCHAR(765),
  LIST_DESCRIPTION_C                         VARCHAR(96000),
  PROMO_CODE_C                               VARCHAR(240),
  INTEGRATION_ID_C                           VARCHAR(60),
  RLC_TYPE_C                                 VARCHAR(765),
  LEAD_HANDLING_FEE_C                        numeric,
  LEAD_GENERATION_FEE_C                      numeric,
  SUB_OFFICE_LOCATIONS_C                     VARCHAR(4099),
  STAGE_C                                    VARCHAR(765),
  PROBABILITY_C                              VARCHAR(765),
  REFERRED_BY_C                              VARCHAR(765),
  OFFICE_LOCATION_C                          VARCHAR(4099),
  WEB_SITE_C                                 VARCHAR(765),
  CONTACT_TITLE_C                            VARCHAR(150),
  TIER_C                                     VARCHAR(765),
  SME_C                                      VARCHAR(18),
  LAUNCH_DATE_C                              DATE,
  THEATER_C                                  VARCHAR(765),
  STATUS_UPDATE_C                            VARCHAR(15000),
  TOTAL_NO_LEADS_C                           numeric,
  REBATE_FORM_URL_C                          VARCHAR(765),
  ELOQUA_FORM_NAME_C                         VARCHAR(765),
  SLA_TYPE_C                                 VARCHAR(765),
  SHORT_DESCRIPTION_C                        VARCHAR(765),
  REQUIRES_LEAD_PRE_QUALIFICATION_C          BOOLEAN,
  PUBLISH_C                                  BOOLEAN,
  RETAILER_C                                 VARCHAR(765),
  IS_EXCLUSIVE_C                             BOOLEAN,
  SALES_STATUS_C                             VARCHAR(765),
  ASSIGN_TO_TCPA_DIALER_C                    BOOLEAN,
  REBATE_CODE_C                              VARCHAR(240),
  TFN_C                                      VARCHAR(120),
  RINGDNA_100_CALL_ATTEMPTS_C                numeric,
  RINGDNA_100_EMAIL_ATTEMPTS_C               numeric,
  RINGDNA_100_FIRST_INBOUND_CALL_C           TIMESTAMPTZ,
  RINGDNA_100_FIRST_OUTBOUND_CALL_C          TIMESTAMPTZ,
  RINGDNA_100_LAST_EMAIL_ATTEMPT_C           TIMESTAMPTZ,
  RINGDNA_100_LAST_INBOUND_CALL_C            TIMESTAMPTZ,
  RINGDNA_100_LAST_OUTBOUND_CALL_C           TIMESTAMPTZ,
  RINGDNA_100_RESPONSE_TYPE_C                VARCHAR(765),
  RINGDNA_100_RING_DNA_CONTEXT_C             BOOLEAN,
  RINGDNA_100_TIME_TO_FIRST_DIAL_MINUTES_C   numeric,
  RINGDNA_100_TIME_TO_FIRST_RESPONSE_C       numeric,
  _FIVETRAN_SYNCED                           TIMESTAMPTZ,
  _FIVETRAN_DELETED                          BOOLEAN,
  HQ_PRIMARY_ADDRESS_C                       VARCHAR(297),
  NH_COMMUNITY_C                             VARCHAR(18),
  I_PLOT_REQUIRED_C                          BOOLEAN,
  SPECIAL_OFFER_C                            BOOLEAN,
  ALLIANCE_OFFER_C                           VARCHAR(7500),
  ACCOUNT_C                                  VARCHAR(18),
  ACTIVE_MY_SUN_POWER_REFERRAL_CAMPAIGN_C    BOOLEAN,
  CHECK_AGAINST_DNC_LIST_C                   BOOLEAN,
  LAST_COMMUNITY_VISIT_C                     VARCHAR(765),
  SOLAR_CUT_OFF_C                            VARCHAR(765),
  CHANNELS_C                                 VARCHAR(4099),
  ASSIGN_RANDOM_PARTNER_C                    BOOLEAN,
  SERVICE_AGREEMENT_SIGNED_C                 DATE,
  CONTACT_CELL_PHONE_C                       VARCHAR(75),
  FIVE_9_FIVE_9_LIST_C                       VARCHAR(150),
  COLLATERAL_FLYERS_REBATE_FORMS_ETC_C       DATE,
  HQ_PRIMARY_ADDRESS_2_C                     VARCHAR(297),
  ALLIANCE_NOTES_C                           VARCHAR(98304),
  MEETING_PROGRAM_OVERVIEW_CONDUCTED_C       DATE,
  CONTACT_FIRST_NAME_C                       VARCHAR(297),
  FIVE_9_FIVE_9_USER_C                       VARCHAR(150),
  FIVE_9_FIVE_9_REPORT_EMAIL_C               VARCHAR(240),
  GROUP_NAME_C                               VARCHAR(297),
  REWARD_AMOUNT_C                            numeric(18, 2),
  LANDING_PAGE_LIVE_C                        DATE,
  OF_EMPLOYEES_MEMBERS_TOTAL_C               VARCHAR(297),
  FIVE_9_FIVE_9_PASSWORD_C                   VARCHAR(150),
  PROGRAM_TYPE_C                             VARCHAR(4099),
  CONTACT_FAX_C                              VARCHAR(45),
  SERVICE_AGREEMENT_PROVIDED_C               DATE,
  CAMPAIGN_LANDING_PAGE_C                    VARCHAR(765),
  PROGRAM_COMMUNICATED_TO_EMPLOYEE_MEMBERS_C DATE,
  FIVE_9_FIVE_9_CALL_NOW_C                   BOOLEAN,
  SKIP_LEAD_ASSIGNMENT_C                     BOOLEAN,
  FIVE_9_FIVE_9_ENDPOINT_C                   VARCHAR(765),
  CONTACT_LAST_NAME_C                        VARCHAR(297),
  HQ_PRIMARY_CITY_C                          VARCHAR(297),
  CONTACT_EMAIL_C                            VARCHAR(297),
  HQ_PRIMARY_STATE_C                         VARCHAR(765),
  HQ_COUNTRY_C                               VARCHAR(765),
  ATTENDED_BY_C                              VARCHAR(765),
  CONTACT_OFFICE_PHONE_C                     VARCHAR(297),
  HQ_PRIMARY_ZIP_CODE_C                      VARCHAR(30),
  TWILIO_SF_DELIVERABLE_C                    numeric,
  TWILIO_SF_UNDELIVERED_C                    numeric,
  TWILIO_SF_NO_MOBILE_C                      numeric,
  TWILIO_SF_OPT_IN_KEYWORD_C                 VARCHAR(18),
  TWILIO_SF_NOT_OPTED_IN_C                   numeric,
  TWILIO_SF_DELIVERABILITY_STATUS_C          VARCHAR(765),
  TWILIO_SF_TOTAL_DELIVERABILITY_COUNT_C     numeric,
  TWILIO_SF_FAILED_C                         numeric,
  TWILIO_SF_UNKNOWN_C                        numeric,
  TWILIO_SF_BLOCKED_C                        numeric
);


drop table if exists brs.NH_COMMUNITY_C;
create table if not exists brs.NH_COMMUNITY_C
(
  ID                                         VARCHAR(18),
  OWNER_ID                                   VARCHAR(18),
  IS_DELETED                                 BOOLEAN,
  NAME                                       VARCHAR(240),
  CURRENCY_ISO_CODE                          VARCHAR(9),
  CREATED_DATE                               TIMESTAMPTZ,
  CREATED_BY_ID                              VARCHAR(18),
  LAST_MODIFIED_DATE                         TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID                        VARCHAR(18),
  SYSTEM_MODSTAMP                            TIMESTAMPTZ,
  LAST_VIEWED_DATE                           TIMESTAMPTZ,
  LAST_REFERENCED_DATE                       TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID                     VARCHAR(18),
  CONNECTION_SENT_ID                         VARCHAR(18),
  BUILDER_NAME_C                             VARCHAR(765),
  COMMUNITY_NAME_C                           VARCHAR(765),
  INSTALLER_C                                VARCHAR(18),
  REGION_C                                   VARCHAR(765),
  COMMUNITY_NAME_TEXT_C                      VARCHAR(150),
  FINANCIAL_OFFERING_C                       VARCHAR(4099),
  PRIMARY_ENERGY_CONSULTANT_C                VARCHAR(18),
  SOLAR_ADD_ON_C                             VARCHAR(765),
  AHJ_C                                      VARCHAR(300),
  ACCOUNT_MANAGER_C                          VARCHAR(18),
  BASE_SQUARE_FOOTAGE_N_C                    numeric,
  BUILDER_PREFERRED_ROOFER_C                 VARCHAR(765),
  BUILDER_C                                  VARCHAR(18),
  BUILDING_TYPE_C                            VARCHAR(765),
  BUSINESS_UNIT_C                            VARCHAR(765),
  CAL_CERTS_READY_C                          VARCHAR(765),
  CASH_PV_MODULE_QTY_C                       VARCHAR(120),
  CITY_LOCATION_C                            VARCHAR(180),
  CLIMATE_ZONE_C                             VARCHAR(150),
  COMMUNITY_ADDER_C                          VARCHAR(4099),
  COMMUNITY_ID_C                             VARCHAR(90),
  COMMUNITY_STATUS_C                         VARCHAR(765),
  COMMUNITY_SUPERINTENDENT_EMAIL_C           VARCHAR(240),
  COMMUNITY_SUPERINTENDENT_NAME_C            VARCHAR(150),
  COMMUNITY_SUPERINTENDENT_PHONE_NUMBER_C    VARCHAR(120),
  COMMUNITY_TYPE_C                           VARCHAR(765),
  DISTRIBUTION_TYPE_C                        VARCHAR(765),
  EE_PLAN_CHECK_TYPE_C                       VARCHAR(765),
  EXPECTED_COMMUNITY_CONSTRUCTION_START_C    DATE,
  INSPECTION_CONTRACT_TYPE_C                 VARCHAR(765),
  INVERTER_TYPE_C                            VARCHAR(765),
  IPLOT_DESIGN_NOTES_C                       VARCHAR(765),
  MASTER_DEVELOPMENT_PERMITTING_NAME_C       VARCHAR(180),
  MOUNTING_TYPE_C                            VARCHAR(765),
  NUMBER_OF_HOMES_RESERVED_C                 numeric,
  NUMBER_OF_HOMES_IN_COMMUNITY_C             numeric,
  PV_HERS_PROVIDER_C                         VARCHAR(765),
  PV_MODULE_MODEL_C                          VARCHAR(765),
  PANEL_ORIENTATION_C                        VARCHAR(765),
  PERMIT_PACK_TYPE_C                         VARCHAR(765),
  PERMITTING_NOTES_C                         VARCHAR(98304),
  PRE_PLUMB_C                                VARCHAR(765),
  REBATE_PAYABLE_TO_C                        VARCHAR(765),
  REBATE_PROGRAM_C                           VARCHAR(765),
  REBATE_RESERVATION_CONFIRMATION_NUMBER_C   VARCHAR(765),
  REBATE_RESERVATION_EXPIRY_DATE_C           DATE,
  REBATE_RESERVATION_TYPE_C                  VARCHAR(765),
  REGISTRY_NOTES_C                           VARCHAR(765),
  RESERVATION_AMOUNT_PER_PROJECT_C           numeric(18, 2),
  RESERVATION_NOTES_C                        VARCHAR(765),
  RESERVED_INCENTIVE_LEVEL_C                 VARCHAR(75),
  RESERVED_KW_C                              numeric,
  ROUGH_WIRE_C                               VARCHAR(765),
  SPWR_HERS_RATER_NAME_C                     VARCHAR(90),
  T_24_CODE_RESERVED_C                       VARCHAR(75),
  TIER_LEVEL_C                               VARCHAR(765),
  TRACKING_NUMBER_C                          VARCHAR(150),
  TRACT_NUMBER_C                             VARCHAR(180),
  TYPE_OF_RELEASE_C                          VARCHAR(765),
  UTILITY_C                                  VARCHAR(180),
  ZIP_CODE_C                                 VARCHAR(15),
  BUILDER_DELIVERY_INFO_C                    VARCHAR(765),
  BUILDER_HERS_RATER_C                       VARCHAR(150),
  SHEET_SIZE_C                               VARCHAR(765),
  STATE_C                                    VARCHAR(150),
  TOTAL_NUMBER_OF_SETS_C                     numeric,
  MASTER_PERMIT_C                            VARCHAR(45),
  MONITORING_INCLUDED_C                      VARCHAR(765),
  BUILDER_ARCHITECT_C                        VARCHAR(18),
  WEEKS_PRIOR_TO_ROUGH_INSTALL_FOR_CUT_OFF_C VARCHAR(765),
  MODULE_CONFIGURATION_C                     VARCHAR(18),
  ROOF_ATTACHMENT_C                          VARCHAR(4099),
  BUILDER_CIVIL_ENGINEER_C                   VARCHAR(18),
  BUILDER_PROJECT_MANAGER_C                  VARCHAR(18),
  BUILDER_PURCHASING_CONTACT_C               VARCHAR(18),
  BUILDER_SPECIFIC_REQUIREMENTS_C            VARCHAR(98304),
  PERMITTING_RESPONSIBILITY_C                VARCHAR(765),
  UTILITY_CONSIDERATIONS_C                   VARCHAR(98304),
  MULTI_FAMILY_ARRAY_C                       VARCHAR(765),
  MULTI_FAMILY_INTERCONNECTION_C             VARCHAR(765),
  MULTI_FAMILY_STEEP_ROOF_C                  BOOLEAN,
  MODEL_DISCOUNT_C                           VARCHAR(765),
  COMPETITOR_C                               VARCHAR(765),
  GRAND_OPENING_DATE_C                       DATE,
  PROBABILITY_C                              VARCHAR(765),
  REASON_WON_LOST_C                          VARCHAR(765),
  STAGE_C                                    VARCHAR(765),
  ADDRESS_LIST_INFO_COMPLETE_C               BOOLEAN,
  ADDRESS_LIST_C                             VARCHAR(765),
  ARCHITECTURE_FILES_INFO_COMPLETE_C         BOOLEAN,
  ARCHITECTURE_FILES_C                       VARCHAR(765),
  CAMPAIGN_C                                 VARCHAR(18),
  DOCUMENT_NOTES_C                           VARCHAR(765),
  SEQUENCE_SHEET_INFO_COMPLETE_C             BOOLEAN,
  SEQUENCE_SHEET_C                           VARCHAR(765),
  SITE_PLAN_INFO_COMPLETE_C                  BOOLEAN,
  SITE_PLAN_C                                VARCHAR(765),
  BUILDER_PERMITTING_COMPLETE_C              BOOLEAN,
  PERMIT_AHJ_FEES_C                          numeric(18, 2),
  PERMIT_EXECUTION_FEES_C                    numeric(18, 2),
  BUILDER_FILE_VALIDATION_C                  VARCHAR(765),
  ARCHITECTURE_FILES_TEXT_C                  VARCHAR(765),
  LAT_LONG_LATITUDE_S                        numeric,
  LAT_LONG_LONGITUDE_S                       numeric,
  STORAGE_ALLOWED_C                          BOOLEAN,
  BUILDER_INITIAL_SUBMITTER_C                DATE,
  LEASE_TERM_C                               VARCHAR(765),
  MY_SUN_POWER_C                             BOOLEAN,
  AHJNAME_C                                  VARCHAR(18),
  FIELD_MANAGER_C                            VARCHAR(18),
  LEASE_ESCALATOR_C                          VARCHAR(765),
  SR_BUILDER_OPERATION_MANAGER_C             VARCHAR(18),
  ACTIVATION_COORDINATOR_C                   VARCHAR(765),
  STRUCTURAL_OPTIONS_ENHANCEMENTS_C          VARCHAR(765),
  BULK_RP_CREATION_C                         BOOLEAN,
  STAGE_MODIFIED_DATE_C                      DATE,
  CUSTOM_ADDER_DESCRIPTION_C                 VARCHAR(765),
  CUSTOM_COMMUNITY_ADDER_C                   numeric(18, 2),
  ESS_PERMIT_PACK_TYPE_C                     VARCHAR(765),
  ESS_PERMITTING_RESPONSIBILITY_C            VARCHAR(765),
  HOME_ENERGY_SOURCE_C                       VARCHAR(765),
  OWNERSHIP_TYPE_C                           VARCHAR(765),
  BUILDER_UTILITY_REP_C                      VARCHAR(18),
  EVSE_OFFERING_C                            VARCHAR(765),
  PREVAILING_WAGE_DETAILS_C                  VARCHAR(765),
  PREVAILING_WAGE_C                          BOOLEAN,
  PROPOSAL_LINK_C                            VARCHAR(98304),
  UTILITY_RELATIONSHIP_C                     VARCHAR(18),
  AHJ_UTILITY_C                              VARCHAR(18),
  _FIVETRAN_SYNCED                           TIMESTAMPTZ,
  PHASE_CUTOVER_C                            VARCHAR(765),
  TRANSITION_NOTES_C                         VARCHAR(98304),
  SSP_REQUIRED_C                             VARCHAR(765),
  _FIVETRAN_DELETED                          BOOLEAN,
  DISTANCE_ADDER_C                           BOOLEAN,
  ELECTRICAL_DIAGRAM_C                       BOOLEAN,
  STORAGE_TYPE_C                             VARCHAR(765),
  INSTALLATION_TYPE_C                        VARCHAR(765),
  RIGHT_SIZED_C                              BOOLEAN,
  ROOF_TYPE_C                                VARCHAR(765),
  SR_COMMUNITY_ACCOUNT_MANAGER_C             VARCHAR(765),
  STORAGE_C                                  VARCHAR(765),
  STORAGE_BACKUP_TYPE_C                      VARCHAR(765),
  CUSTOM_PRICING_NOTES_C                     VARCHAR(393216),
  LOAD_APPLICATION_C                         VARCHAR(765),
  LOAD_APPLICATION_RECEIVED_C                BOOLEAN,
  PREFERRED_PV_PARTNER_C                     VARCHAR(765),
  PREFERRED_STORAGE_PARTNER_C                VARCHAR(765),
  COMMUNITY_DOCUMENTS_FOLDER_C               VARCHAR(765),
  FLAT_LEASE_COMMUNITY_C                     BOOLEAN
);



drop table if exists brs.NH_COMMUNITY_VISIT_C;
create table if not exists brs.NH_COMMUNITY_VISIT_C
(
  ID                     VARCHAR(18),
  IS_DELETED             BOOLEAN,
  NAME                   VARCHAR(240),
  CURRENCY_ISO_CODE      VARCHAR(9),
  CREATED_DATE           TIMESTAMPTZ,
  CREATED_BY_ID          VARCHAR(18),
  LAST_MODIFIED_DATE     TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID    VARCHAR(18),
  SYSTEM_MODSTAMP        TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID VARCHAR(18),
  CONNECTION_SENT_ID     VARCHAR(18),
  NH_COMMUNITY_C         VARCHAR(18),
  RECENT_VISIT_DATE_C    DATE,
  ROLE_C                 VARCHAR(765),
  VISIT_NOTES_C          VARCHAR(98304),
  _FIVETRAN_DELETED      BOOLEAN,
  _FIVETRAN_SYNCED       TIMESTAMPTZ
);



drop table if exists brs.NH_CONTRACTS_C;
create table if not exists brs.NH_CONTRACTS_C
(
  ID                     VARCHAR(18),
  OWNER_ID               VARCHAR(18),
  IS_DELETED             BOOLEAN,
  NAME                   VARCHAR(240),
  CURRENCY_ISO_CODE      VARCHAR(9),
  CREATED_DATE           TIMESTAMPTZ,
  CREATED_BY_ID          VARCHAR(18),
  LAST_MODIFIED_DATE     TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID    VARCHAR(18),
  SYSTEM_MODSTAMP        TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID VARCHAR(18),
  CONNECTION_SENT_ID     VARCHAR(18),
  ATTACHMENT_ID_C        VARCHAR(54),
  ATTACHMENT_TITLE_C     VARCHAR(765),
  DOCUMENT_TYPE_C        VARCHAR(765),
  NH_COMMUNITY_C         VARCHAR(18),
  URL_TRACKABLE_C        VARCHAR(765),
  _FIVETRAN_DELETED      BOOLEAN,
  _FIVETRAN_SYNCED       TIMESTAMPTZ
);


drop table if exists brs.PLAN_TYPE_C;
create table if not exists brs.PLAN_TYPE_C
(
  ID                            VARCHAR(18),
  IS_DELETED                    BOOLEAN,
  NAME                          VARCHAR(240),
  CURRENCY_ISO_CODE             VARCHAR(9),
  CREATED_DATE                  TIMESTAMPTZ,
  CREATED_BY_ID                 VARCHAR(18),
  LAST_MODIFIED_DATE            TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID           VARCHAR(18),
  SYSTEM_MODSTAMP               TIMESTAMPTZ,
  LAST_VIEWED_DATE              TIMESTAMPTZ,
  LAST_REFERENCED_DATE          TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID        VARCHAR(18),
  CONNECTION_SENT_ID            VARCHAR(18),
  COMMUNITY_C                   VARCHAR(18),
  BASE_SQUARE_FOOTAGE_C         numeric,
  MODULES_C                     numeric,
  CODE_LEVEL_C                  VARCHAR(765),
  CFI_C                         VARCHAR(765),
  MIN_SYSTEM_SIZE_WATTS_C       numeric,
  SOLAR_ACCESS_C                numeric,
  RETAIL_VALUE_C                numeric(18),
  SUN_VAULT_RETAIL_VALUE_C      numeric(18),
  MODULE_CONFIGURATION_1_C      VARCHAR(18),
  MODULE_CONFIGURATION_2_C      VARCHAR(18),
  ADDITIONAL_COST_FOR_STORAGE_C numeric(18),
  FLAT_MONTHLY_TPO_RATE_C       numeric(18),
  _FIVETRAN_DELETED             BOOLEAN,
  _FIVETRAN_SYNCED              TIMESTAMPTZ
);


drop table if exists brs.MODULE_CONFIGURATION_C;
create table if not exists brs.MODULE_CONFIGURATION_C
(
  ID                     VARCHAR(18),
  OWNER_ID               VARCHAR(18),
  IS_DELETED             BOOLEAN,
  NAME                   VARCHAR(240),
  CURRENCY_ISO_CODE      VARCHAR(9),
  CREATED_DATE           TIMESTAMPTZ,
  CREATED_BY_ID          VARCHAR(18),
  LAST_MODIFIED_DATE     TIMESTAMPTZ,
  LAST_MODIFIED_BY_ID    VARCHAR(18),
  SYSTEM_MODSTAMP        TIMESTAMPTZ,
  LAST_VIEWED_DATE       TIMESTAMPTZ,
  LAST_REFERENCED_DATE   TIMESTAMPTZ,
  CONNECTION_RECEIVED_ID VARCHAR(18),
  CONNECTION_SENT_ID     VARCHAR(18),
  CURRENT_TYPE_C         VARCHAR(765),
  ITEM_C                 VARCHAR(18),
  DEFAULT_MODULE_ORDER_C numeric,
  _FIVETRAN_SYNCED       TIMESTAMPTZ,
  _FIVETRAN_DELETED      BOOLEAN,
  SERIES_NUM_C           VARCHAR(765),
  DIMENSIONS_WIDTH_C     numeric,
  DESCRIPTION_C          VARCHAR(3000),
  WATTAGE_C              numeric,
  DIMENSIONS_LENGTH_C    numeric,
  DIMENSIONS_SCALE_C     VARCHAR(765),
  SERIES_ALPHA_C         VARCHAR(765),
  EFFICIENCY_C           numeric,
  AVAILABILITY_SCALE_C   VARCHAR(765),
  DIMENSIONS_HEIGHT_C    numeric,
  AVAILABILITY_C         numeric,
  BACKSHEET_COLOR_C      VARCHAR(765)
);

CREATE INDEX if not exists nw_account_type ON brs.account (type);
CREATE INDEX if not exists nw_account_id ON brs.account (id);
CREATE INDEX if not exists nw_billing_state ON brs.account (billing_state);
CREATE INDEX if not exists nw_available_lender_c ON brs.account (available_lender_c);
CREATE INDEX if not exists nw_status_c ON brs.account (status_c);

CREATE INDEX if not exists ncc_builder_c ON brs.nh_community_c (builder_c);
CREATE INDEX if not exists ncc_state_c ON brs.nh_community_c (state_c);
CREATE INDEX if not exists ncc_lease_term_c ON brs.nh_community_c (lease_term_c);
CREATE INDEX if not exists ncc_weeks_prior_to_rough_install_for_cut_off_c ON brs.nh_community_c (weeks_prior_to_rough_install_for_cut_off_c);
CREATE INDEX if not exists ncc_builder_architect_c ON brs.nh_community_c (builder_architect_c);
CREATE INDEX if not exists ncc_builder_project_manager_c ON brs.nh_community_c (builder_project_manager_c);
CREATE INDEX if not exists ncc_campaign_c ON brs.nh_community_c (campaign_c);
CREATE INDEX if not exists ncc_competitor_c ON brs.nh_community_c (competitor_c);
CREATE INDEX if not exists ncc_distribution_type_c ON brs.nh_community_c (distribution_type_c);
CREATE INDEX if not exists ncc_home_energy_source_c ON brs.nh_community_c (home_energy_source_c);
CREATE INDEX if not exists ncc_multi_family_interconnection_c ON brs.nh_community_c (multi_family_interconnection_c);
CREATE INDEX if not exists ncc_pre_plumb_c ON brs.nh_community_c (pre_plumb_c);
CREATE INDEX if not exists ncc_reason_won_lost_c ON brs.nh_community_c (reason_won_lost_c);
CREATE INDEX if not exists ncc_rough_wire_c ON brs.nh_community_c (rough_wire_c);
CREATE INDEX if not exists ncc_type_of_release_c ON brs.nh_community_c (type_of_release_c);
CREATE INDEX if not exists ncc_stage_c ON brs.nh_community_c (stage_c);
CREATE INDEX if not exists ncc_building_type_c ON brs.nh_community_c (building_type_c);
CREATE INDEX if not exists ncc_ownership_type_c ON brs.nh_community_c (ownership_type_c);
CREATE INDEX if not exists ncc_financial_offering_c ON brs.nh_community_c (financial_offering_c);
CREATE INDEX if not exists ncc_permit_pack_type_c ON brs.nh_community_c (permit_pack_type_c);
CREATE INDEX if not exists ncc_permitting_responsibility_c ON brs.nh_community_c (permitting_responsibility_c);
CREATE INDEX if not exists ncc_ssp_required_c ON brs.nh_community_c (ssp_required_c);
CREATE INDEX if not exists ncc_ess_permit_pack_type_c ON brs.nh_community_c (ess_permit_pack_type_c);
CREATE INDEX if not exists ncc_ess_permitting_responsibility_c ON brs.nh_community_c (ess_permitting_responsibility_c);
CREATE INDEX if not exists ncc_mounting_type_c ON brs.nh_community_c (mounting_type_c);
CREATE INDEX if not exists ncc_roof_attachment_c ON brs.nh_community_c (roof_attachment_c);
CREATE INDEX if not exists ncc_multi_family_array_c ON brs.nh_community_c (multi_family_array_c);
CREATE INDEX if not exists ncc_roof_type_c ON brs.nh_community_c (roof_type_c);
CREATE INDEX if not exists ncc_installation_type_c ON brs.nh_community_c (installation_type_c);
CREATE INDEX if not exists ncc_inverter_type_c ON brs.nh_community_c (inverter_type_c);
CREATE INDEX if not exists ncc_structural_options_enhancements_c ON brs.nh_community_c (structural_options_enhancements_c);
CREATE INDEX if not exists ncc_evse_offering_c ON brs.nh_community_c (evse_offering_c);
CREATE INDEX if not exists ncc_builder_file_validation_c ON brs.nh_community_c (builder_file_validation_c);
CREATE INDEX if not exists ncc_storage_type_c ON brs.nh_community_c (storage_type_c);
CREATE INDEX if not exists ncc_storage_backup_type_c ON brs.nh_community_c (storage_backup_type_c);
CREATE INDEX if not exists ncc_rebate_program_c ON brs.nh_community_c (rebate_program_c);
CREATE INDEX if not exists ncc_rebate_payable_to_c ON brs.nh_community_c (rebate_payable_to_c);
CREATE INDEX if not exists ncc_COMMUNITY_ADDER_C ON brs.nh_community_c (COMMUNITY_ADDER_C);

CREATE INDEX if not exists ptc_CFI_C ON brs.plan_type_c (CFI_C);
CREATE INDEX if not exists ptc_code_level_c ON brs.plan_type_c (code_level_c);

CREATE INDEX if not exists campaign_id ON brs.campaign (id);


DO
$do$
  declare
    x            record;
    v_contact_id bigint;
  v_object_category_id bigint;

  BEGIN
    select oc.id
      into v_object_category_id
        from flow.object_category oc
      where object_category_code = 'BUILDER_NEW_HOMES_BUILDER';
    for x in select lov1.id as status_c1 ,lov.id as lov_available_lender_c,cs.id as company_state_id, a.*
             from brs.account a
                    left join flow.state s on s.abbreviation = a.billing_state
                    left join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
                    left join flow.list_of_value lov on lov.name = a.available_lender_c and lov.parent_id = 25717
                    left join flow.list_of_value lov1 on lov1.name = a.status_c and lov1.parent_id = 25722
             where type = 'Builder'

      loop
        v_contact_id = null;
        insert into flow.contact(contact_type_id, first_name, last_name, street1, street2, city, postal_code, phone,
                                 email, mobile, date_created, date_modified, created_by_id, modified_by_id, company_id,
                                 archived,
                                 company_state_id, company_country_id, nw_migration_id,object_category_id)
        values (1, x.name, null, x.billing_street, null, x.billing_city, x.billing_postal_code, x.phone, x.email_c,
                x.phone, now(), now(), 2384850, 2384850, 3, false,
                x.company_state_id, 1, x.id,v_object_category_id)
        returning id into v_contact_id;

        if v_contact_id is not null then
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28812, x.account_number,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28813, x.lov_available_lender_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28814, x.cash_partner_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28815, x.contact_name_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28816, x.credit_check_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28817, x.credit_limit_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28818, x.credit_limit_date_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28819, x.default_dealer_warehouse_shipping_site_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28820, x.description,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28821, x.i_supplier_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28822, x.legal_business_name_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28823, x.owner_id,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28826, x.rlcpa_notes_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28831, x.shipping_city,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28832, x.shipping_postal_code,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28833, x.shipping_state,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28830, x.shipping_street,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28827, x.spwr_cash_partner_c,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28828, x.status_c1,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28829, x.website,true);
        end if;
      end loop;

  end
$do$;


DO
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
    where object_category_code = 'COMMUNITY';
    for x in select c.id as contact_id,c.*,cs.id as company_state_id,lov.id as lov_lease_term_c_id,
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
                    l32.id as l32_rebate_payable_to_c_id
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
      loop
        v_project_id = null;
        v_community_adder_c = null;
        v_financial_offering_c = null;
        v_roof_attachment_c = null;
        insert into flow.project( contact_id, company_process_id, project_name, date_created, date_modified,
                                 created_by_id, modified_by_id, company_project_status_type_id,
                                 company_state_id,city,postal_code,
                                 company_country_id, archived,object_category_id,nw_migration_id)
        values(x.contact_id,26,x.community_name_c,now(),now(),
               2384850,2384850,case when x.community_status_c = 'Hold' then 224
                                    when x.community_status_c = 'Active' then 223
                                    when x.community_status_c = 'Cancelled' then 225
                                    when x.community_status_c = 'Construction Complete' then 226
                                    when x.community_status_c = 'Closed' then 227 end,company_state_id,x.city_location_c,x.zip_code_c,1,false,v_object_category_id,x.id) returning id into v_project_id;

        if v_project_id is not null then
          perform flow.set_project_cfv(v_project_id , 2384850,27998,x.community_id_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27999,x.number_of_homes_reserved_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28005,x.sr_community_account_manager_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28011,x.proposal_link_c , true);
         --todo Mandy is figuring out this
          perform flow.set_project_cfv(v_project_id , 2384850,27979,x.community_type_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27980,x.account_manager_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27981,x.expected_community_construction_start_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27982,x.grand_opening_date_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27983,x.number_of_homes_in_community_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27996,x.my_sun_power_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27988,x.field_manager_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27989,x.sr_builder_operation_manager_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28006,x.utility_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28005,x.sr_community_account_manager_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28007,x.ahj_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28010,x.builder_initial_submitter_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28008,x.tract_number_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28000,x.model_discount_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28001,x.lov_lease_term_c_id , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28002,x.lease_escalator_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28003,x.flat_lease_community_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,27996,x.my_sun_power_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28004,x.bulk_rp_creation_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28009,x.l_weeks_prior_to_rough_install_for_cut_off_c_id , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28030,x.l1_builder_architect_c_id , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28031,x.l1_builder_project_manager_c_id , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28029,x.builder_purchasing_contact_c , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28034,x.builder_utility_rep_c , true);
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
            perform flow.set_project_cfv(v_project_id , 2384850,28025,v_community_adder_c, true);
          end if;

          perform flow.set_project_cfv(v_project_id , 2384850,28015,x.l3_competitor_c_id , true);
          perform flow.set_project_cfv(v_project_id , 2384850,28027,x.distance_adder_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28016,x.l4_distribution_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28035,x.l5_home_energy_source_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28036,x.l6_multi_family_interconnection_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28033,x.phase_cutover_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28024,x.l7_pre_plumb_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28037,x.prevailing_wage_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28038,x.prevailing_wage_details_c, true);
          --todo ask carlin
          perform flow.set_project_cfv(v_project_id , 2384850,28014,x.l8_reason_won_lost_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28026,x.l9_rough_wire_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28032,x.transition_notes_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28028,x.l10_type_of_release_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28013,x.l11_stage_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27984,x.utility_considerations_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27986,x.l12_building_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27987,x.l13_OWNERSHIP_TYPE_C_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28017,x.region_c, true);
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
            perform flow.set_project_cfv(v_project_id , 2384850,27990,v_financial_offering_c, true);
          end if;

          perform flow.set_project_cfv(v_project_id , 2384850,28018,x.builder_preferred_roofer_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28019,x.preferred_pv_partner_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28020,x.preferred_storage_partner_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28021,x.community_superintendent_name_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28022,x.community_superintendent_email_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28023,x.community_superintendent_phone_number_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28725,x.activation_coordinator_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28040,x.tracking_number_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28039,x.l15_permit_pack_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28041,x.l16_PERMITTING_RESPONSIBILITY_C_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28042,x.builder_delivery_info_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28043,x.l17_ssp_required_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28044,x.permit_ahj_fees_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28093,x.permitting_notes_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28045,x.master_permit_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28046,x.builder_permitting_complete_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28047,x.l18_ess_permit_pack_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28048,x.l19_ess_permitting_responsibility_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28049,x.cash_pv_module_qty_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28051,x.right_sized_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28052,x.l20_mounting_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28053,x.sheet_size_c, true);

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
            perform flow.set_project_cfv(v_project_id , 2384850,28054,v_roof_attachment_c, true);
          end if;
          perform flow.set_project_cfv(v_project_id , 2384850,28057,x.l22_multi_family_array_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28055,x.l23_roof_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28058,x.multi_family_steep_roof_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28055,x.l24_installation_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28059,x.custom_community_adder_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28060,x.custom_adder_description_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28062,x.l25_inverter_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28063,x.l26_structural_options_enhancements_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28064,x.l27_evse_offering_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28065,x.l28_builder_file_validation_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27985,x.l29_storage_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,27995,x.l30_storage_backup_type_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28061,x.storage_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28066,x.l31_rebate_program_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28067,x.climate_zone_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28068,x.l32_rebate_payable_to_c_id, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28073,x.t_24_code_reserved_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28071,x.rebate_reservation_expiry_date_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28072,x.rebate_reservation_confirmation_number_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28075,x.reservation_amount_per_project_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28076,x.reserved_kw_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28077,x.reservation_notes_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28078,x.reserved_incentive_level_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28079,x.registry_notes_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28080,x.builder_hers_rater_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28435,x.load_application_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28436,x.load_application_received_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28082,x.address_list_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28083,x.address_list_info_complete_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28089,x.architecture_files_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28090,x.architecture_files_info_complete_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28086,x.community_documents_folder_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28092,x.document_notes_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28091,x.electrical_diagram_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28084,x.sequence_sheet_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28085,x.sequence_sheet_info_complete_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28087,x.site_plan_c, true);
          perform flow.set_project_cfv(v_project_id , 2384850,28088,x.site_plan_info_complete_c, true);
        end if;

      end loop;

  end
$do$;


DO
$do$
  declare
    x                               record;
    y                               record;
    v_project_process_step_id       bigint;
    v_project_process_step_event_id bigint;
  v_project_process_step_campaign_id bigint;
  BEGIN
    for x in select p.id as project_id,
                    c.id as community_id,
                    c3.owner_id,
                    lov1.id as lov1_sales_status_c_id,
                    c3.end_date,
                    c3.short_description_c,
                    c3.description,
                    c3.solar_cut_off_c
             from brs.NH_COMMUNITY_C c
                    inner join flow.project p on p.nw_migration_id = c.id
                    inner join brs.account a on a.id = c.builder_c
                    inner join flow.contact c2 on c2.nw_migration_id = a.id
                    left join brs.campaign c3 on c3.nh_community_c = c.id
                    left join flow.list_of_value lov1 on lov1.name = c3.sales_status_c and lov1.parent_id = 25309
      loop
        v_project_process_step_id = null;
        v_project_process_step_campaign_id = null;
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3756, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
        returning id into v_project_process_step_id;

        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id)
        values (x.project_id, 3758, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null)
        returning id into v_project_process_step_campaign_id;

        perform flow.set_pps_cfv(x.project_id, 2384850,28116,x.lov1_sales_status_c_id , true);
        perform flow.set_pps_cfv(x.project_id, 2384850,28117,x.owner_id , true);
        perform flow.set_pps_cfv(x.project_id, 2384850,28118,x.end_date , true);
        perform flow.set_pps_cfv(x.project_id, 2384850,28119,x.short_description_c , true);
        perform flow.set_pps_cfv(x.project_id, 2384850,28120,x.description , true);
        perform flow.set_pps_cfv(x.project_id, 2384850,28121,x.solar_cut_off_c , true);


        for y in select ptc.*,
                        lov1.id as lov1_CFI_C_id,
                        lov2.id as lov2_code_level_c_id
                 from brs.plan_type_c ptc
                        left join flow.list_of_value lov1 on lov1.name = ptc.CFI_C and lov1.parent_id = 25293
                        left join flow.list_of_value lov2 on lov2.name = ptc.code_level_c and lov2.parent_id = 25300
                 where ptc.community_c = x.community_id

          loop
            v_project_process_step_event_id = null;
            insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                        company_event_status_type_id, start_time, end_time,
                                                        date_created,
                                                        date_modified, created_by_id, modified_by_id, archived,
                                                        cancelled_date, completed_date, scheduled_date, save_version)
            values (v_project_process_step_id, 236, null, 3, null, null, now(), now(), 2384850, 2384850, false, null,
                    null, null, 1)
            returning id into v_project_process_step_event_id;

            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28099, y.CREATED_BY_ID, true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28098, y.NAME, true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28100,
                                           y.ADDITIONAL_COST_FOR_STORAGE_C, true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28101, y.BASE_SQUARE_FOOTAGE_C,
                                           true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28102, y.lov1_CFI_C_id, true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28103, y.lov2_code_level_c_id,
                                           true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28104, y.flat_monthly_tpo_rate_c,
                                           true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28105, y.min_system_size_watts_c,
                                           true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28107, y.modules_c, true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28108, y.retail_value_c, true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28109, y.solar_access_c, true);
            perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28110, y.sun_vault_retail_value_c,
                                           true);

          end loop;
      end loop;

  end
$do$;


