SET session_replication_role = replica;
CREATE INDEX if not exists sunpower_s3_files_archive_link ON sunpower_migration.sunpower_s3_files USING GIN ((metadata ->> 'archive_link') gin_trgm_ops);
CREATE INDEX if not exists sunpower_s3_files_aws_file_name ON sunpower_migration.sunpower_s3_files USING GIN ((metadata ->> 'aws_file_name') gin_trgm_ops);

--todo delete this it's not for migration
-- CREATE INDEX if not exists attachment_nw_migration_id ON flow.attachment (nw_migration_id);
-- delete from  flow.project_attachment pa
-- where pa.attachment_id in (select id from flow.attachment a where nw_migration_id is not null);
--
-- delete from flow.attachment a
-- where nw_migration_id is not null;

with insert_attachment as (
  insert into flow.attachment(attachment_type_id, company_id, filename, content_type,
                              s3_key, size, date_created, created_by_id, modified_by_id,
                              uuid, display_name,nw_migration_id,project_migration_id)
    (SELECT 1024,  --49163
            3,
            a.name,
            ss3f.content_type,
            ss3f.albatross_s3_key,
            ss3f.size,
            now(),
            2384850,
            2384850,
            uuid_generate_v4(),
            a.name,
            a.id,
            p.id
     from  brs.SFDC_CONTENT_VERSION_ARCHIVE_LINKS l
             join brs.CONTENT_VERSION cv on cv.ID  = l.CONTENT_VERSION_ID
             left join brs.CONTENT_DOCUMENT cd on cd.ID = cv.CONTENT_DOCUMENT_ID
             left join brs.CONTENT_DOCUMENT_LINK cdl on cdl.CONTENT_DOCUMENT_ID = cd.ID
             left join brs.DS_Agreement_c a on a.id = cdl.LINKED_ENTITY_ID
             left join brs.QUOTE q on q.id = a.quote_c
             left join brs.ACCOUNT acct on acct.id = a.account_c
             inner join brs.RESIDENTIAL_PROJECT_C rp on rp.account_c = acct.id
             inner join flow.project p on p.nw_migration_id = rp.id
             inner join sunpower_migration.sunpower_s3_files ss3f on metadata ->> 'archive_link' =substr(l.ARCHIVE_LINK,64)
     where a.Envelope_Status_c = 'Signed'  and  cd.title like '%Completed%'
       and rp.record_type_id = '01234000000UQPbAAO'
     and a.name is not null)returning *
)
insert into flow.project_attachment(attachment_id, project_id, created_by_id, modified_by_id)
  (select ia.id,ia.project_migration_id,2384850,2384850
   from insert_attachment ia);

with insert_attachment as (
  insert into flow.attachment(attachment_type_id, company_id, filename, content_type,
                              s3_key, size, date_created, created_by_id, modified_by_id,
                              uuid, display_name,nw_migration_id,project_migration_id)
    (SELECT 1000, --3656
            3,
            attachment.name,
            ss3f.content_type,
            ss3f.albatross_s3_key,
            ss3f.size,
            now(),
            2384850,
            2384850,
            uuid_generate_v4(),
            attachment.name,
            attachment.id,
            p.id
     FROM brs.SFDC_ATTACHMENTS_ARCHIVE_LINKS archive
            JOIN brs.ATTACHMENT attachment ON attachment.id = archive.attachment_id
            JOIN brs.NH_CONTRACTS_C nh_contract ON nh_contract.attachment_id_c = attachment.ID
            inner JOIN brs.NH_COMMUNITY_C nh_comm ON nh_comm.id = nh_contract.nh_community_c
            inner join flow.project p on p.nw_migration_id = nh_comm.id
            inner join sunpower_migration.sunpower_s3_files ss3f on metadata ->> 'archive_link' = archive.archive_link
     WHERE archive.attachment_id = attachment.id
     and attachment.name is not null) returning * )
insert into flow.project_attachment(attachment_id, project_id, created_by_id, modified_by_id)
  (select ia.id,ia.project_migration_id,2384850,2384850
   from insert_attachment ia);

