package com.albatross.api.v1.company.blueraven.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.Date;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-10-23.
 */
@Data
public class HubspotContact {
    private Long vid;

    @JsonProperty("canonical-vid")
    private Long canonicalVid;

    @JsonProperty("merged-vids")
    private List<Long> mergedVids;

    @JsonProperty("portal-id")
    private Long portalId;

    @JsonProperty("is-contact")
    private Boolean isContact;

    @JsonProperty("profile-token")
    private String profileToken;

    @JsonProperty("profile-url")
    private String profileUrl;

    private ContactProperties properties;

    @JsonProperty("form-submissions")
    private List<FormSubmission> formSubmissions;

    @JsonProperty("list-memberships")
    private List<Membership> listMemberships;

    @JsonProperty("identity-profiles")
    private List<IdentityProfile> identityProfiles;

    @JsonProperty("merge-audits")
    private List<String> mergeAudits;

    @Data
    public static class ContactProperties {
        private ContactProperty hs_email_optout_4715233, lead_source, hs_email_bounce, hs_analytics_last_url, num_unique_conversion_events,
                                hs_analytics_revenue, hs_email_quarantined, createdate, hs_email_optout_5585859, hs_email_optout,
                                recent_conversion_event_name, hs_analytics_num_page_views, hs_email_optout_4602503,
                                hs_email_optout_3206167, zip, hs_email_optout_3206168, hs_email_last_email_name, first_conversion_date,
                                hs_analytics_average_page_views, lastname, phone, hs_is_contact, num_conversion_events, currentlyinworkflow,
                                hs_analytics_num_event_completions, first_conversion_event_name, firstname, hs_email_optout_4657648,
                                hs_social_num_broadcast_clicks, hs_analytics_last_timestamp, hs_email_recipient_fatigue_recovery_time,
                                hs_analytics_num_visits, hs_social_linkedin_clicks, lead_source_detail, hs_analytics_last_visit_timestamp, hs_social_last_engagement,
                                hs_analytics_source, hs_searchable_calculated_phone_number, hs_analytics_first_touch_converting_campaign,
                                hs_email_domain, email, hs_analytics_first_url, hs_analytics_first_visit_timestamp, hs_analytics_first_timestamp,
                                lastmodifieddate, hs_analytics_last_touch_converting_campaign, hs_social_google_plus_clicks, hs_analytics_last_referrer,
                                hs_calculated_form_submissions, hs_social_facebook_clicks, recent_conversion_date, hs_analytics_source_data_2,
                                hs_social_twitter_clicks, hs_analytics_source_data_1, hs_lifecyclestage_salesqualifiedlead_date, lifecyclestage,
                                hs_email_sends_since_last_engagement, state, city, address;
    }

    @Data
    public static class ContactProperty {
        private String value;
        private List<PropertyVersion> versions;
    }

    @Data
    public static class PropertyVersion {
        private String value;

        @JsonProperty("source-type")
        private String sourceType;

        @JsonProperty("source-id")
        private String sourceId;

        @JsonProperty("source-label")
        private String sourceLabel;

        private Date timestamp;
        private Boolean selected;
    }

    @Data
    public static class FormSubmission {
        @JsonProperty("conversion-id")
        private String conversionId;

        private Date timestamp;

        @JsonProperty("form-id")
        private String formId;

        @JsonProperty("portal-id")
        private Long portalId;

        @JsonProperty("page-url")
        private String pageUrl;

        @JsonProperty("page-title")
        private String pageTitle;

        private String title;

        @JsonProperty("form-type")
        private String formType;

        @JsonProperty("meta-data")
        private List<String> metaData;
    }

    @Data
    public static class Membership {
        @JsonProperty("static-list-id")
        private Long staticListId;

        @JsonProperty("internal-list-id")
        private Long internalListId;

        private Date timestamp;
        private Long vid;

        @JsonProperty("is-member")
        private Boolean isMember;
    }

    @Data
    public static class IdentityProfile {
        private Long vid;

        @JsonProperty("pointer-vid")
        private Long pointerVid;

        @JsonProperty("previous-vid")
        private Long previousVid;

        @JsonProperty("is-deleted")
        private Boolean isDeleted;

        @JsonProperty("is-contact")
        private Boolean isContact;

        @JsonProperty("linked-vids")
        private List<Long> linkedVids;

        @JsonProperty("saved-at-timestamp")
        private Date savedAtTimestamp;

        @JsonProperty("deleted-changed-timestamp")
        private Date deletedChangedTimestamp;

        private List<Identity> identities;
    }

    @Data
    public static class Identity {
        private String type, value, source;
        private Date timestamp;

        @JsonProperty("is-primary")
        private Boolean isPrimary;
    }
}
