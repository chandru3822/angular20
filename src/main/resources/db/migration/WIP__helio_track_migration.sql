alter table flow.contact
  add column if not exists ht_migration_id integer;
alter table flow.project
  add column if not exists ht_migration_id integer;
alter table brs.helio_data
  add column if not exists financier_id bigint;
alter table brs.helio_data
  add column if not exists interest_rate numeric;
alter table brs.helio_data
  add column if not exists panel_brand_id bigint;
alter table brs.helio_data
  add column if not exists inverter_id bigint;
alter table brs.helio_data
  add column if not exists storage_brand_id bigint;
alter table brs.helio_data
  add column if not exists loan_term_id bigint;

with my_data as (SELECT "PRODUCT_TYPE",
                        hd."JOB_ID",
                        (REGEXP_MATCHES("PRODUCT_TYPE", '(\d+(?:\.\d+)?)%'))[1]::DECIMAL AS percent_value
                 from brs.helio_data hd
                 WHERE "PRODUCT_TYPE" LIKE '%\%%')
update brs.helio_data hd
set interest_rate = percent_value
from my_data md
where md."JOB_ID" = hd."JOB_ID";

update brs.helio_data hd
set financier_id = case
                     when "PRODUCT_TYPE" ilike '%lightreach%' then 29092
                     when "PRODUCT_TYPE" ilike '%svc%' then 29093
                     when "PRODUCT_TYPE" ilike '%CalFirst%' then 29094
                     when "PRODUCT_TYPE" ilike '%dividend%' then 726
                     when "PRODUCT_TYPE" ilike '%sunlight%' then 19023
                     when "PRODUCT_TYPE" ilike '%Greensky%' then 724
                     when "PRODUCT_TYPE" ilike '%HERO%' then 29095
                     when "PRODUCT_TYPE" ilike '%HelioLoan%' then 29096
                     when "PRODUCT_TYPE" ilike '%Integrys%' then 29097
                     when "PRODUCT_TYPE" ilike '%KW %' then 29098
                     when "PRODUCT_TYPE" ilike '%loanpal%' then 722
                     when "PRODUCT_TYPE" ilike '%Mosaic%' then 723
                     when "PRODUCT_TYPE" ilike '%PACE %' then 29099
                     when "PRODUCT_TYPE" ilike '%SunEdison%' then 29100
                     when "PRODUCT_TYPE" ilike '%SunPower%' then 20064
                     when "PRODUCT_TYPE" ilike '%Sunrun%' then 728
                     when "PRODUCT_TYPE" ilike '%Ygrene%' then 29101
                     when "PRODUCT_TYPE" ilike '%TG %' then 29102
                     when "PRODUCT_TYPE" ilike '%BrightOak%' then 29103
                     when "PRODUCT_TYPE" ilike '%Elevate Plus%' then 29104
                     when "PRODUCT_TYPE" ilike '%GreenPaceCapitals%' then 29105
                     when "PRODUCT_TYPE" ilike '%LLS PPA%' then 29106
                     when "PRODUCT_TYPE" ilike '%OneRoof PPA%' then 727
                     when "PRODUCT_TYPE" ilike '%cash%' then 721 end;

update brs.helio_data hd
set panel_brand_id = case
                       when "MODULE_MANUFACTURER" ilike '%Hanwha%' then 242
                       when "MODULE_MANUFACTURER" ilike '%longi%' then 252
                       when "MODULE_MANUFACTURER" ilike '%Solaria%' then 23734
                       when "MODULE_MANUFACTURER" ilike '%Aleo Solar%' then 29107
                       when "MODULE_MANUFACTURER" ilike '%Canadian Solar%' then 240
                       when "MODULE_MANUFACTURER" ilike '%CertainTeed%' then 20372
                       when "MODULE_MANUFACTURER" ilike '%Flextronics%' then 29108
                       when "MODULE_MANUFACTURER" ilike '%Hanwa%' then 242
                       when "MODULE_MANUFACTURER" ilike '%Hyundai%' then 241
                       when "MODULE_MANUFACTURER" ilike '%Jinko Solar%' then 247
                       when "MODULE_MANUFACTURER" ilike '%Kyocera%' then 253
                       when "MODULE_MANUFACTURER" ilike '%LG%' then 29109
                       when "MODULE_MANUFACTURER" ilike '%Mission%' then 29110
                       when "MODULE_MANUFACTURER" ilike '%Panasonic%' then 29111
                       when "MODULE_MANUFACTURER" ilike '%Phono%' then 253
                       when "MODULE_MANUFACTURER" ilike 'REC%' then 243
                       when "MODULE_MANUFACTURER" ilike '%Renesola%' then 29112
                       when "MODULE_MANUFACTURER" ilike '%SUNPOWER%' then 20062
                       when "MODULE_MANUFACTURER" ilike '%Silfab%' then 23877
                       when "MODULE_MANUFACTURER" ilike '%SolarWorld%' then 245
                       when "MODULE_MANUFACTURER" ilike '%Solar World%' then 245
                       when "MODULE_MANUFACTURER" ilike '%SunEdison%' then 29113
                       when "MODULE_MANUFACTURER" ilike '%Suniva%' then 29114
                       when "MODULE_MANUFACTURER" ilike '%Trina%' then 246
                       when "MODULE_MANUFACTURER" ilike '%logi%' then 252 end;

update brs.helio_data hd
set inverter_id = case
                    when "INVERTER_MODEL" ilike '%IQ6%' then 430
                    when "INVERTER_MODEL" ilike '%IQ7-60-2-US%' then 429
                    when "INVERTER_MODEL" ilike '%IQ7PLUS-72-2-US%' then 19146
                    when "INVERTER_MODEL" ilike '%M215-60-2LL-S22%' then 429
                    when "INVERTER_MODEL" ilike '%M250-60-2LL-S22%' then 429
                    when "INVERTER_MODEL" ilike '%SE10000A-US RGM%' then 149
                    when "INVERTER_MODEL" ilike '%SE10000H-US%' then 437
                    when "INVERTER_MODEL" ilike '%SE11400A-US RGM%' then 150
                    when "INVERTER_MODEL" ilike '%SE11400H%' then 438
                    when "INVERTER_MODEL" ilike '%SE3000A%' then 431
                    when "INVERTER_MODEL" ilike '%SE3000H%' then 144
                    when "INVERTER_MODEL" ilike '%SE3800A%' then 432
                    when "INVERTER_MODEL" ilike '%SE3800H%' then 145
                    when "INVERTER_MODEL" ilike '%SE5000H%' then 146
                    when "INVERTER_MODEL" ilike '%SE6000H%' then 147
                    when "INVERTER_MODEL" ilike '%SE7600A%' then 435
                    when "INVERTER_MODEL" ilike '%SE7600H%' then 148
  -- when "INVERTER_MODEL" ilike '%SEx000A-US%' then
                    when "INVERTER_MODEL" ilike '%SPR-x000p-TL-1 Central Inverter%' then 20063
                    when "INVERTER_MODEL" ilike '%SUNNY BOY%' then 436
  end;


update brs.helio_data hd
set storage_brand_id = case
                         when "BATTERY_NAME" ilike '%lg%' then 29115
                         when "BATTERY_NAME" ilike '%Telsa%' then 23856
                         when "BATTERY_NAME" ilike '%Enphase%' then 19408
                         when "BATTERY_NAME" ilike '%Storz%' then 29116
                         when "BATTERY_NAME" ilike '%Sunrun%' then 29117 end;