with insert_attachment as (
  insert into flow.attachment (attachment_type_id, company_id, filename, content_type,
                               s3_key, size, date_created, created_by_id, modified_by_id,
                               uuid, display_name, nw_migration_id, project_migration_id)
    (
      SELECT case  --797215
               when doc.name = 'Builder Plot Plan' then 1002
               when doc.name = 'BOM' then 1001
               when doc.name = 'Design/Permit Package' then 1004
               when doc.name = 'Issued Solar Permit' then 1005
               when doc.name = 'Final Solar Permit' then 1006
               when doc.name = 'Designs Distributed - Email Confirmation' then 1025
               when doc.name = 'Shade Analysis' then 1008
               when doc.name = 'Rebate Claim Approval' then 1026
               when doc.name = 'HERS Certificate' then 1027
               when doc.name = 'Rebate Claim Form' then 1026
               when doc.name = 'Pre-comm checklist' then 1007
               when doc.name = 'Builder WO' then 1018
               when doc.name = 'Preliminary IC Approval' then 1010
               when doc.name = 'Final Inspection Card' then 56
               when doc.name = 'PG&E Interconnection Agreement' then 1011
               when doc.name = 'CIIF' then 1003
               when doc.name = 'Commissioning Checklist' then 1017
               when doc.name = 'Approved Plans' then 56
               when doc.name = 'Preliminary Utility Approval' then 1010
               when doc.name = 'Approved Permit' then 56
               when doc.name = 'Shading Analysis' then 1008
               when doc.name = 'Inspection Results' then 56
               when doc.name = 'Utility Pre-Approval' then 1010
               when doc.name = 'SDG&E Terms and Conditions' then 56
               when doc.name = 'Designs Distributed - Email CDesigns Distributed - Email Confirmation' then 1025
               when doc.name = 'Electric Meter & Placard Photo' then 1011
               when doc.name = 'Final Building Permit' then 1028
               else 56 end,
             3,
             doc.aws_file_name_c,
             ss3f.content_type,
             ss3f.albatross_s3_key,
             ss3f.size,
             now(),
             2384850,
             2384850,
             uuid_generate_v4(),
             doc.name,
             doc.id,
             p.id
      FROM brs.DOCUMENT_C doc
             JOIN brs.RESIDENTIAL_PROJECT_C rp ON rp.id = doc.residential_project_c
             inner join flow.project p on p.nw_migration_id = rp.id
             inner join sunpower_migration.sunpower_s3_files ss3f
                        on metadata ->> 'aws_file_name' = doc.aws_file_name_c
      WHERE rp.record_type_id = '01234000000UQPbAAO' and
            doc.aws_file_name_c is not null)returning *)
insert
into flow.project_attachment(attachment_id, project_id, created_by_id, modified_by_id)
  (select ia.id, ia.project_migration_id, 2384850, 2384850
   from insert_attachment ia);


with insert_attachment as (
  insert into flow.attachment (attachment_type_id, company_id, filename, content_type,
                               s3_key, size, date_created, created_by_id, modified_by_id,
                               uuid, display_name, nw_migration_id, project_migration_id)
    (
      SELECT  --443235
        case
          when icd.name like '%PTO Letter%' then 1016
          when icd.name like '%Builder WO%' then  1018
          when icd.name like '%Final Permit%' then 1006
          when icd.name like '%Project Checklist%' then 1019
          when icd.name like '%Commissioning Report%' then 1017
          when icd.name like '%JCO Upload Trim%' then 1013
          when icd.name like '%JCO Upload PV%' then 1012
          when icd.name like '%Storage Conditional Lien Waiver%' then 1015
          when icd.name like '%Storage Checklist%' then 1014
          when icd.name like '%Conditional%' then  1023
          else 56 end,
        3,
        icd.aws_file_name_c,
        ss3f.content_type,
        ss3f.albatross_s3_key,
        ss3f.size,
        now(),
        2384850,
        2384850,
        uuid_generate_v4(),
        icd.name,
        icd.id,
        p.id
      FROM brs.INVOICE_COMPLIANCE_DOCUMENT_C icd
             JOIN brs.RESIDENTIAL_PROJECT_C rp ON rp.id = icd.residential_project_c
             inner join flow.project p on p.nw_migration_id = rp.id
             inner join sunpower_migration.sunpower_s3_files ss3f
                        on metadata ->> 'aws_file_name' = icd.aws_file_name_c
      WHERE rp.record_type_id = '01234000000UQPbAAO' and
            icd.aws_file_name_c is not null)returning *)
