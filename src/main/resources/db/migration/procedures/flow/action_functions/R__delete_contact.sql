drop procedure if exists flow.delete_contact(p_contact_id bigint);
CREATE OR REPLACE procedure flow.delete_contact(p_contact_id bigint)
 AS
$BODY$
declare
  v_project_ids bigint[];
BEGIN

  select array_agg(id)
  into v_project_ids
  from flow.project p2
  where p2.contact_id = p_contact_id;

  --CONTACT FK'S
  delete
  from flow.contact_attachment
  where contact_id = p_contact_id;

  delete
  from flow.trigger_error
  where
    contact_custom_field_value_id in (select id from flow.contact_custom_field_value where contact_id = p_contact_id);

  delete
  from flow.contact_custom_field_value
  where contact_id = p_contact_id;

  delete
  from flow.contact_activity_hashtag cah
  where contact_activity_id in (select id from flow.contact_activity a where contact_id = p_contact_id);

  delete
  from flow.contact_activity ca
  where contact_id = p_contact_id;

--   delete
--   from flow.sms_queue sq
--   where contact_id = p_contact_id;

  delete
  from flow.trigger_error te
  where contact_id = p_contact_id;


  --PROJECT FK'S


  delete
  from brs.birdeye_invitations
  where project_id = any (v_project_ids);

  delete
  from brs.permit_pack_log_history pplh
  where design_log_id in (select id from brs.design_log dl where dl.project_id = any (v_project_ids));

  delete
  from brs.permit_pack_log_history h
  where project_id = any (v_project_ids);

  delete
  from brs.design_log_history pplh
  where design_log_id in (select id from brs.design_log dl where dl.project_id = any (v_project_ids));

  delete
  from brs.design_log_history h
  where project_id = any (v_project_ids);

  delete
  from brs.permit_pack_log ppl
  where project_id = any (v_project_ids);

  delete
  from brs.design_log d
  where project_id = any (v_project_ids);


  delete
  from brs.exclude_commission
  where project_id = any (v_project_ids);

  delete
  from brs.installation_agreement_requests
  where project_id = any (v_project_ids);

  delete
  from brs.payroll_adjustment
  where project_id = any (v_project_ids);

  delete
  from brs.project_commission
  where project_id = any (v_project_ids);

  delete
  from brs.project_commission_ledger
  where project_id = any (v_project_ids);

  delete
  from brs.project_override_commission_snapshot
  where project_commission_snapshot_id in (select id
                                           from brs.project_commission_snapshot
                                           where project_id = any (v_project_ids));

  delete
  from brs.project_commission_snapshot
  where project_id = any (v_project_ids);

  delete
  from brs.project_details
  where project_id = any (v_project_ids);

  delete
  from brs.project_override
  where project_id = any (v_project_ids);

  delete
  from brs.project_rebate_payment
  where project_id = any (v_project_ids);

  delete
  from brs.project_rebate_payment_audit
  where project_id = any (v_project_ids);

  delete
  from brs.proposal_log_history
  where project_id = any (v_project_ids);

  delete
  from brs.proposal_log
  where project_id = any (v_project_ids);

  delete
  from brs.proposal_project_proposal_version
  where project_id = any (v_project_ids);

  delete
  from brs.residual_ledger
  where project_id = any (v_project_ids);

  delete
  from brs.residual_project_override_qualified_date
  where project_id = any (v_project_ids);

  delete
  from brs.residual_project_qualified_date
  where project_id = any (v_project_ids);

  delete
  from brs.setter_project_override_commission_snapshot
  where setter_project_commission_snapshot_id in (select id
                                                  from brs.setter_project_commission_snapshot
                                                  where project_id = any (v_project_ids));

  delete
  from brs.setter_project_commission_snapshot
  where project_id = any (v_project_ids);

  delete
  from brs.user_residual_project_snapshot
  where project_id = any (v_project_ids);

  delete
  from flow.project_activity_hashtag
  where project_activity_id in (select id
                                from flow.project_activity pa
                                where project_id = any (v_project_ids));
  delete
  from flow.project_activity pa2
  where project_id = any (v_project_ids);

  delete
  from flow.project_attachment
  where project_id = any (v_project_ids);

  delete
  from flow.trigger_error t
  where project_custom_field_value_id in (select id
                                          from flow.project_custom_field_value pcfv
                                          where project_id = any (v_project_ids));

  delete
  from flow.project_custom_field_value v
  where project_id = any (v_project_ids);

  delete
  from flow.project_message_owner
  where project_id = any (v_project_ids);

  delete
  from flow.project_message_owner_history
  where project_id = any (v_project_ids);

  delete
  from flow.project_message_properties
  where project_id = any (v_project_ids);

  delete
  from flow.project_message_team
  where project_id = any (v_project_ids);


  delete
  from flow.trigger_error e
  where project_process_step_custom_value_id in (select id
                                                 from flow.project_process_step_custom_field_value
                                                 where project_process_step_id in (select id
                                                                                   from flow.project_process_step pps
                                                                                   where pps.project_id = any (v_project_ids)));

  delete
  from flow.project_process_step_custom_field_value
  where project_process_step_id in (select id
                                    from flow.project_process_step s
                                    where project_id = any (v_project_ids));

  delete
  from flow.project_process_step_process_step_work_queue_type_note
  where project_process_step_id in (select id
                                    from flow.project_process_step pps2
                                    where project_id = any (v_project_ids));


  delete
  from flow.project_activity_hashtag pah
  where pah.project_activity_id in (select id
                                    from flow.project_activity pa3
                                    where linked_pps_id in (select id
                                                            from flow.project_process_step pps3
                                                            where pps3.project_id = any (v_project_ids)));
  delete
  from flow.project_activity pa4
  where linked_pps_id in (select id
                          from flow.project_process_step pps3
                          where pps3.project_id = any (v_project_ids));

  delete
  from flow.project_process_step_event_action
  where project_process_step_event_id in (select id
                                          from flow.project_process_step_event ppse
                                          where ppse.project_process_step_id in (select id
                                                                                 from flow.project_process_step pps
                                                                                 where pps.project_id = any (v_project_ids)));
  delete
  from flow.pps_event_process_step_event_work_queue_type_note
  where project_process_step_event_id in (select id
                                          from flow.project_process_step_event ppse2
                                          where project_process_step_id in (select id
                                                                            from flow.project_process_step pps4
                                                                            where pps4.project_id = any (v_project_ids)));

  delete
  from flow.project_activity_hashtag pah
  where pah.project_activity_id in (select id
                                    from flow.project_activity pa3
                                    where linked_ppse_id in (select id
                                                             from flow.project_process_step_event pps3
                                                             where pps3.project_process_step_id in (select id
                                                                                                    from flow.project_process_step pps5
                                                                                                    where pps5.project_id = any (v_project_ids))));
  delete
  from flow.project_activity pa4
  where linked_ppse_id in (select id
                           from flow.project_process_step_event pps3
                           where pps3.project_process_step_id in (select id
                                                                  from flow.project_process_step pps6
                                                                  where pps6.project_id = any (v_project_ids)));

  delete
  from flow.trigger_error te2
  where project_process_step_event_custom_field_value_id in (select id
                                                             from flow.project_process_step_event_custom_field_value
                                                             where project_process_step_event_id in
                                                                   (select id
                                                                    from flow.project_process_step_event ppse3
                                                                    where project_process_step_id in (select id
                                                                                                      from flow.project_process_step pps7
                                                                                                      where pps7.project_id = any (v_project_ids))));
  delete
  from flow.project_process_step_event_custom_field_value
  where project_process_step_event_id in (select id
                                          from flow.project_process_step_event
                                          where project_process_step_id in (select id
                                                                            from flow.project_process_step pps8
                                                                            where pps8.project_id = any (v_project_ids)));

  delete
  from flow.work_queue_cycle
  where project_process_step_event_id in (select id
                                          from flow.project_process_step_event ppse4
                                          where ppse4.project_process_step_id in (select id
                                                                                  from flow.project_process_step pps9
                                                                                  where pps9.project_id = any (v_project_ids)));

  delete
  from flow.trigger_error te3
  where te3.project_process_step_event_id in (select id
                                              from flow.project_process_step_event ppse5
                                              where ppse5.project_process_step_id in (select id
                                                                                      from flow.project_process_step pps10
                                                                                      where pps10.project_id = any (v_project_ids)));

  delete
  from flow.project_process_step_event_attachment
  where project_process_step_event_id in (select id
                                          from flow.project_process_step_event ppse6
                                          where ppse6.project_process_step_id in (select id
                                                                                  from flow.project_process_step pps11
                                                                                  where pps11.project_id = any (v_project_ids)));

  update flow.project_process_step pps13
  set parent_project_process_step_event_id = null
  where pps13.project_id = any (v_project_ids);


  delete
  from flow.project_process_step_event
  where project_process_step_id in (select id
                                    from flow.project_process_step pps12
                                    where pps12.project_id = any (v_project_ids));


  delete
  from flow.project_process_step_attachment
  where project_process_step_id in (select id
                                    from flow.project_process_step pps15
                                    where pps15.project_id = any (v_project_ids));

  delete
  from flow.project_process_step_action
  where project_process_step_id in (select id
                                    from flow.project_process_step pps15
                                    where pps15.project_id = any (v_project_ids));

  delete
  from flow.work_queue_cycle
  where project_process_step_id in (select id
                                    from flow.project_process_step pps15
                                    where pps15.project_id = any (v_project_ids));

  delete
  from flow.trigger_error
  where project_process_step_id in (select id
                                    from flow.project_process_step pps15
                                    where pps15.project_id = any (v_project_ids));

  update brs.proposal p
  set original_proposal_id = null
  where project_process_step_id in (select id
                                    from flow.project_process_step pps15
                                    where pps15.project_id = any (v_project_ids));

  delete
  from brs.proposal_custom_field_value
  where proposal_id in (select id from brs.proposal p3
                                  where p3.project_process_step_id in (select id
                                    from flow.project_process_step pps15
                                    where pps15.project_id = any (v_project_ids)));

  delete
  from brs.proposal
  where project_process_step_id in (select id
                                    from flow.project_process_step pps15
                                    where pps15.project_id = any (v_project_ids));

  update flow.project_process_step pps13
  set parent_project_process_step_id = null
  where pps13.project_id = any (v_project_ids);

  delete
  from flow.project_process_step pps14
  where project_id = any (v_project_ids);


  delete
  from flow.project_prod_stats_note
  where project_id = any (v_project_ids);

  delete
  from flow.project_status_change_history
  where project_id = any (v_project_ids);

  delete
  from flow.project_tag
  where project_id = any (v_project_ids);

  delete
  from flow.sms_thread
  where search_external_phone = (select search_phones from flow.contact c where c.id = p_contact_id);

  delete
  from flow.sms_thread
  where sent_to_project_id = any (v_project_ids);

  delete
  from flow.trigger_error
  where project_id = any (v_project_ids);

  delete
  from brs.project_override_commission_snapshot f
  where f.project_commission_snapshot_id in (select id
                                             from brs.project_commission_snapshot pcs
                                             where pcs.project_id = any (v_project_ids));

  delete
  from brs.project_commission_snapshot pcs2
  where pcs2.project_id = any (v_project_ids);

  delete from flow.import_sp_project
    where project_id = any (v_project_ids);

  delete from flow.project where contact_id = p_contact_id;
  delete from flow.contact c where id = p_contact_id;
  commit;

END
$BODY$
  LANGUAGE plpgsql;