update brs.helio_data hd
set loan_term_id = case
                     when "PRODUCT_TYPE" ilike '% 2yr%' then 29118
                     when "PRODUCT_TYPE" ilike '%21.5yr%' then 29119
                     when "PRODUCT_TYPE" ilike '%20yr%' then 427
                     when "PRODUCT_TYPE" ilike '%16.5yr%' then 29120
                     when "PRODUCT_TYPE" ilike '%13.5yr%' then 29121
                     when "PRODUCT_TYPE" ilike '%10yr%' then 424
                     when "PRODUCT_TYPE" ilike '%12yr%' then 425
                     when "PRODUCT_TYPE" ilike '%15yr%' then 426
                     when "PRODUCT_TYPE" ilike '%25yr%' then 428
                     when "PRODUCT_TYPE" ilike '%30yr%' then 20511
                     when "PRODUCT_TYPE" ilike '% 5yr%' then 23653 end;

update brs.helio_data hd
set "NAME" = REGEXP_REPLACE("NAME", '\s*-\s*\d{2,5}$', '');


create index if not exists helio_data_name_idx  on brs.helio_data("NAME");
create index if not exists helio_data_product_type_idx  on brs.helio_data("PRODUCT_TYPE");
create index if not exists helio_data_job_id_idx  on brs.helio_data("JOB_ID");
create index if not exists ht_opf_job_tasks_job_id_idx  on brs.ht_opf_job_tasks("JOB_ID");
create index if not exists ht_opf_job_tasks_OPF_TASK_ID_idx  on brs.ht_opf_job_tasks("OPF_TASK_ID");
create index if not exists ht_opf_job_tasks_PERFORMED_AT_idx  on brs.ht_opf_job_tasks("PERFORMED_AT");
create index if not exists ht_opf_job_tasks_OPF_ACTION_ID_idx  on brs.ht_opf_job_tasks("OPF_ACTION_ID");
create index if not exists ht_opf_tasks_id_idx  on brs.ht_opf_tasks("ID");
create index if not exists ht_opf_tasks_NAME_idx  on brs.ht_opf_tasks("NAME");
create index if not exists ht_opf_job_tasks_ACTUAL_START_DATE_idx  on brs.ht_opf_job_tasks("ACTUAL_START_DATE");
CREATE INDEX idx_helio_data_lower_product_type_1_34
  ON brs.helio_data (lower("PRODUCT_TYPE"));
CREATE INDEX idx_ht_opf_tasks_name_id_56
  ON brs.ht_opf_tasks ("NAME", "ID");
CREATE INDEX idx_ht_opf_job_tasks_job_action_perf
  ON brs.ht_opf_job_tasks ("JOB_ID", "OPF_ACTION_ID", "PERFORMED_AT", "OPF_TASK_ID");


