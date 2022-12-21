drop function if exists brs.send_email(bigint, bigint, bigint, character varying, character varying, character varying);
CREATE OR REPLACE FUNCTION brs.send_email(p_project_id bigint,
                                          p_current_user_id bigint,
                                          p_message_type_id bigint,
                                          p_from_email character varying,
                                          p_from_display_name character varying,
                                          p_subject character varying,
                                          p_addressees character varying)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
  v_email_body text;
  v_addressees text[];
  r text;
  v_project_name text;
  v_project_address text;
  v_electrical_permit_number text;
  v_installation_agreement_signed_date text;
  v_ahj_name text;
  v_email_default_header text;
  v_email_default_footer text;
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

  -- p_addressees should come in like 'randa@gmail.com,jjs@br.com', need to convert to array
  select concat('{', replace(p_addressees, ' ', ''), '}')::text[]
    into v_addressees;

  --get the project name and address
  select p.project_name, concat(p.street1, ' ', p.city, ', ', s.abbreviation, ' ', p.postal_code)
  into v_project_name, v_project_address
  from flow.project p
         inner join flow.company_state cs on p.company_state_id = cs.id
         inner join flow.state s on s.id = cs.state_id
  where p.id = p_project_id;

  --place any message specific data gathering queries in here
  if p_message_type_id = 1 then
    select pd.installation_agreement_signed_date, pd.ahj_name
    into v_installation_agreement_signed_date, v_ahj_name
    from brs.project_details pd
    where pd.project_id = p_project_id;

    select text_value
    into v_electrical_permit_number
    from flow.project_custom_field_value
    where project_id = p_project_id
    and custom_field_group_assignment_id = 1100; -- electrical permit number on the project object

    select concat(
      '<div><p><br/>',
      'A new permit has been submitted to ', v_ahj_name, '. <br/><br/>',

      'Project ID: ', p_project_id, '<br/>',
      'Project Name: ', v_project_name, '<br/>',
      'Project Address: ', v_project_address, '<br/>',
      'Permit Number: ', coalesce(v_electrical_permit_number, 'N/A'), '<br/><br/>',

      'System Purchase and Installation Agreement Signed on ', v_installation_agreement_signed_date, '.<br/><br/>',

      'You can access this permit by going to <a href="https://albatross.myblueraven.com/project/', p_project_id, '/details" target="_blank">Albatross</a>.<br/><br/>',
      'Please contact <a href="mailto:legal@blueravensolar.com">legal@blueravensolar.com</a> if you have any questions about this permit.',
      '</p></div>'
    ) into v_email_body;
  end if;

  for r in select unnest(v_addressees)
    LOOP
      if r is not null and v_email_body is not null then
        insert into flow.email_queue(user_id, subject, message, attachments, from_email, to_email, processed, from_display_name)
        values(p_current_user_id,
               p_subject,
               concat(v_email_default_header, v_email_body, v_email_default_footer),
               null,
               p_from_email,
               r,
               false,
               p_from_display_name);
      end if;
    END LOOP;

    insert into flow.company_function_log(function_name, db_function_id, parameters, run_by_id)
    values ('Send Email', 61, 'p_project_id: ' || p_project_id ||
                              ' p_current_user_id: '|| p_current_user_id ||
                              ' p_message_type_id: ' || p_message_type_id ||
                              ' p_from_email: '|| p_from_email ||
                              ' p_from_display_name: ' || p_project_id ||
                              ' p_subject: '|| p_current_user_id ||
                              ' p_addressees: ' || p_addressees,
            p_current_user_id);

END
$function$