insert into flow.project_attachment(attachment_id, project_id, created_by_id, modified_by_id)
  (select ia.id, ia.project_migration_id, 2384850, 2384850
   from insert_attachment ia);

with insert_attachment as (
  insert into flow.attachment (attachment_type_id, company_id, filename, content_type,
                               s3_key, size, date_created, created_by_id, modified_by_id,
                               uuid, display_name, nw_migration_id, project_migration_id)
    (
      SELECT  --9382
        56,
        3,
        attachment.name,
        ss3f.content_type,
        ss3f.albatross_s3_key,
        ss3f.size,
        now(),
        2384850,
        2384850,
        uuid_generate_v4(),
        attachment.name,
        attachment.id,
        p.id
      FROM  brs.SFDC_ATTACHMENTS_ARCHIVE_LINKS archive
              JOIN brs.ATTACHMENT attachment ON attachment.id = archive.attachment_id
              JOIN brs.ACCOUNT acct ON acct.id = attachment.parent_id
              LEFT JOIN brs.RESIDENTIAL_PROJECT_C rp ON rp.account_c = acct.id
              inner join flow.project p on p.nw_migration_id = rp.id
              inner join sunpower_migration.sunpower_s3_files ss3f
                         on metadata ->> 'archive_link' = archive.archive_link
      WHERE rp.record_type_id = '01234000000UQPbAAO' and
        attachment.name is not null)returning *)
insert into flow.project_attachment(attachment_id, project_id, created_by_id, modified_by_id)
  (select ia.id, ia.project_migration_id, 2384850, 2384850
   from insert_attachment ia);

with insert_attachment as (
  insert into flow.attachment (attachment_type_id, company_id, filename, content_type,
                               s3_key, size, date_created, created_by_id, modified_by_id,
                               uuid, display_name, nw_migration_id, project_migration_id)
    (
      SELECT  --96659
        56,
        3,
        icd.name,
        ss3f.content_type,
        ss3f.albatross_s3_key,
        ss3f.size,
        now(),
        2384850,
        2384850,
        uuid_generate_v4(),
        icd.id,
        icd.id,
        p.id
      FROM brs.INVOICE_COMPLIANCE_DOCUMENT_C icd
             INNER JOIN brs.RESIDENTIAL_PROJECT_C rp ON icd.residential_project_c = rp.id
             INNER JOIN brs.SFDC_ATTACHMENTS_ARCHIVE_LINKS archive ON archive.attachment_id = RIGHT(icd.link_to_attachment_c,18)
             inner join flow.project p on p.nw_migration_id = rp.id
             inner join sunpower_migration.sunpower_s3_files ss3f
                        on metadata ->> 'archive_link' = archive.archive_link
      WHERE icd.link_to_attachment_c is not null AND icd.aws_file_name_c is null
        AND icd.residential_project_c is not null
        AND rp.record_type_id = '01234000000UQPbAAO'
        AND icd.link_to_attachment_c LIKE 'https://sunpower.my.salesforce.com/servlet/servlet.FileDownload?file=%')returning *)
insert into flow.project_attachment(attachment_id, project_id, created_by_id, modified_by_id)
  (select ia.id, ia.project_migration_id, 2384850, 2384850
   from insert_attachment ia);



-- START NEW SCENARIOS
-- SCENARIO 1: DOCUMENT_C - gocanvas only----todo gocanvas
SELECT doc.name as display_name
     , doc.name as file_name
     , doc.url_c
     , doc.id as migration_id
     , doc.residential_project_c
FROM SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.DOCUMENT_C doc
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.RESIDENTIAL_PROJECT_C rp ON doc.residential_project_c = rp.id
WHERE
  rp.record_type_id = '01234000000UQPbAAO'
  AND doc.aws_file_name_c is null
  AND doc.url_c is not null
  AND doc.url_c LIKE 'https://www.gocanvas.com%';