SET session_replication_role = replica;
DO
$do$
  declare
    x                                  record;
    v_contact_id                       bigint;
    v_project_id                       bigint;
    z                                  record;
    v_install_completed_date           timestamp;
    v_install_start_completed_date     timestamp;
    v_install_scheduled_start_date     timestamp;
    v_batter_installation_completed    timestamp;
    v_battery_installation_start       timestamp;
    v_pip_completed_date               timestamp;
    v_finance_milestone1_complete_date timestamp;
    v_permit_application_start_date    timestamp;
    v_permit_received_completed_date   timestamp;
    v_reroof_start_date                timestamp;
    v_reroof_completed_date            timestamp;
    v_project_status_id                bigint;
    v_loan_or_cash                     boolean default false;
    v_booking_pps_id                   bigint;
    v_tpo_booking_pps_id               bigint;
    v_product_type text;
    v_energized_date date;
    v_pto_date date;
    v_nem_submitted_date date;
    v_nem_approved date;
    v_count bigint;
    v_175_id bigint;
    v_87_id bigint;
    v_3361_id bigint;
    v_19_id bigint;
    v_20_id bigint;
    v_73_id bigint;
    v_3684_id bigint;
    v_168_id bigint;
    v_50_id bigint;
    v_51_id bigint;
    v_22_id bigint;
    v_23_id bigint;
    v_3413_id bigint;
    v_28_id bigint;
    v_3494_id bigint;
    v_3365_id bigint;
    v_13_id bigint;
  BEGIN
    v_count = 0;
    for x in select *
             from brs.helio_data
             where "NAME" not ilike '%test%'

      loop
        v_count =  v_count + 1;
        --raise notice 'v_count %',v_count;
        if v_count = 1000 then
          raise notice 'v_count =%',v_count;
          v_count = 0;
        end if;
        v_contact_id = null;
        v_project_id = null;
        v_project_status_id = null;
        v_product_type = null;
        v_175_id = null;
        v_87_id = null;
        v_3361_id = null;
        v_19_id = null;
        v_20_id = null;
        v_73_id = null;
        v_3684_id = null;
        v_168_id = null;
        v_50_id = null;
        v_51_id = null;
        v_22_id = null;
        v_23_id = null;
        v_3413_id = null;
        v_28_id = null;
        v_3494_id = null;
        v_13_id = null;
        v_3365_id = null;
        SELECT  "PRODUCT_TYPE"
        into v_product_type
        FROM brs.helio_data hd1
        WHERE ("PRODUCT_TYPE" IS NOT NULL
                 and ("PRODUCT_TYPE" like '%\%%' and "PRODUCT_TYPE" not like '%PPA%') or lower("PRODUCT_TYPE") like '%loan%'
          or lower("PRODUCT_TYPE") like '%greensky%'
          or lower("PRODUCT_TYPE") like '%ygrene%'
          or lower("PRODUCT_TYPE") like '%greenpace%'
          or lower("PRODUCT_TYPE") like '%mosaic%'
          or lower("PRODUCT_TYPE") like '%cash%') and
          hd1."JOB_ID" = x."JOB_ID";

        v_loan_or_cash = false;
        if v_product_type is not null then
          v_loan_or_cash = true;
        end if;

        v_energized_date = null;
        v_pto_date = null;
        v_nem_approved = null;
        v_nem_submitted_date = null;
        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_energized_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME"  in ('PTO_UPDATE' ,'NEW_HOME_PTO_UPDATE') and h."PERFORMED_AT" is not null and h."OPF_ACTION_ID" = 1;

        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_pto_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME"  = 'PTO' and h."PERFORMED_AT" is not null and h."OPF_ACTION_ID" = 1;

        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_nem_approved
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME"  = 'NEM_APPROVAL' and h."PERFORMED_AT" is not null and h."OPF_ACTION_ID" = 1;

        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_nem_submitted_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME"  = 'NEM_SUBMITTED' and h."PERFORMED_AT" is not null and h."OPF_ACTION_ID" = 1;

        insert into flow.contact(contact_type_id, first_name, last_name, street1, street2, city, postal_code,
                                 phone, email, mobile, created_by_id, modified_by_id, company_id,
                                 owner_user_position_id, company_state_id,
                                 company_country_id,
                                 object_category_id, ht_migration_id)
        values (1, REGEXP_REPLACE(x."NAME", '\s+\S+$', ''),
                substring(x."NAME" FROM '(\S+)$'), x."STREET",
                '', x."CITY", substring(x."ZIP",1,10), x."CUSTOMER_PHONE", x."CUSTOMER_EMAIL", x."SECONDARY_PHONE", 2384850,
                2384850,
                3, null, (select cs.id
                          from flow.company_state cs
                                 inner join flow.state s on s.id = cs.state_id
                          where s.abbreviation = x."STATE" and cs.company_id = 3), 1, 8, x."JOB_ID")
        returning id into v_contact_id;

        perform flow.set_contact_cfv(v_contact_id, 2384850, 395, 29124::text, true);

        insert into flow.project(contact_id, company_process_id, project_name, created_by_id, modified_by_id,
                                 company_project_status_type_id, street1, city,
                                 postal_code, company_state_id,
                                 company_country_id, cancelled_date, object_category_id, ht_migration_id)
        values (v_contact_id, 1, coalesce(x."CUSTOMER_NAME",x."NAME",'MISSING'), 2384850, 2384850, case
                                                                                                     when x."SUB_STATE_NAME" = 'CANCELED'
                                                                                                       then 234
                                                                                                     when x."SUB_STATE_NAME" = 'JOB IN JEOPARDY'
                                                                                                       then 234
                                                                                                     when  v_energized_date is not null
                                                                                                       then 68
                                                                                                     else 233 end, x."STREET", x."CITY",
                substring(x."ZIP",1,10),
                (select cs.id
                 from flow.company_state cs
                        inner join flow.state s on s.id = cs.state_id
                 where s.abbreviation = x."STATE" and cs.company_id = 3), 1, null, 1, x."JOB_ID")
        returning id,company_project_status_type_id into v_project_id, v_project_status_id;

        insert into flow.project_tag( project_id, tag_id, date_created, date_modified, created_by_id, modified_by_id, archived)
        values(v_project_id,46,now(),now(),2384850,2384850,false);

        insert into brs.project_details(project_id,contact_id,date_modified)
        values(v_project_id,v_contact_id,now());

        perform flow.set_project_cfv(v_project_id, 2384850, 17280, 29124::text, true);
        if x."MAIN_PANEL" = 'MPU' then
          perform flow.set_project_cfv(v_project_id, 2384850, 1061, 856::text, true);
        end if;
        perform flow.set_project_cfv(v_project_id, 2384850, 1054, case
                                                                    when x."RE_ROOF" = 1 then 883::text
          end, true);


        insert into flow.project_process_step(project_id, process_step_id,
                                              company_process_step_status_type_id, date_created,
                                              date_modified, created_by_id,
                                              modified_by_id, archived, main,
                                              process_step_complete_date)
        values (v_project_id, 3876, case when x."STATE_NAME" = 'OPEN' then 1853 when x."INSTALL_COMPLETE_DATE"  < '2023-01-01' then 2 when v_project_status_id != 68 then 1  else  2 end,
                now(), now(), 2384850, 2384850, false, true,
                case when v_project_status_id != 68 then now() end);


        for z in select hot."NAME",
                        case
                          when hojt."OPF_ACTION_ID" = 1 and hojt."PERFORMED_AT" is not null then
                            TO_TIMESTAMP(hojt."PERFORMED_AT" / 1000000000) end as completed_date,
                        TO_TIMESTAMP(hojt."ACTUAL_START_DATE" / 1000000000)           start_date

                 from brs.ht_opf_job_tasks hojt
                        inner join brs.ht_opf_tasks hot on hojt."OPF_TASK_ID" = hot."ID"
                 where hojt."JOB_ID" = x."JOB_ID"
                   and hojt."ACTUAL_START_DATE" is not null
                   and hot."NAME" in ('HOLD','SUSPENDED','JIJ','INITIAL_CUSTOMER_CONTACT','DESIGN_APPROVAL',
                                      'ESCROW_DEPOSIT','DESIGN','NEM_SUBMITTED','NEM_APPROVAL','FINAL_INSPECTION',
                                      'FINANCE_MILESTONE_1','NEW_HOME_PTO_UPDATE','PTO_UPDATE','PTO',
                                      'EXPIRED_FINANCING','HOA_SUBMITTED','HOA_APPROVED','ROOF_REVIEW','MSP_MODIFICATION')
          loop
            v_175_id = null;
            v_87_id = null;
            v_3361_id = null;
            v_19_id = null;
            v_20_id = null;
            v_73_id = null;
            v_3684_id = null;
            v_168_id = null;
            v_50_id = null;
            v_51_id = null;
            v_22_id = null;
            v_23_id = null;
            v_3413_id = null;
            v_28_id = null;
            v_3494_id = null;

            if x."NAME" = 'HOLD' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 112, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date);
            end if;

            if x."NAME" = 'SUSPENDED' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 3659, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date);
            end if;

            if x."NAME" = 'JIJ' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 3419, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date);
            end if;


            if x."NAME" = 'INITIAL_CUSTOMER_CONTACT' and v_loan_or_cash is true then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 4, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date);
            end if;
            if x."NAME" = 'INITIAL_CUSTOMER_CONTACT' and v_loan_or_cash is false then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 3617, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date);
            end if;



            if x."NAME" = 'DESIGN_APPROVAL' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 175, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date) returning id into v_175_id;
            end if;

            --                         insert into flow.project_process_step(project_id, process_step_id,
--                                                               company_process_step_status_type_id, date_created,
--                                                               date_modified, created_by_id,
--                                                               modified_by_id, archived, main)
--                         values (v_project_id, 56, 2, now(), now(), 2384850, 2384850, false, true);
--
--                         insert into flow.project_process_step(project_id, process_step_id,
--                                                               company_process_step_status_type_id, date_created,
--                                                               date_modified, created_by_id,
--                                                               modified_by_id, archived, main)
--                         values (v_project_id, 57, 2, now(), now(), 2384850, 2384850, false, true);
            if x."NAME" = 'ESCROW_DEPOSIT' then --todo fill in first cash payment amount date
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 87, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date) returning id into v_87_id;
            end if;

            if x."NAME" = 'DESIGN' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 3361, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_3361_id;
            end if;
            --                         insert into flow.project_process_step(project_id, process_step_id,
--                                                               company_process_step_status_type_id, date_created,
--                                                               date_modified, created_by_id,
--                                                               modified_by_id, archived, main)
--                         values (v_project_id, 3591, 2, now(), now(), 2384850, 2384850, false, true);

            if x."NAME" = 'NEM_SUBMITTED' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 19, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_19_id;
            end if;
            if x."NAME" = 'NEM_APPROVAL' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 20, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_20_id;
            end if;

            if x."NAME" = 'FINANCE_MILESTONE_1' and v_loan_or_cash is true then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 73, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_73_id;
            end if;
            if x."NAME" = 'FINANCE_MILESTONE_1' and v_loan_or_cash is false then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 3684, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_3684_id;
            end if;

            if x."NAME" = 'FINAL_INSPECTION' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 168, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_168_id;
            end if;

            if x."NAME" = 'PTO' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 50, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_50_id;

              perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 158, v_pto_date::text, true);
            end if;

            if x."NAME" = 'PTO_UPDATE' or x."NAME" = 'NEW_HOME_PTO_UPDATE' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 51, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_51_id;
              perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 202, v_energized_date::text, true);

            end if;

            if x."NAME" = 'HOA_SUBMITTED' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 22, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_22_id;
            end if;
            if x."NAME" = 'HOA_APPROVED' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 23, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_23_id;
            end if;

            if x."NAME" = 'EXPIRED_FINANCING' then --todo fill in credit expiration fields
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 3413, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_3413_id;
            end if;

            if x."NAME" = 'MSP_MODIFICATION' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 28, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_28_id;
            end if;
            --                         if x."NAME" = 'BOM' then
