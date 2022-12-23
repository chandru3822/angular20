package com.albatross.api.v1.company.blueraven.services.queries;

public class BirdeyeQuery {

  //language=PostgreSQL
  public final static String getBusinessId = """
    select text_value
    from flow.organization_custom_field_value ocfv
    where ocfv.custom_field_group_assignment_id =
          (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on cf.id = cfg.custom_field_id
             WHERE field_name = 'Birdeye Business ID' and cf.company_id = (select o.company_id from brs.project_details pd inner join flow.org o on pd.installation_resource = o.id where project_id = :projectId))
    and ocfv.org_id = (select installation_resource from brs.project_details where project_id = :projectId)
    """;

  //language=PostgreSQL
  public final static String getEmail = """
    select text_value
    from flow.organization_custom_field_value ocfv
    inner join flow.custom_field_group_assignment cfga on cfga.id = ocfv.custom_field_group_assignment_id
    inner join flow.custom_field cf on  cfga.custom_field_id = cf.id
    where field_name = 'Org Email'
    and company_id = (select company_id from brs.project_details where project_id = :projectId)
    and org_id = (select installation_resource from brs.project_details where project_id = :projectId);
    """;

  //language=PostgreSQL
  public final static String saveInvitation = """
    INSERT INTO brs.birdeye_invitations(project_id, birdeye_business_id, date_sent, raw_invitation)
    VALUES (:projectId, :birdeyeBusinessId, :dateSent, :rawInvitation::JSONB);
    """;

  //language=PostgreSQL
  public final static String addCustomerId = """
    UPDATE brs.birdeye_invitations
    SET birdeye_customer_id = :custId, date_modified = now()
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String saveReviewInviteSentValue = """
    select from flow.set_pps_cfv(:projectId::bigint, :userId::bigint, 23391, 'true'::text, true);
    """;

  //language=PostgreSQL
  public final static String saveReview = """
    INSERT INTO brs.birdeye_reviews(birdeye_business_id,
                                    birdeye_review_id,
                                    birdeye_customer_id,
                                    review_date,
                                    brs_response_date,
                                    review_text,
                                    review_score)
    VALUES
      (:birdeyeBusinessId, :birdeyeReviewId, :birdeyeCustomerId,
       :reviewDate, :brsResponseDate, :reviewText, :reviewScore)
    ON CONFLICT (birdeye_review_id)
    DO UPDATE SET brs_response_date = :brsResponseDate,
                  review_text       = :reviewText,
                  review_score      = :reviewScore
    """;

  //language=PostgreSQL
  public final static String saveLocation = """
    INSERT INTO brs.birdeye_location(business_id, alias)
    VALUES (:businessId, :alias)
    ON CONFLICT (business_id)
    DO UPDATE SET alias = :alias
    """;

  //language=PostgreSQL
  public final static String getLastSync = """
    select bss.last_sync_timestamp from brs.birdeye_survey_sync bss where bss.business_id = :businessId and bss.survey_id = :surveyId
    """;

  //language=PostgreSQL
  public final static String setLastSync = """
    insert into brs.birdeye_survey_sync (business_id, survey_id, last_sync_timestamp)
    values (:businessId, :surveyId, :lastSync)
    on conflict (business_id, survey_id)
        do update set last_sync_timestamp = excluded.last_sync_timestamp
    """;

  //language=PostgreSQL
  public final static String getProjectByCustomer = """
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