--  SCENARIO 2: ICDs with a different attachment link format - not gocanvas
SELECT
  RIGHT(icd.link_to_attachment_c,18),
  icd.link_to_attachment_c,
  rp.id as migration_project_id,
  icd.id as icd_id,
  icd.name as display_name,
  icd.file_name_c,
  archive.archive_link
FROM SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.INVOICE_COMPLIANCE_DOCUMENT_C icd
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.RESIDENTIAL_PROJECT_C rp ON icd.residential_project_c = rp.id
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_ARCHIVE.SFDC_ATTACHMENTS_ARCHIVE_LINKS archive ON archive.attachment_id = RIGHT(icd.link_to_attachment_c,18)
WHERE icd.link_to_attachment_c is not null AND icd.aws_file_name_c is null
  AND icd.residential_project_c is not null
  AND rp.record_type_id = '01234000000UQPbAAO'
  AND icd.link_to_attachment_c NOT LIKE 'https://www.gocanvas.com/submission_files/%'
  AND icd.link_to_attachment_c NOT LIKE 'https://sunpower.my.salesforce.com/servlet/servlet.FileDownload?file=%'
  AND icd.link_to_attachment_c LIKE 'https://sunpower1.force.com/servlet/servlet.FileDownload?%'


-- SCENARIO 3: DOCUMENT_C - AgreementIds
SELECT
  RIGHT(doc.url_c,18) as agreement_id
     , doc.name
     , doc.url_c
     , doc.residential_project_c
     , doc.project_task_c
     , doc.aws_file_name_c
     , dsa.name
     , archive.archive_link
FROM SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.DOCUMENT_C doc
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.RESIDENTIAL_PROJECT_C rp ON doc.residential_project_c = rp.id
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.echosign_dev_1_sign_agreement_c dsa ON dsa.id = RIGHT(doc.url_c, 18)
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.attachment a ON a.parent_id = RIGHT(doc.url_c, 18)
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_ARCHIVE.SFDC_ATTACHMENTS_ARCHIVE_LINKS archive ON archive.attachment_id = a.id
WHERE
  rp.record_type_id = '01234000000UQPbAAO'
  AND doc.aws_file_name_c is null
  AND doc.url_c is not null
  AND doc.url_c NOT LIKE 'https://www.gocanvas.com%'
  AND doc.url_c LIKE 'https://sunpower.my.salesforce.com/apex/echosign_dev1__SignedAgreementDocLink?agreementId=%'


-- SCENARIO 4: documents - content versions na101
SELECT doc.name
     , doc.url_c
     , doc.residential_project_c
     , doc.project_task_c
     , doc.aws_file_name_c
     , archive.archive_link
FROM SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.DOCUMENT_C doc
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.RESIDENTIAL_PROJECT_C rp ON doc.residential_project_c = rp.id
       LEFT JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.CONTENT_DOCUMENT cd ON cd.id = RIGHT(doc.url_c,18)
       LEFT JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.CONTENT_VERSION cv ON cv.ID = cd.latest_published_version_id
       LEFT JOIN SUNPOWER_DATAWAREHOUSE.SFDC_ARCHIVE.SFDC_CONTENT_VERSION_ARCHIVE_LINKS archive ON archive.content_version_id = cv.id
WHERE
  rp.record_type_id = '01234000000UQPbAAO'
  AND doc.aws_file_name_c is null
  AND doc.url_c is not null
  AND doc.url_c NOT LIKE 'https://www.gocanvas.com%'
  AND doc.url_c LIKE 'https://na101.salesforce.com/%'


-- SCENARIO 5: some other random salesfore link
SELECT doc.name
     , doc.url_c
     , doc.residential_project_c
     , doc.project_task_c
     , doc.aws_file_name_c
     , archive.archive_link