--                             insert into flow.project_process_step(project_id, process_step_id,
--                                                                   company_process_step_status_type_id, date_created,
--                                                                   date_modified, created_by_id,
--                                                                   modified_by_id, archived, main,
--                                                                   process_step_complete_date)
--                             values (v_project_id, 3674, case when z.completed_date is not null then 2 else 1 end,
--                                     z.start_date, now(), 2384850, 2384850, false, true, z.completed_date);
--                         end if;
            if x."NAME" = 'ROOF_REVIEW' then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 3494, case when z.completed_date is not null then 2 else 1 end,
                      z.start_date, now(), 2384850, 2384850, false, true, z.completed_date)returning id into v_3494_id;
            end if;
          end loop;

        v_tpo_booking_pps_id = null;
        v_booking_pps_id = null;
        select id
        into v_booking_pps_id
        from flow.project_process_step pps
        where process_step_id = 4
          and project_id = v_project_id;

        select id
        into v_tpo_booking_pps_id
        from flow.project_process_step pps
        where process_step_id = 3617
          and project_id = v_project_id;

        if v_loan_or_cash  then
          if v_booking_pps_id is null then
            insert into flow.project_process_step(project_id, process_step_id,
                                                  company_process_step_status_type_id, date_created,
                                                  date_modified, created_by_id,
                                                  modified_by_id, archived, main,
                                                  process_step_complete_date)
            values (v_project_id, 4, case when x."STATE_NAME" = 'OPEN' then 1 else 2 end,
                    z.start_date, now(), 2384850, 2384850, false, true, z.completed_date);
          end if;

        else
          if v_tpo_booking_pps_id is null  then
            insert into flow.project_process_step(project_id, process_step_id,
                                                  company_process_step_status_type_id, date_created,
                                                  date_modified, created_by_id,
                                                  modified_by_id, archived, main,
                                                  process_step_complete_date)
            values (v_project_id, 3617, case when x."STATE_NAME" = 'OPEN' then 1 else 2 end,
                    z.start_date, now(), 2384850, 2384850, false, true, z.completed_date);
          end if;
        end if;

        if v_loan_or_cash is true and x."SALES_PACKET_APPROVAL_DATE" is not null then
          insert into flow.project_process_step(project_id, process_step_id,
                                                company_process_step_status_type_id, date_created,
                                                date_modified, created_by_id,
                                                modified_by_id, archived, main,
                                                process_step_complete_date)
          values (v_project_id, 3355,  2 ,
                  x."SALES_PACKET_APPROVAL_DATE", now(), 2384850, 2384850, false, true, x."SALES_PACKET_APPROVAL_DATE");
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19451, x."SYSTEM_SIZE"::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19465, x.financier_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19470, x.interest_rate::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19453, x.panel_brand_id::text, true);
          if x."MODULE_SIZE"::numeric is not null and x."MODULE_SIZE"::numeric > 0 then
            perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19454,
                                               round(x."SYSTEM_SIZE"::numeric * 1000::numeric / x."MODULE_SIZE"::numeric)::text, true);
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19455, round(x."MODULE_SIZE"::numeric)::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19456, x.inverter_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 22036, x.storage_brand_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 30041,
                                             case
                                               when x."BATTERY_NAME" ilike '%Smart Saver%' then 26299::text
                                               when x."BATTERY_NAME" ilike '%A test battery for JT%' then null::text
                                               else 26298::text
                                               end, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 22037, case
                                                                             when x."BATTERY_NAME" ilike '%1 LG Chem RESU10H%'
                                                                               then 9.6::text
                                                                             when x."BATTERY_NAME" ilike '%2 LG Chem RESU10H%'
                                                                               then (9.6::numeric * 2)::text
                                                                             when x."BATTERY_NAME" ilike '%1 Tesla PowerWall 2 AC%'
                                                                               then 13.5::text
                                                                             when x."BATTERY_NAME" ilike '%2 Tesla PowerWall 2 AC%'
                                                                               then (13.5 * 2)::text
                                                                             when x."BATTERY_NAME" ilike '%10kWh%'
                                                                               then 10::text
                                                                             when x."BATTERY_NAME" ilike '%20kWh%'
                                                                               then 20::text
                                                                             when x."BATTERY_NAME" ilike '%15kWh%'
                                                                               then 15::text
                                                                             when x."BATTERY_NAME" ilike '%25kWh%'
                                                                               then 25::text
                                                                             when x."BATTERY_NAME" ilike '%30kWh%'
                                                                               then 30::text
                                                                             when x."BATTERY_NAME" ilike '%35kWh%'
                                                                               then 35::text
                                                                             when x."BATTERY_NAME" ilike '%40kWh%'
                                                                               then 40::text
                                                                             when x."BATTERY_NAME" ilike '%45kWh%'
                                                                               then 45::text
                                                                             when x."BATTERY_NAME" ilike '%55kWh%'
                                                                               then 55::text
            end, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19458, x."ANNUAL_PRODUCTION"::integer::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19469, x.loan_term_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19463, x."CONTRACT_AMOUNT"::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 27006, case
                                                                             when x."BATTERY_NAME" like '1%' then 1::text
                                                                             when x."BATTERY_NAME" like '2%' then 2::text
                                                                             when x."BATTERY_NAME" like 'RETROFIT: 1%'
                                                                               then 1::text
                                                                             when x."BATTERY_NAME" like 'RETROFIT: 2%'
                                                                               then 2::text
                                                                             when x."BATTERY_NAME" like '%10kWh%'
                                                                               then 2::text
                                                                             when x."BATTERY_NAME" like '%15kWh%'
                                                                               then 3::text
                                                                             when x."BATTERY_NAME" like '%20kWh%'
                                                                               then 4::text
                                                                             when x."BATTERY_NAME" like '%25kWh%'
                                                                               then 5::text
                                                                             when x."BATTERY_NAME" like '%30kWh%'
                                                                               then 6::text
                                                                             when x."BATTERY_NAME" like '%35kWh%'
                                                                               then 7::text
                                                                             when x."BATTERY_NAME" like '%40kWh%'
                                                                               then 8::text
                                                                             when x."BATTERY_NAME" like '%45kWh%'
                                                                               then 9::text
                                                                             when x."BATTERY_NAME" like '%55kWh%'
                                                                               then 11::text
            end, true);
        end if;


        if v_loan_or_cash is false and x."SALES_PACKET_APPROVAL_DATE" is not null then
          insert into flow.project_process_step(project_id, process_step_id,
                                                company_process_step_status_type_id, date_created,
                                                date_modified, created_by_id,
                                                modified_by_id, archived, main,
                                                process_step_complete_date)
          values (v_project_id, 3620,  2 ,
                  x."SALES_PACKET_APPROVAL_DATE", now(), 2384850, 2384850, false, true, x."SALES_PACKET_APPROVAL_DATE" );
          if x."SYSTEM_SIZE"::numeric is not null and x."SYSTEM_SIZE"::numeric > 0 then
            perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 26428,
                                               round((x."CONTRACT_AMOUNT"::numeric / (x."SYSTEM_SIZE"::numeric * 1000)),2)::text, true);
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25391, x."SYSTEM_SIZE"::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31411, x.financier_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25388, x.panel_brand_id::text, true);
          if x."MODULE_SIZE"::numeric is not null and x."MODULE_SIZE"::numeric > 0 then
            perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25390,
                                               round(x."SYSTEM_SIZE"::numeric * 1000 / x."MODULE_SIZE"::numeric)::text, true);
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25389, round(x."MODULE_SIZE"::numeric)::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25392, x.inverter_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 30049, x.storage_brand_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 30051, case
                                                                             when x."BATTERY_NAME" ilike '%1 LG Chem RESU10H%'
                                                                               then 9.6::text
                                                                             when x."BATTERY_NAME" ilike '%2 LG Chem RESU10H%'
                                                                               then (9.6 * 2)::text
                                                                             when x."BATTERY_NAME" ilike '%1 Tesla PowerWall 2 AC%'
                                                                               then 13.5::text
                                                                             when x."BATTERY_NAME" ilike '%2 Tesla PowerWall 2 AC%'
                                                                               then (13.5 * 2)::text
                                                                             when x."BATTERY_NAME" ilike '%10kWh%'
                                                                               then 10::text
                                                                             when x."BATTERY_NAME" ilike '%20kWh%'
                                                                               then 20::text
                                                                             when x."BATTERY_NAME" ilike '%15kWh%'
                                                                               then 15::text
                                                                             when x."BATTERY_NAME" ilike '%25kWh%'
                                                                               then 25::text
                                                                             when x."BATTERY_NAME" ilike '%30kWh%'
                                                                               then 30::text
                                                                             when x."BATTERY_NAME" ilike '%35kWh%'
                                                                               then 35::text
                                                                             when x."BATTERY_NAME" ilike '%40kWh%'
                                                                               then 40::text
                                                                             when x."BATTERY_NAME" ilike '%45kWh%'
                                                                               then 45::text
                                                                             when x."BATTERY_NAME" ilike '%55kWh%'
                                                                               then 55::text
            end, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25370, x."ANNUAL_PRODUCTION"::integer::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31108, x."CONTRACT_AMOUNT"::text, true);

        end if;

        v_finance_milestone1_complete_date = null;
        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_finance_milestone1_complete_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'FINANCE_MILESTONE_1'
        order by h."ACTUAL_START_DATE" desc;
        v_install_scheduled_start_date = null;
        select TO_TIMESTAMP(h."ACTUAL_START_DATE" / 1000000000) start_date
        into v_install_scheduled_start_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'INSTALL_SCHEDULED'
        order by h."ACTUAL_START_DATE" desc;
        v_install_start_completed_date = null;
        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_install_start_completed_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'INSTALL_START'
        order by h."ACTUAL_START_DATE" desc;
        v_install_completed_date = null;
        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_install_completed_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'INSTALL_COMPLETE'
        order by h."ACTUAL_START_DATE" desc;
        v_pip_completed_date = null;
        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_pip_completed_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'PIP_APPROVED'
        order by h."ACTUAL_START_DATE" desc;
        v_battery_installation_start = null;
        v_batter_installation_completed = null;
        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date,
               TO_TIMESTAMP(h."ACTUAL_START_DATE" / 1000000000)           start_date
        into v_battery_installation_start,v_batter_installation_completed
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'BATTERY_INSTALLATION'
        order by h."ACTUAL_START_DATE" desc;

        if v_install_scheduled_start_date is not null or v_install_start_completed_date is not null or
           v_battery_installation_start is not null then

          insert into flow.project_process_step(project_id, process_step_id,
                                                company_process_step_status_type_id, date_created,
                                                date_modified, created_by_id,
                                                modified_by_id, archived, main,
                                                process_step_complete_date)
          values (v_project_id, 3365, case when x."INSTALL_COMPLETE_DATE" is not null then 2 else 1 end,
                  coalesce(v_install_scheduled_start_date,v_install_start_completed_date,v_battery_installation_start), now(), 2384850, 2384850, false, true,
                  x."INSTALL_COMPLETE_DATE")
          returning id into v_3365_id;
        end if;
        if v_install_start_completed_date is not null  then
          insert into flow.project_process_step_event(project_process_step_id, process_step_event_id,
                                                      company_event_status_type_id,
                                                      start_time, end_time, date_created, date_modified,
                                                      created_by_id,
                                                      modified_by_id, archived, cancelled_date,
                                                      completed_date,
                                                      scheduled_date, save_version)
          values (v_3365_id, 22, case when v_install_completed_date is not null then 3 else 1 end,
                  v_install_start_completed_date, null, v_install_scheduled_start_date, now(), 2384850,
                  2384850, false, null, v_install_completed_date, v_install_start_completed_date, 0);
        end if;


        if v_battery_installation_start is not null then
          insert into flow.project_process_step_event(project_process_step_id, process_step_event_id,
                                                      company_event_status_type_id,
                                                      start_time, end_time, date_created, date_modified,
                                                      created_by_id,
                                                      modified_by_id, archived, cancelled_date,
                                                      completed_date,
                                                      scheduled_date, save_version)
          values (v_3365_id, 282, case when v_batter_installation_completed is not null then 3 else 1 end,
                  v_battery_installation_start, null, v_battery_installation_start, now(), 2384850,
                  2384850, false, null, v_batter_installation_completed, v_battery_installation_start, 0);
        end if;


        v_permit_application_start_date = null;
        select TO_TIMESTAMP(h."ACTUAL_START_DATE" / 1000000000) start_date
        into v_permit_application_start_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'PERMIT_APPLICATION'
        order by h."ACTUAL_START_DATE" desc;

        v_permit_received_completed_date = null;
        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_permit_received_completed_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'PERMIT_RECEIVED'
        order by h."ACTUAL_START_DATE" desc;

        if v_permit_application_start_date is not null then
          insert into flow.project_process_step(project_id, process_step_id,
                                                company_process_step_status_type_id, date_created,
                                                date_modified, created_by_id,
                                                modified_by_id, archived, main,
                                                process_step_complete_date)
          values (v_project_id, 13, case when v_permit_received_completed_date is not null then 2 else 1 end,
                  v_permit_application_start_date, now(), 2384850, 2384850, false, true,
                  v_permit_received_completed_date)
          returning id into v_13_id;
        end if;

        v_reroof_start_date = null;
        select TO_TIMESTAMP(h."ACTUAL_START_DATE" / 1000000000) start_date
        into v_reroof_start_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'REROOF'
        order by h."ACTUAL_START_DATE" desc;

        v_reroof_completed_date = null;
        select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as completed_date
        into v_reroof_completed_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = x."JOB_ID"
          and t."NAME" = 'REROOF_COMPLETE'
        order by h."ACTUAL_START_DATE" desc;


        if v_reroof_start_date is not null then
          insert into flow.project_process_step(project_id, process_step_id,
                                                company_process_step_status_type_id, date_created,
                                                date_modified, created_by_id,
                                                modified_by_id, archived, main,
                                                process_step_complete_date)
          values (v_project_id, 140, case when v_reroof_completed_date is not null then 2 else 1 end,
                  v_reroof_start_date, now(), 2384850, 2384850, false, true,
                  v_reroof_completed_date);
        end if;

        if v_loan_or_cash is true then
          if v_finance_milestone1_complete_date is not null then
            if v_73_id is null then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 73, 2,
                      now(), now(), 2384850, 2384850, false, true, now());
            end if;
            perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 147, v_finance_milestone1_complete_date::text,
                                               true);
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 40, x."SYSTEM_SIZE"::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 460, x.financier_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 41, x.panel_brand_id::text, true);
          if x."MODULE_SIZE"::numeric is not null and x."MODULE_SIZE"::numeric > 0 then
            perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 42,
                                               round(x."SYSTEM_SIZE"::numeric * 1000::numeric / x."MODULE_SIZE"::numeric)::text, true);
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 43, round(x."MODULE_SIZE"::numeric)::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 44, x.inverter_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 22192, x.storage_brand_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 22194, case
                                                                             when x."BATTERY_NAME" ilike '%1 LG Chem RESU10H%'
                                                                               then 9.6::text
                                                                             when x."BATTERY_NAME" ilike '%2 LG Chem RESU10H%'
                                                                               then (9.6 * 2)::text
                                                                             when x."BATTERY_NAME" ilike '%1 Tesla PowerWall 2 AC%'
                                                                               then 13.5::text
                                                                             when x."BATTERY_NAME" ilike '%2 Tesla PowerWall 2 AC%'
                                                                               then (13.5 * 2)::text
                                                                             when x."BATTERY_NAME" ilike '%10kWh%'
                                                                               then 10::text
                                                                             when x."BATTERY_NAME" ilike '%20kWh%'
                                                                               then 20::text
                                                                             when x."BATTERY_NAME" ilike '%15kWh%'
                                                                               then 15::text
                                                                             when x."BATTERY_NAME" ilike '%25kWh%'
                                                                               then 25::text
                                                                             when x."BATTERY_NAME" ilike '%30kWh%'
                                                                               then 30::text
                                                                             when x."BATTERY_NAME" ilike '%35kWh%'
                                                                               then 35::text
                                                                             when x."BATTERY_NAME" ilike '%40kWh%'
                                                                               then 40::text
                                                                             when x."BATTERY_NAME" ilike '%45kWh%'
                                                                               then 45::text
                                                                             when x."BATTERY_NAME" ilike '%55kWh%'
                                                                               then 55::text
            end, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 11, x."CONTRACT_DATE"::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 58, x.loan_term_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 49, x."CONTRACT_AMOUNT"::text, true);
        else
          if v_finance_milestone1_complete_date is not null then
            if v_3684_id is null then
              insert into flow.project_process_step(project_id, process_step_id,
                                                    company_process_step_status_type_id, date_created,
                                                    date_modified, created_by_id,
                                                    modified_by_id, archived, main,
                                                    process_step_complete_date)
              values (v_project_id, 3684, 2,
                      now(), now(), 2384850, 2384850, false, true, now());
            end if;
            perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 26803, v_finance_milestone1_complete_date::text,
                                               true);
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25361, x."CONTRACT_DATE"::text, true);
          if  x."SYSTEM_SIZE"::numeric is not null and x."SYSTEM_SIZE"::numeric > 0 then
            perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 26423,
                                               round((x."CONTRACT_AMOUNT"::numeric / (x."SYSTEM_SIZE"::numeric * 1000)),2)::text, true);
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25365, x."SYSTEM_SIZE"::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31410, x.financier_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25363, x.panel_brand_id::text, true);
          if x."MODULE_SIZE"::numeric is not null and x."MODULE_SIZE"::numeric > 0 then
            perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25364,
                                               round(x."SYSTEM_SIZE"::numeric * 1000 / x."MODULE_SIZE"::numeric)::text, true);
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25366, round(x."MODULE_SIZE"::numeric)::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25362, x.inverter_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 30046, x.storage_brand_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 30048, case
                                                                             when x."BATTERY_NAME" ilike '%1 LG Chem RESU10H%'
                                                                               then 9.6::text
                                                                             when x."BATTERY_NAME" ilike '%2 LG Chem RESU10H%'
                                                                               then (9.6 * 2)::text
                                                                             when x."BATTERY_NAME" ilike '%1 Tesla PowerWall 2 AC%'
                                                                               then 13.5::text
                                                                             when x."BATTERY_NAME" ilike '%2 Tesla PowerWall 2 AC%'
                                                                               then (13.5 * 2)::text
                                                                             when x."BATTERY_NAME" ilike '%10kWh%'
                                                                               then 10::text
                                                                             when x."BATTERY_NAME" ilike '%20kWh%'
                                                                               then 20::text
                                                                             when x."BATTERY_NAME" ilike '%15kWh%'
                                                                               then 15::text
                                                                             when x."BATTERY_NAME" ilike '%25kWh%'
                                                                               then 25::text
                                                                             when x."BATTERY_NAME" ilike '%30kWh%'
                                                                               then 30::text
                                                                             when x."BATTERY_NAME" ilike '%35kWh%'
                                                                               then 35::text
                                                                             when x."BATTERY_NAME" ilike '%40kWh%'
                                                                               then 40::text
                                                                             when x."BATTERY_NAME" ilike '%45kWh%'
                                                                               then 45::text
                                                                             when x."BATTERY_NAME" ilike '%55kWh%'
                                                                               then 55::text
            end, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 25367, x."ANNUAL_PRODUCTION"::integer::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31107, x."CONTRACT_AMOUNT"::text, true);
        end if;

        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31434, x."JOB_ID"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31435, x."CHANNEL_NAME"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31457, x."STATE_NAME"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31458, x."SUB_STATE_NAME"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31447, x."CONTRACT_DATE"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31453, x."SALES_PACKET_APPROVAL_DATE"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31449, TO_TIMESTAMP(x."PIP_APPROVED" / 1000000000)::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31450, x."INSTALL_COMPLETE_DATE"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31451, v_finance_milestone1_complete_date::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31452, TO_TIMESTAMP(x."INSPECTION_COMPLETED_DATE" / 1000000000)::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31454, v_pto_date::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31455, v_energized_date::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31436, x."SYSTEM_SIZE"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31437, x.panel_brand_id::text, true);
        if x."MODULE_SIZE"::numeric is not null and x."MODULE_SIZE"::numeric > 0 then
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31438, round(x."SYSTEM_SIZE"::numeric * 1000 / x."MODULE_SIZE"::numeric)::text, true);
        end if;
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31439, x."MODULE_SIZE"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31441, x.storage_brand_id::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31442, case
                                                                           when x."BATTERY_NAME" ilike '%1 LG Chem RESU10H%'
                                                                             then 9.6::text
                                                                           when x."BATTERY_NAME" ilike '%2 LG Chem RESU10H%'
                                                                             then (9.6 * 2)::text
                                                                           when x."BATTERY_NAME" ilike '%1 Tesla PowerWall 2 AC%'
                                                                             then 13.5::text
                                                                           when x."BATTERY_NAME" ilike '%2 Tesla PowerWall 2 AC%'
                                                                             then (13.5 * 2)::text
                                                                           when x."BATTERY_NAME" ilike '%10kWh%'
                                                                             then 10::text
                                                                           when x."BATTERY_NAME" ilike '%20kWh%'
                                                                             then 20::text
                                                                           when x."BATTERY_NAME" ilike '%15kWh%'
                                                                             then 15::text
                                                                           when x."BATTERY_NAME" ilike '%25kWh%'
                                                                             then 25::text
                                                                           when x."BATTERY_NAME" ilike '%30kWh%'
                                                                             then 30::text
                                                                           when x."BATTERY_NAME" ilike '%35kWh%'
                                                                             then 35::text
                                                                           when x."BATTERY_NAME" ilike '%40kWh%'
                                                                             then 40::text
                                                                           when x."BATTERY_NAME" ilike '%45kWh%'
                                                                             then 45::text
                                                                           when x."BATTERY_NAME" ilike '%55kWh%'
                                                                             then 55::text
          end, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31440, x."ANNUAL_PRODUCTION"::integer::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31446, x."PRODUCT_TYPE"::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31443, x."CONTRACT_AMOUNT"::text, true);
        if x."SYSTEM_SIZE"::numeric is not null and x."SYSTEM_SIZE"::numeric > 0 then
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31444, round((x."CONTRACT_AMOUNT"::numeric / (x."SYSTEM_SIZE"::numeric * 1000)),2)::text, true);
        end if;
        perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 31445, x.financier_id::text, true);

        if v_nem_submitted_date is not null then
          if v_19_id is null then
            insert into flow.project_process_step(project_id, process_step_id,
                                                  company_process_step_status_type_id, date_created,
                                                  date_modified, created_by_id,
                                                  modified_by_id, archived, main,
                                                  process_step_complete_date)
            values (v_project_id, 19, 2,
                    now(), now(), 2384850, 2384850, false, true, now());
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 113, v_nem_submitted_date::text, true);
        end if;

        if v_nem_approved is not null then
          if v_20_id is null then
            insert into flow.project_process_step(project_id, process_step_id,
                                                  company_process_step_status_type_id, date_created,
                                                  date_modified, created_by_id,
                                                  modified_by_id, archived, main,
                                                  process_step_complete_date)
            values (v_project_id, 20, 2,
                    now(), now(), 2384850, 2384850, false, true, now());
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 114, v_nem_approved::text, true);
        end if;

        if x."SALES_PACKET_APPROVAL_DATE" is not null then
          if v_3361_id is null then
            insert into flow.project_process_step(project_id, process_step_id,
                                                  company_process_step_status_type_id, date_created,
                                                  date_modified, created_by_id,
                                                  modified_by_id, archived, main,
                                                  process_step_complete_date)
            values (v_project_id, 3361, 2,
                    now(), now(), 2384850, 2384850, false, true, now());
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 19622, x."SALES_PACKET_APPROVAL_DATE"::text, true);
        end if;

        if x."SALES_PACKET_APPROVAL_DATE" is not null then
          if v_175_id is null then
            insert into flow.project_process_step(project_id, process_step_id,
                                                  company_process_step_status_type_id, date_created,
                                                  date_modified, created_by_id,
                                                  modified_by_id, archived, main,
                                                  process_step_complete_date)
            values (v_project_id, 175, 2,
                    now(), now(), 2384850, 2384850, false, true, now());
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 1251, x."SALES_PACKET_APPROVAL_DATE"::text, true);
        end if;

        --                 if x."PIP_APPROVED" is not null then
