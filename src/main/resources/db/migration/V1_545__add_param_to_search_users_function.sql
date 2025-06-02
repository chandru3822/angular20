-- Dropping old search_users function for new param addition

DROP FUNCTION IF EXISTS flow.search_users(p_searchterm character varying,
                                          p_first_name character varying,
                                          p_last_name character varying,
                                          p_email character varying,
                                          p_phone character varying,
                                          p_company_id bigint,
                                          p_primary_flag boolean,
                                          p_status_ids bigint[],
                                          p_position_ids bigint[],
                                          p_org_ids bigint[],
                                          p_limit bigint,
                                          p_offset bigint);

