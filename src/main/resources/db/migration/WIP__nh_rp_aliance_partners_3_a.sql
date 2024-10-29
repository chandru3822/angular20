SET session_replication_role = replica;
DO
$do$
  declare
    x                         record;
    v_count                   bigint;
    v_total                   bigint;
    v_project_process_step_id bigint;
  BEGIN
    raise notice '3 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for x in select distinct on (p.id,apc.role_c) apc.role_c,
                                                  o.id   as org_id,
                                                  p.id   as project_id,
                                                  apc.id as alliance_partner_id,
                                                  CASE
                                                    WHEN row_number() OVER (PARTITION BY rpc.id ORDER BY rpc.id) = 1 THEN TRUE
                                                    ELSE FALSE END AS is_first_row
             from brs.residential_project_c rpc
                    inner join brs.alliance_partner_c apc on apc.residential_project_c = rpc.id
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    inner join flow.org o on o.nh_migration_id = apc.partner_account_c
             where apc.RESIDENTIAL_PROJECT_C is not null
               and apc.IS_DELETED = false
               and apc.RECORD_TYPE_ID = '01234000000UQPYAA4'
               and apc.partner_account_c in ('0013400001MNCFmAAP',
                                             '0013400001VYGgBAAX',
                                             '0013400001NBguWAAT',
                                             '0013400001M0OvCAAV',
                                             '0013400001KNIglAAH',
                                             '0013400001YM5F3AAL',
                                             '0012T00001ZDmogQAD',
                                             '0012T00001wnyWkQAI',
                                             '0013400001Y3ICkAAN',
                                             '0013400001KdlonAAB',
                                             '0012T00001eW2LgQAK',
                                             '0013400001RbMuTAAV',
                                             '0012T00001vNyBdQAK',
                                             '0012T00001srcCPQAY',
                                             '0013400001Y2wOKAAZ',
                                             '0012T00001wIMjRQAW',
                                             '0013400001OYSe8AAH',
                                             '0012T00001v6GWEQA2',
                                             '0018000000zOkBiAAK',
                                             '0013400001YO79pAAD',
                                             '0013400001Kmf3tAAB',
                                             '0012T00001af237QAA',
                                             '0012T00001wpRIFQA2',
                                             '0012T00001aBmiDQAS',
                                             '0013400001PS5uBAAT',
                                             '0018000000ubop8AAA',
                                             '0012T00001y40GRQAY',
                                             '0013400001XwHNPAA3',
                                             '0013400001VZsD7AAL',
                                             '0013400001MmJcdAAF',
                                             '0013400001K5nFUAAZ',
                                             '0012T00001zgPc7QAE',
                                             '0013400001JktcIAAR',
                                             '0013400001VXpRiAAL',
                                             '0013400001Wh0v6AAB',
                                             '0013400001SdXanAAF',
                                             '0018000000sAbbBAAS',
                                             '0013400001RNTbqAAH',
                                             '0018000001CUV8eAAH',
                                             '00180000011rldIAAQ',
                                             '0012T00001a42PiQAI',
                                             '0012T00001u7UpOQAU',
                                             '0013400001Qo1vRAAR',
                                             '0018000000xGzJeAAK',
                                             '0013400001PS5uCAAT',
                                             '0013400001VXouaAAD',
                                             '0018000000UqMSFAA3',
                                             '0018000000meiUmAAI',
                                             '0013400001K5nGNAAZ',
                                             '0013400001PJnJzAAL',
                                             '00180000011dk7gAAA',
                                             '0013400001KMOyvAAH',
                                             '0013400001UgO9pAAF',
                                             '0012T00001tV7yVQAS',
                                             '0013400001MiSI0AAN',
                                             '0012T00001jkhrqQAA',
                                             '0012T00001vNmoKQAS',
                                             '0013400001U7mVUAAZ',
                                             '0013400001JK9ctAAD',
                                             '0013400001SpGH3AAN',
                                             '0013400001Sou2MAAR',
                                             '0012T00001cFRXXQA4',
                                             '0013400001QvrT6AAJ',
                                             '00180000011dl8yAAA',
                                             '0012T00001m11irQAA',
                                             '0012T00001url7iQAA',
                                             '0012T00001iU9AbQAK',
                                             '0012T00001wqykMQAQ',
                                             '0012T00001lF6ZKQA0',
                                             '0012T00001ti7fjQAA',
                                             '0013400001NuKDBAA3',
                                             '0018000001Ao4RpAAJ',
                                             '0018000000ua6BlAAI',
                                             '0012T00001aEPItQAO',
                                             '0013400001Qo1bMAAR',
                                             '0013400001PgjXVAAZ',
                                             '0013400001Qo1hUAAR',
                                             '0013400001Qo0SgAAJ',
                                             '0013400001Qo1jpAAB',
                                             '0013400001Y3IOqAAN',
                                             '0018000001EVWWDAA5',
                                             '0012T00001m4eIRQAY',
                                             '0012T00001wH9JAQA0',
                                             '0012T00001u5icaQAA',
                                             '0018000000ppk90AAA',
                                             '0012T00001wJCDuQAO',
                                             '00180000016MK99AAG',
                                             '0018000000xHk3eAAC',
                                             '0012T00001nkjawQAA',
                                             '0012T00001pzaCLQAY',
                                             '0013400001NvgrhAAB',
                                             '0012T00001m4e7mQAA',
                                             '0012T00001u331hQAA',
                                             '0013400001KYBe2AAH',
                                             '0012T00001tjq5MQAQ',
                                             '0018000000xJ1gSAAS',
                                             '0013400001MmIiGAAV',
                                             '0012T00001eW2QMQA0',
                                             '0012T00001eW2LWQA0',
                                             '0012T00001eW2MAQA0',
                                             '0012T00001eW2LlQAK',
                                             '0012T00001eW2IxQAK',
                                             '0012T00001eW2M1QAK',
                                             '0012T00001eW22cQAC',
                                             '0012T00001eXVVkQAO',
                                             '0012T00001eW2Q2QAK',
                                             '0012T00001eW2QCQA0',
                                             '0012T00001vqdcdQAA',
                                             '00180000019ogNMAAY',
                                             '0013400001SIpdKAAT',
                                             '0018000000s7x8IAAQ',
                                             '0018000000UqM8iAAF',
                                             '0018000000vPuPMAA0',
                                             '0013400001KonzcAAB',
                                             '0012T00001wGvyOQAS',
                                             '0012T00001y2MpuQAE',
                                             '0013400001QWN3YAAX',
                                             '0013400001PS5uAAAT',
                                             '0018000000UqMLVAA3',
                                             '0013400001NrLmuAAF',
                                             '0013400001Qo215AAB',
                                             '0013400001Qo23rAAB',
                                             '0013400001XcRU1AAN')
             order by p.id,apc.role_c, apc.created_date desc
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;

        if x.is_first_row is true then
        v_project_process_step_id = null;
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (x.project_id, 3793, null, 1, null, now(), now(), 2384850, 2384850, false,
                  true, null, null, null, x.alliance_partner_id)
          returning id into v_project_process_step_id;
        end if;
        case
          when x.role_c = 'Builder'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28877, x.org_id::text, true);
          when x.role_c = 'Builder HERS Rater'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28878, x.org_id::text, true);
          when x.role_c = 'Commissioning Partner'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28879, x.org_id::text, true);
          when x.role_c = 'Customer Service Partner'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28880, x.org_id::text, true);
          when x.role_c = 'Dealer'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28881, x.org_id::text, true);
          when x.role_c = 'Design Partner'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28882, x.org_id::text, true);
          when x.role_c = 'DRIP'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28883, x.org_id::text, true);
          when x.role_c = 'EV Electrician'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28884, x.org_id::text, true);
          when x.role_c = 'Field Service Representative'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28886, x.org_id::text, true);
          when x.role_c = 'Inspection Partner'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28887, x.org_id::text, true);
          when x.role_c = 'IP'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28888, x.org_id::text, true);
          when x.role_c = 'MPU Electrician'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28889, x.org_id::text, true);
          when x.role_c = 'Permitting Partner'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28890, x.org_id::text, true);
          when x.role_c = 'PV HERS Provider'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28891, x.org_id::text, true);
          when x.role_c = 'Roofer'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28892, x.org_id::text, true);
          when x.role_c = 'Storage IP'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28893, x.org_id::text, true);
          when x.role_c = 'T24 Energy Consultant'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28894, x.org_id::text, true);
          when x.role_c = 'TPS'
            then perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28895, x.org_id::text, true);
          else
          end case;
      end loop;
    raise notice '3 END = %',clock_timestamp();
    raise notice '3 END total = %',v_total;
  end
$do$;