--                     if v_13_id is null then
--                         insert into flow.project_process_step(project_id, process_step_id,
--                                                               company_process_step_status_type_id, date_created,
--                                                               date_modified, created_by_id,
--                                                               modified_by_id, archived, main,
--                                                               process_step_complete_date)
--                         values (v_project_id, 13, 2,
--                                 now(), now(), 2384850, 2384850, false, true, now());
--                     end if;
--                     perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 22766, TO_TIMESTAMP(x."PIP_APPROVED" / 1000000000)::text, true);
--                 end if;

        if x."INSTALL_COMPLETE_DATE" is not null then
          if v_3365_id is null then
            insert into flow.project_process_step(project_id, process_step_id,
                                                  company_process_step_status_type_id, date_created,
                                                  date_modified, created_by_id,
                                                  modified_by_id, archived, main,
                                                  process_step_complete_date)
            values (v_project_id, 3365, 2,
                    now(), now(), 2384850, 2384850, false, true, now());
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 21009, x."INSTALL_COMPLETE_DATE"::text, true);
        end if;

        if x."INSPECTION_COMPLETED_DATE" is not null then
          if v_168_id is null then
            insert into flow.project_process_step(project_id, process_step_id,
                                                  company_process_step_status_type_id, date_created,
                                                  date_modified, created_by_id,
                                                  modified_by_id, archived, main,
                                                  process_step_complete_date)
            values (v_project_id, 168, 2,
                    now(), now(), 2384850, 2384850, false, true, now());
          end if;
          perform flow.set_pps_cfv_no_checks(v_project_id, 2384850, 22722, TO_TIMESTAMP(x."INSPECTION_COMPLETED_DATE" / 1000000000)::text, true);
        end if;

      end loop;
  end
