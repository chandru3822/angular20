DROP FUNCTION if exists flow.search_contacts_by_user( character varying,  bigint,
                                                      boolean,  bigint,
                                                      bigint,  bigint);

DROP FUNCTION if exists flow.search_contacts_with_down_line(p_searchterm character varying, p_company_id bigint,
                                                            p_is_parent boolean, p_userid bigint,
                                                            p_limit bigint, p_offset bigint);

DROP FUNCTION IF EXISTS flow.search_contacts(p_searchterm character varying, p_company_id bigint,
                                             p_is_parent boolean,
                                             p_limit bigint, p_offset bigint);