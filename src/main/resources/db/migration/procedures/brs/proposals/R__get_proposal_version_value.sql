DROP TYPE IF EXISTS ProposalFieldFilter cascade;

DROP FUNCTION IF EXISTS brs.get_proposal_version_value(p_proposal_version_id bigint,
                                                       p_filters ProposalFieldFilter[],
                                                       p_object_code varchar);
-- This type is used as a filter in a JSONPath query
CREATE TYPE ProposalFieldFilter AS
(
  fieldId       int,
  value         varchar,
  intValue      int,
  intArrayValue int
);
-- usage:
-- select (420, null, 100, null)::ProposalFieldFilter;

CREATE OR REPLACE FUNCTION brs.get_proposal_version_value(p_proposal_version_id bigint,
                                                          p_filters ProposalFieldFilter[] default null,
                                                          p_object_code varchar default null)
  RETURNS setof jsonb AS
$$
DECLARE
  v_path_counter        integer;
  v_query               text;
  v_where_clause        varchar   := '';
  v_item                ProposalFieldFilter;
  v_var                 varchar;
  v_paths               varchar[] := array []::varchar[];
  v_jsonpath            varchar;
  v_proposal_version_id int;
  v_item_data_type      varchar;
BEGIN
  if p_proposal_version_id is null
  then
    raise notice 'no proposal version id; using latest published version';
    select proposal_version_id
    into v_proposal_version_id
    from brs.primary_company_proposal_version p
    where p.company_id = 3;
  else
    v_proposal_version_id := p_proposal_version_id;
  end if;

  v_query := format($query$
    with version_values as (select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) vw.id,
                                                                                                             vw.proposal_group_uuid,
                                                                                                             vw.value,
                                                                                                             vw.object_code,
                                                                                                             vw.field_id
                                from brs.proposal_version_custom_field_value_vw vw
                                where vw.proposal_version_id <= V_PROPOSAL_VERSION_ID
                                    %s
                                    and vw.proposal_group_uuid not in (select distinct proposal_group_uuid
                                                                     from brs.proposal_version_custom_field_group g
                                                                     where proposal_version_id <= V_PROPOSAL_VERSION_ID
                                                                       and archived is not null)
                                order by vw.proposal_group_uuid, vw.custom_field_group_assignment_id, vw.date_modified desc),
             grouped_rows as (select jsonb_build_object('pk', proposal_group_uuid,
                                                        'fields',
                                                        array_to_json(array_agg(jsonb_strip_nulls(
                                                                    jsonb_build_object('fieldId', vv.field_id,
                                                                                       'flowCustomFieldId', cf.flow_custom_field_id) ||
                                                                    vv.value)))
                                         ) as row
                              from version_values vv
                                       inner join brs.custom_field cf on cf.id = vv.field_id
                              group by proposal_group_uuid)
        select * from grouped_rows
        $query$
    ,
                    case
                      when p_object_code is not null
                        then format('and vw.object_code = %L', p_object_code)
                      else '' end);


  if p_filters is not null or array_length(p_filters, 1) > 0 then
--     build the filters
    foreach v_item in array p_filters
      loop
        if v_item.intArrayValue is not null or v_item.intValue is not null or v_item.value is not null then
          v_var = format('(@.fieldId == %s && ', v_item.fieldId);
          case
            when v_item.intArrayValue is not null and v_item.intArrayValue > -1
              then v_var = v_var || format('@.intArrayValue == %s)', v_item.intArrayValue);
            when v_item.intValue is not null and v_item.intValue > -1
              then v_var = v_var || format('@.intValue == %s)', v_item.intValue);
            when v_item.value is not null and lower(v_item.value) != 'undefined'
              then select lower(dt.data_type)
                   into v_item_data_type
                   from brs.custom_field cf
                          inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                          inner join flow.data_type dt on cdt.data_type_id = dt.id
                   where cf.id = v_item.fieldId;

                   case
                     when v_item_data_type in
                          ('text', 'system',
                           'system list',
                           'system multiselect',
                           'rich text')
                       then v_var = v_var || format('@.value == %I)', v_item.value);
                     else v_var = v_var || format('@.value == %s)', v_item.value);
                     end case;
              else
              raise exception 'must specify at least one search param';
            end case;
          if v_var is not null then
            v_paths := array_append(v_paths, v_var);
          end if;
        end if;

        v_item_data_type := null;
      end loop;

    v_path_counter := 0;
    if array_length(v_paths, 1) > 0 then
      v_where_clause = ' where ( ';
      foreach v_jsonpath in array v_paths
        loop
          if v_path_counter > 0 then
            v_where_clause = v_where_clause || ' and ';
          end if;
          v_where_clause = v_where_clause
            || format('jsonb_path_exists(row, ''$.fields[*] ? %s'' )', v_jsonpath);
          v_path_counter = v_path_counter + 1;
        end loop;
      v_where_clause = v_where_clause || ' )';
    end if;

    v_query = v_query || v_where_clause;

  end if;

  v_query = replace(v_query, 'V_PROPOSAL_VERSION_ID', v_proposal_version_id::varchar);
--   raise notice 'SQL %', v_query;
  return query execute v_query;
END;
$$
  LANGUAGE plpgsql;


-- usage:
-- select jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 123 )')
-- from brs.get_proposal_version_value(300, array [(122, 84199, null, null)::ProposalFieldFilter]);