$do$;

with update_data as (
  select p.id,pcfv.int_value,lov.name
  from flow.project p
         inner join flow.project_custom_field_value pcfv on pcfv.project_id = p.id
         inner join flow.list_of_value lov on lov.id = pcfv.int_value
  where pcfv.custom_field_group_assignment_id = 17280 and
    p.ht_migration_id is not null
)
update brs.project_details pd
set source = int_value,
    source_name = name
from update_data ud
where ud.id = pd.project_id;


with update_data as (
  select p.id,pcfv.int_value,lov.name
  from flow.project p
         inner join flow.project_custom_field_value pcfv on pcfv.project_id = p.id
         inner join flow.list_of_value lov on lov.id = pcfv.int_value
  where pcfv.custom_field_group_assignment_id = 1061 and
    p.ht_migration_id is not null
)
update brs.project_details pd
set main_panel_upgrade_required_outsource = int_value,
    main_panel_upgrade_required_outsource_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,pcfv.int_value,lov.name
  from flow.project p
         inner join flow.project_custom_field_value pcfv on pcfv.project_id = p.id
         inner join flow.list_of_value lov on lov.id = pcfv.int_value
  where pcfv.custom_field_group_assignment_id = 1054 and
    p.ht_migration_id is not null
)
update brs.project_details pd
set reroof_required = int_value,
    reroof_required_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 460
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set primary_financier = int_value,
    primary_financier_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 31410
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set primary_financier = int_value,
    primary_financier_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19465
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set primary_financier = int_value,
    primary_financier_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 31411
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set primary_financier = int_value,
    primary_financier_name = name
