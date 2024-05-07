package com.albatross.api.v1.company.blueraven.integration.birdeye;

class BirdEyeQuery {

  //language=PostgreSQL
  final static String getOrgInfo = """
    with pd as (select company_id, installation_resource from brs.project_details where project_id = :projectId),
         vals as (select text_value, cf.field_name
                  from flow.organization_custom_field_value ocfv
                           inner join flow.custom_field_group_assignment cfga
                                      on cfga.id = ocfv.custom_field_group_assignment_id
                           inner join flow.custom_field cf on cfga.custom_field_id = cf.id
                           inner join pd on pd.company_id = cf.company_id and ocfv.org_id = pd.installation_resource
                  where cf.field_name in ('Birdeye Business ID', 'Org Email'))
    select (select text_value from vals where field_name = 'Org Email')           as org_email,
           (select text_value from vals where field_name = 'Birdeye Business ID') as birdeye_business_id
    """;

  //language=PostgreSQL
  final static String saveInvitation = """
    INSERT INTO brs.birdeye_invitations(project_id, birdeye_business_id, date_sent, raw_invitation)
    VALUES (:projectId, :birdeyeBusinessId, :dateSent, :rawInvitation::JSONB);
    """;

  //language=PostgreSQL
  final static String addCustomerId = """
    UPDATE brs.birdeye_invitations SET birdeye_customer_id = :custId, date_modified = now() WHERE id = :id
    """;

  //language=PostgreSQL
  final static String saveReviewInviteSentValue = """
    select from flow.set_pps_cfv(:projectId::bigint, :userId::bigint, 23391, 'true'::text, true);
    """;

  //language=PostgreSQL
  final static String getLastSync = """
    select bss.last_sync_timestamp from brs.birdeye_sync bss where bss.business_id = :businessId and bss.sync_key = :syncKey
    """;

  //language=PostgreSQL
  final static String setLastSync = """
    insert into brs.birdeye_sync (business_id, sync_key, sync_type, last_sync_timestamp)
    values (:businessId, :syncKey, :syncType, :lastSync)
    on conflict (business_id, sync_key, sync_type)
        do update set last_sync_timestamp = excluded.last_sync_timestamp
    """;

  final static String getSyncableSurveys = """
    select birdeye_survey_id, custom_field_group_id
    from brs.birdeye_survey
    where enabled is true
    """;

  //language=PostgreSQL
  final static String getProjectByCustomer = """
    select bi.id,
           bi.project_id,
           bi.birdeye_business_id,
           bi.raw_invitation -> 'sendSms'       as send_sms,
           bi.raw_invitation ->> 'customerName'  as customer_name,
           bi.raw_invitation ->> 'customerEmail' as customer_email,
           bi.raw_invitation ->> 'customerPhone' as customer_phone,
           bi.birdeye_customer_id
    from brs.birdeye_invitations bi
    where bi.birdeye_customer_id = :customerId
    order by date_modified desc
    limit 1
    """;
}
