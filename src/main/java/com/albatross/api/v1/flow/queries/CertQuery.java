package com.albatross.api.v1.flow.queries;

public class CertQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select c.id,
           c.expiration_date,
           c.notes,
           c.cert_name,
           c.archived
       from flow.cert c
       where c.archived is not true
       order by c.expiration_date, c.cert_name
    """;

  //language=PostgreSQL
  public final static String getOneCert = """
    select c.id,
           c.cert_name,
           c.expiration_date,
           c.notes,
           c.archived
    from flow.cert c
    where c.id = :id
    """;

  //language=PostgreSQL
  public final static String insertCert = """
    insert into flow.cert(cert_name, created_by_id, expiration_date, notes)
     values (:certName, :userId, :expirationDate, :notes)
    """;

  //language=PostgreSQL
  public final static String updateCert = """
    update flow.cert
        set cert_name = :certName,
            expiration_date = :expirationDate,
            notes = :notes,
            modified_by_id = :userId,
            date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteCert = """
    update flow.cert
        set archived = true
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getExpiring30DayCerts = """
    select c.id,
           c.expiration_date,
           c.notes,
           c.cert_name,
           c.archived
       from flow.cert c
       where c.archived is not true
        and c.thirty_day_notice_sent is not true
        and c.expiration_date between (now() + interval '7 days')::date and (now() + interval '30 days')::date
        order by c.expiration_date
    """;

  //language=PostgreSQL
  public final static String getExpiring7DayCerts = """
    select c.id,
           c.expiration_date,
           c.notes,
           c.cert_name,
           c.archived
       from flow.cert c
       where c.archived is not true
       and c.expiration_date between now()::date and (now() + interval '7 days')::date
      order by c.expiration_date
    """;


  //language=PostgreSQL
  public final static String update30DayNotice = """
    update flow.cert
        set thirty_day_notice_sent = true
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getCertAdmins = """
    select id, first_name, last_name, email
    from flow.cert_admin_email
    where archived is false
    """;


}