from update_data ud
where ud.id = pd.project_id;


with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 22192
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set storage_brand = int_value,
    storage_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 30046
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set storage_brand = int_value,
    storage_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 22036
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set storage_brand = int_value,
    storage_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 30049
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set storage_brand = int_value,
    storage_brand_name = name
from update_data ud
where ud.id = pd.project_id;


with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 44
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set inverter_brand = int_value,
    inverter_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25362
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set inverter_brand = int_value,
    inverter_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19456
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set inverter_brand = int_value,
    inverter_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25392
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set inverter_brand = int_value,
    inverter_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 41
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_brand = int_value,
    panel_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25363
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_brand = int_value,
    panel_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19453
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_brand = int_value,
    panel_brand_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25388
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_brand = int_value,
    panel_brand_name = name
from update_data ud
where ud.id = pd.project_id;


with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 58
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set loan_term = int_value,
    loan_term_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25368
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set lease_term = int_value,
    lease_term_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19469
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set loan_term = int_value,
    loan_term_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value,lov.name
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25400
         inner join flow.list_of_value lov on lov.id = ppscfv.int_value
  where p.ht_migration_id is not null
)
update brs.project_details pd
set lease_term = int_value,
    lease_term_name = name
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 22194
  where p.ht_migration_id is not null
)
update brs.project_details pd
set storage_size_kwh = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 30048

  where p.ht_migration_id is not null
)
update brs.project_details pd
set storage_size_kwh = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 22037

  where p.ht_migration_id is not null
)
update brs.project_details pd
set storage_size_kwh = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 30051

  where p.ht_migration_id is not null
)
update brs.project_details pd
set storage_size_kwh = numeric_value
from update_data ud
where ud.id = pd.project_id;


with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 40
  where p.ht_migration_id is not null
)
update brs.project_details pd
set system_size = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25365

  where p.ht_migration_id is not null
)
update brs.project_details pd
set system_size = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19451

  where p.ht_migration_id is not null
)
update brs.project_details pd
set system_size = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25391

  where p.ht_migration_id is not null
)
update brs.project_details pd
set system_size = numeric_value
from update_data ud
where ud.id = pd.project_id;


with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 49
  where p.ht_migration_id is not null
)
update brs.project_details pd
set total_system_price = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 31107

  where p.ht_migration_id is not null
)
update brs.project_details pd
set total_system_price = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19463

  where p.ht_migration_id is not null
)
update brs.project_details pd
set total_system_price = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 31108

  where p.ht_migration_id is not null
)
update brs.project_details pd
set total_system_price = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 42
  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_quantity = int_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25364

  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_quantity = int_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19454

  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_quantity = int_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25390

  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_quantity = int_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 43
  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_watts = int_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3617
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25366

  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_watts = int_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19455

  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_watts = int_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.int_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3620
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 25389

  where p.ht_migration_id is not null
)
update brs.project_details pd
set panel_watts = int_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 48
  where p.ht_migration_id is not null
)
update brs.project_details pd
set interest_rate = numeric_value
from update_data ud
where ud.id = pd.project_id;


with update_data as (
  select p.id,ppscfv.numeric_value
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3355
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19470

  where p.ht_migration_id is not null
)
update brs.project_details pd
set interest_rate = numeric_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 175
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 1251

  where p.ht_migration_id is not null
)
update brs.project_details pd
set final_design_complete_date = date_value,
    final_design_complete_date_ppscfv_id = ppscfv_id
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3361
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 19622

  where p.ht_migration_id is not null
)
update brs.project_details pd
set permit_pack_complete = date_value,
    permit_pack_complete_ppscfv_id = ppscfv_id
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 13
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 22766

  where p.ht_migration_id is not null
)
update brs.project_details pd
set permit_approved_date = date_value,
    permit_approved_date_cfv_id = ppscfv_id,
    permit_approved_date_ppscfv_id = ppscfv_id
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 20
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 114

  where p.ht_migration_id is not null
)
update brs.project_details pd
set interconnection_application_approved_date = date_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3365
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 21009

  where p.ht_migration_id is not null
)
update brs.project_details pd
set substantial_completion_date = date_value,
    substantial_completion_date_cfv_id = ppscfv_id,
    substantial_completion_date_ppsecfv_id = ppscfv_id
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 73
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 147

  where p.ht_migration_id is not null
)
update brs.project_details pd
set substantial_completion_approved_date = date_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3684
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 26803

  where p.ht_migration_id is not null
)
update brs.project_details pd
set substantial_completion_approved_date = date_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 168
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 22722

  where p.ht_migration_id is not null
)
update brs.project_details pd
set ahj_final_inspection_verified = date_value,
    ahj_final_inspection_verified_ppsecfv_id = ppscfv_id
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 50
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 158

  where p.ht_migration_id is not null
)
update brs.project_details pd
set pto_verified = date_value
from update_data ud
where ud.id = pd.project_id;