FROM SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.DOCUMENT_C doc
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.RESIDENTIAL_PROJECT_C rp ON doc.residential_project_c = rp.id
       LEFT JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.CONTENT_DOCUMENT cd ON cd.id = RIGHT(doc.url_c,18)
       LEFT JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.CONTENT_VERSION cv ON cv.ID = cd.latest_published_version_id
       LEFT JOIN SUNPOWER_DATAWAREHOUSE.SFDC_ARCHIVE.SFDC_CONTENT_VERSION_ARCHIVE_LINKS archive ON archive.content_version_id = cv.id
WHERE
  rp.record_type_id = '01234000000UQPbAAO'
  AND doc.aws_file_name_c is null
  AND doc.url_c is not null
  AND doc.url_c NOT LIKE 'https://www.gocanvas.com%'
  AND doc.url_c NOT LIKE 'https://na101.salesforce.com/%'
  AND doc.url_c NOT LIKE 'https://sunpower.my.salesforce.com/apex/echosign_dev1__SignedAgreementDocLink?agreementId=%'
  AND doc.url_c LIKE 'https://sunpower.my.salesforce.com/%'


-- SCENARIO 6: another salesforce attachment url format
SELECT doc.name
     , doc.url_c
     , doc.residential_project_c
     , doc.project_task_c
     , doc.aws_file_name_c
     , archive.archive_link
FROM SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.DOCUMENT_C doc
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.RESIDENTIAL_PROJECT_C rp ON doc.residential_project_c = rp.id
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_ARCHIVE.SFDC_ATTACHMENTS_ARCHIVE_LINKS archive ON archive.attachment_id = RIGHT(doc.url_c,18)
WHERE
  rp.record_type_id = '01234000000UQPbAAO'
  AND doc.aws_file_name_c is null
  AND doc.url_c is not null
  AND doc.url_c NOT LIKE 'https://www.gocanvas.com%'
  AND doc.url_c NOT LIKE 'https://na101.salesforce.com/%'
  AND doc.url_c NOT LIKE 'https://sunpower.my.salesforce.com/apex/echosign_dev1__SignedAgreementDocLink?agreementId=%'
  AND doc.url_c NOT LIKE 'https://sunpower.my.salesforce.com/%'
  AND doc.url_c LIKE 'https://sunpower1.force.com/servlet/servlet.FileDownload?file=%'


-- SCENARIO 10: files directly attached to RP
SELECT a.name
     , a.id
     , rp.id
     , archive.archive_link
FROM SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.ATTACHMENT a
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_STAGING.RESIDENTIAL_PROJECT_C rp ON rp.id = a.parent_id
       INNER JOIN SUNPOWER_DATAWAREHOUSE.SFDC_ARCHIVE.SFDC_ATTACHMENTS_ARCHIVE_LINKS archive ON archive.attachment_id = a.id
WHERE
  rp.record_type_id = '01234000000UQPbAAO'
  AND a.is_deleted = false;




--todo talke to Carlin or Michael to figure out where to put these
create table brs.gocanvas_link_records as (

  (SELECT
    icd.link_to_attachment_c,
    rp.id as migration_project_id,
    icd.id as icd_id,
    icd.name as display_name,
    p.id as project_id
  FROM brs.INVOICE_COMPLIANCE_DOCUMENT_C icd
         INNER JOIN brs.RESIDENTIAL_PROJECT_C rp ON icd.residential_project_c = rp.id
  inner join flow.project p on p.nw_migration_id = rp.id
  WHERE icd.link_to_attachment_c is not null AND icd.aws_file_name_c is null
    AND icd.residential_project_c is not null
    AND rp.record_type_id = '01234000000UQPbAAO'
    AND icd.link_to_attachment_c LIKE 'https://www.gocanvas.com/submission_files/%')

);

DO
$do$
    declare
        x record;
        v_link_text text;
    BEGIN
        for x in    select distinct project_id
                    from brs.gocanvas_link_records
            loop
                v_link_text = null;

                select string_agg(concat(display_name, ' = ', link_to_attachment_c),E'\n')::text
                into v_link_text
                from brs.gocanvas_link_records glr
                where glr.project_id = x.project_id;

                perform flow.set_project_cfv(x.project_id::bigint, 2384850::bigint, 30142::bigint,
                                             v_link_text::text, true);
            end loop;

    end
$do$;




