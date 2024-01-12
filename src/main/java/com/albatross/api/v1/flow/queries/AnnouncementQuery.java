package com.albatross.api.v1.flow.queries;

public class AnnouncementQuery {

  //language=PostgreSQL
  public final static String get = """
    select a.id,
           a.title,
           a.alert_text,
           a.subtitle,
           a.description,
           a.hyperlink,
           a.attachment_id,
           a.start_time,
           a.end_time,
           a.expandable,
           a.show_on_web,
           a.show_on_mobile,
           a.company_id,
           a.date_created,
           a.date_modified,
           a.created_by_id,
           a.modified_by_id,
           a.archived
    from flow.announcement a
    where a.archived is false
    and case when :current::boolean is true then
    (end_time is null or end_time >= now())
    else
        end_time < now() end
    order by a.start_time desc, a.end_time desc
    limit :limit
    offset :offset
    """;


  //language=PostgreSQL
  public final static String getCount = """
    select count(1)
    from flow.announcement a
    where a.archived is false
    and case when :current::boolean is true then
    (end_time is null or end_time >= now())
    else
        end_time < now() end
    """;

  //language=PostgreSQL
  public final static String getActive = """
    select a.id,
           a.title,
           a.alert_text,
           a.subtitle,
           a.description,
           a.hyperlink,
           a.attachment_id,
           a.start_time,
           a.end_time,
           a.expandable,
           a.show_on_web,
           a.show_on_mobile,
           a.company_id,
           a.date_created,
           a.date_modified,
           a.created_by_id,
           a.modified_by_id,
           a.archived,
           case when ua.message_read_tsz is null then false else true end as read,
           case when ua.message_seen_tsz is null then false else true end as seen
    from flow.announcement a
    left join flow.user_announcement ua on a.id = ua.announcement_id and ua.user_id = :userId
    where a.archived is false
    and case when :mobile::boolean is true then a.show_on_mobile is true
      else a.show_on_web is true
    end
    and a.start_time <= now()
    and (a.end_time is null or a.end_time >= now())
    order by a.start_time desc, a.end_time desc
    """;

  //language=PostgreSQL
  public final static String delete = """
    update flow.announcement
    set archived = true,
        date_modified = now(),
        modified_by_id = :userId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getOne = """
        select a.id,
           a.title,
           a.alert_text,
           a.subtitle,
           a.description,
           a.hyperlink,
           a.attachment_id,
           a.start_time,
           a.end_time,
           a.expandable,
           a.show_on_web,
           a.show_on_mobile,
           a.company_id,
           a.date_created,
           a.date_modified,
           a.created_by_id,
           a.modified_by_id,
           a.archived
    from flow.announcement a
    where a.archived is false
    and a.id = :id
    """;

  //language=PostgreSQL
  public final static String markAsRead = """
    insert into flow.user_announcement(user_id, announcement_id, message_read_tsz)
    values (:userId, :announcementId, now())
    on conflict (user_id, announcement_id) do update
      set message_read_tsz = now()
    """;

  //language=PostgreSQL
  public final static String markAsSeen = """
    insert into flow.user_announcement(user_id, announcement_id, message_seen_tsz)
    values (:userId, :announcementId, now())
    on conflict (user_id, announcement_id) do update
      set message_seen_tsz = now()
    """;

  //language=PostgreSQL
  public final static String insert = """
    insert into flow.announcement(title, alert_text, subtitle, description, hyperlink, start_time, end_time, expandable,
                                  show_on_web, show_on_mobile, company_id, date_created, date_modified, created_by_id)
    values (:title, :alertText, :subtitle, :description, :hyperlink, :startTime, :endTime, :expandable,
            :showOnWeb, :showOnMobile, :companyId, now(), now(), :userId);
    """;

  //language=PostgreSQL
  public final static String update = """
    update flow.announcement
       set title = :title,
           alert_text = :alertText,
           subtitle = :subtitle,
           description = :description,
           hyperlink = :hyperlink,
           start_time = :startTime,
           end_time = :endTime,
           expandable = :expandable,
           show_on_web = :showOnWeb,
           show_on_mobile = :showOnMobile,
           company_id = :companyId,
           date_modified = now(),
           modified_by_id = :userId
    where id = :id
    """;

}