with update_data as (
  select p.id,ppscfv.date_value,ppscfv.id as ppscfv_id
  from flow.project p
         inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 51
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id = 202

  where p.ht_migration_id is not null
)
update brs.project_details pd
set energized_date = date_value
from update_data ud
where ud.id = pd.project_id;

SET session_replication_role = default;


SELECT
  (SELECT count(1)
   FROM flow.project p
   WHERE ht_migration_id IS NOT NULL) AS albatross_count,
  (SELECT count(1)
   FROM brs.helio_data
   WHERE "NAME" NOT ILIKE '%test%') AS helio_count;

SELECT ht_migration_id,project_name,
       p.id as project_id,
       company_project_status_type_id,
       hd."STATE_NAME",
       hd."SUB_STATE_NAME",
       hd."JOB_ID",
       ppscfv.text_value as a_job_id,
       hd."CHANNEL_NAME",
       ppscfv1.text_value as a_channel_name,
       hd."CONTRACT_DATE",
       ppscfv2.date_value as a_hic_signed,
       hd."SALES_PACKET_APPROVAL_DATE",
       ppscfv3.date_value as a_fdc_date,
       hd."INSTALL_COMPLETE_DATE",
       ppscfv5.date_value a_sc_date,
       ( select case
                  when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                    TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as finance_milestone_1_complete_date
         from brs.ht_opf_job_tasks h
                inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
         where h."JOB_ID" = hd."JOB_ID"
           and t."NAME" = 'FINANCE_MILESTONE_1'
         order by h."ACTUAL_START_DATE" desc limit 1),
       ppscfv6.date_value as a_funding_verified,
       hd."INSPECTION_COMPLETED_DATE",
       ppscfv7.date_value as a_fiv_date,
       (select case
                 when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                   TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as pto_task_completed_date
        from brs.ht_opf_job_tasks h
               inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
        where h."JOB_ID" = hd."JOB_ID"
          and t."NAME"  = 'PTO' and h."PERFORMED_AT" is not null and h."OPF_ACTION_ID" = 1 limit 1),
       ppscfv8.date_value as a_pto_date,
       ( select case
                  when h."OPF_ACTION_ID" = 1 and h."PERFORMED_AT" is not null then
                    TO_TIMESTAMP(h."PERFORMED_AT" / 1000000000) end as pto_update_task_completed_date
         from brs.ht_opf_job_tasks h
                inner join brs.ht_opf_tasks t on h."OPF_TASK_ID" = t."ID"
         where h."JOB_ID" = hd."JOB_ID"
           and t."NAME"  in ('PTO_UPDATE' ,'NEW_HOME_PTO_UPDATE') and h."PERFORMED_AT" is not null and h."OPF_ACTION_ID" = 1 limit 1),
       ppscfv9.date_value as a_energized_date,
       hd."SYSTEM_SIZE",
       ppscfv10.numeric_value as a_system_size,
       hd."MODULE_MANUFACTURER",
       lov.name as a_panel_brand,
       ppscfv12.numeric_value as a_panel_quantity,
       hd."MODULE_SIZE",
       ppscfv13.numeric_value as a_panel_watts,
       hd."BATTERY_NAME",
       lov1.name as a_storage_brand,
       ppscfv15.numeric_value as a_storage_size,
       hd."ANNUAL_PRODUCTION",
       ppscfv16.numeric_value as a_first_year_production_estimate,
       hd."PRODUCT_TYPE",
       ppscfv17.text_value as a_product_type,
       hd."CONTRACT_AMOUNT",
       ppscfv18.numeric_value as a_total_system_price,
       ppscfv19.numeric_value as a_funded_price_per_watt,
       lov2.name as a_primary_financier
FROM flow.project p
       left join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 3876
       left join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 31434
       left join flow.project_process_step_custom_field_value ppscfv1 on ppscfv1.project_process_step_id = pps.id and ppscfv1.custom_field_group_assignment_id = 31435
       left join flow.project_process_step_custom_field_value ppscfv2 on ppscfv2.project_process_step_id = pps.id and ppscfv2.custom_field_group_assignment_id = 31447
       left join flow.project_process_step_custom_field_value ppscfv3 on ppscfv3.project_process_step_id = pps.id and ppscfv3.custom_field_group_assignment_id = 31453
  --left join flow.project_process_step_custom_field_value ppscfv4 on ppscfv4.project_process_step_id = pps.id and ppscfv4.custom_field_group_assignment_id = 31449
       left join flow.project_process_step_custom_field_value ppscfv5 on ppscfv5.project_process_step_id = pps.id and ppscfv5.custom_field_group_assignment_id = 31450
       left join flow.project_process_step_custom_field_value ppscfv6 on ppscfv6.project_process_step_id = pps.id and ppscfv6.custom_field_group_assignment_id = 31451
       left join flow.project_process_step_custom_field_value ppscfv7 on ppscfv7.project_process_step_id = pps.id and ppscfv7.custom_field_group_assignment_id = 31452
       left join flow.project_process_step_custom_field_value ppscfv8 on ppscfv8.project_process_step_id = pps.id and ppscfv8.custom_field_group_assignment_id = 31454
       left join flow.project_process_step_custom_field_value ppscfv9 on ppscfv9.project_process_step_id = pps.id and ppscfv9.custom_field_group_assignment_id = 31455
       left join flow.project_process_step_custom_field_value ppscfv10 on ppscfv10.project_process_step_id = pps.id and ppscfv10.custom_field_group_assignment_id = 31436
       left join flow.project_process_step_custom_field_value ppscfv11 on ppscfv11.project_process_step_id = pps.id and ppscfv11.custom_field_group_assignment_id = 31437
       left join flow.list_of_value lov on lov.id = ppscfv11.int_value
       left join flow.project_process_step_custom_field_value ppscfv12 on ppscfv12.project_process_step_id = pps.id and ppscfv12.custom_field_group_assignment_id = 31438
       left join flow.project_process_step_custom_field_value ppscfv13 on ppscfv13.project_process_step_id = pps.id and ppscfv13.custom_field_group_assignment_id = 31439
       left join flow.project_process_step_custom_field_value ppscfv14 on ppscfv14.project_process_step_id = pps.id and ppscfv14.custom_field_group_assignment_id = 31441
       left join flow.list_of_value lov1 on lov1.id = ppscfv14.int_value
       left join flow.project_process_step_custom_field_value ppscfv15 on ppscfv15.project_process_step_id = pps.id and ppscfv15.custom_field_group_assignment_id = 31442
       left join flow.project_process_step_custom_field_value ppscfv16 on ppscfv16.project_process_step_id = pps.id and ppscfv16.custom_field_group_assignment_id = 31440
       left join flow.project_process_step_custom_field_value ppscfv17 on ppscfv17.project_process_step_id = pps.id and ppscfv17.custom_field_group_assignment_id = 31446
       left join flow.project_process_step_custom_field_value ppscfv18 on ppscfv18.project_process_step_id = pps.id and ppscfv18.custom_field_group_assignment_id = 31443
       left join flow.project_process_step_custom_field_value ppscfv19 on ppscfv19.project_process_step_id = pps.id and ppscfv19.custom_field_group_assignment_id = 31444
       left join flow.project_process_step_custom_field_value ppscfv20 on ppscfv20.project_process_step_id = pps.id and ppscfv20.custom_field_group_assignment_id = 31445
       left join flow.list_of_value lov2 on lov2.id = ppscfv20.int_value
       left join brs.helio_data hd on hd."JOB_ID" = p.ht_migration_id
WHERE ht_migration_id IS NOT NULL ;



