-- drop function if exists flow.send_email_with_attachment_to_contact(p_project_id bigint,
--                                                                       p_pps_id bigint,
--                                                                       p_ppse_id bigint,
--                                                                       p_user_id bigint,
--                                                                       p_attachment_type_id bigint,
--                                                                       p_display_name_match_text varchar,
--                                                                       p_email_subject varchar,
--                                                                       p_email_message text,
--                                                                       p_email_sender_id int);
CREATE OR REPLACE FUNCTION flow.send_email_with_attachment_to_contact(p_project_id bigint,
                                                                      p_pps_id bigint,
                                                                      p_ppse_id bigint,
                                                                      p_user_id bigint,
                                                                      p_attachment_type_id bigint,
                                                                      p_display_name_match_text varchar,
                                                                      p_email_subject varchar,
                                                                      p_email_message text,
                                                                      p_email_sender_id int)
  returns boolean AS
$BODY$
declare
--   v_request_is_valid boolean;
  v_matching_attachment_ids int[];
  v_to_email varchar;
  v_email_default_header text;
  v_email_default_footer text;
  v_email_sender_address varchar;
  v_email_sender_name varchar;
BEGIN

  select '<!doctype html>
          <html xmlns="http://www.w3.org/1999/xhtml">
          <head>
              <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
              <meta name="viewport" content="width=device-width">
          </head>

          <body style="width: 100% !important; min-width: 100%; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; margin: 0; Margin: 0; padding: 0; -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box; ">'
  into v_email_default_header;

  select '</body>
         </html>'
  into v_email_default_footer;

  --todo: validate this request somehow??
  if(p_ppse_id is not null) then
    select array_agg(att.id)::int[]
      into v_matching_attachment_ids
    from flow.project_process_step_event_attachment ppsa
           inner join flow.attachment att on att.id = ppsa.attachment_id
    where att.archived is false
      and ppsa.archived is false
      and ppsa.project_process_step_event_id = p_ppse_id
      and att.attachment_type_id = p_attachment_type_id
      and lower(att.display_name) like concat('%', lower(p_display_name_match_text),'%');
  else
    select array_agg(att.id)::int[]
      into v_matching_attachment_ids
    from flow.project_process_step_attachment ppsa
           inner join flow.attachment att on att.id = ppsa.attachment_id
    where att.archived is false
      and ppsa.archived is false
      and ppsa.project_process_step_id = p_pps_id
      and att.attachment_type_id = p_attachment_type_id
      and lower(att.display_name) like concat('%', lower(p_display_name_match_text),'%');
  end if;



  if array_length(v_matching_attachment_ids, 1) > 0 then
      select c.email into v_to_email
      from flow.project p
        inner join flow.contact c on c.id = p.contact_id
      where p.id = p_project_id;

      select es.email_address, es.sender_name
        into v_email_sender_address, v_email_sender_name
      from flow.email_sender es
      where es.id = p_email_sender_id;

      if(v_to_email is not null and v_email_sender_address is not null) then
        insert into flow.email_queue (user_id, subject, message, from_email,
                                      to_email, processed, from_display_name, attachment_ids)
        values(p_user_id, p_email_subject, concat(v_email_default_header, p_email_message, v_email_default_footer), v_email_sender_address,
               v_to_email, false, v_email_sender_name, v_matching_attachment_ids);
        return true;
      else
        return false;
      end if;
  else
    return false;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
