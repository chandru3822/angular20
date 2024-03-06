drop function if exists flow.search_projects_by_user(p_searchterm character varying, p_company_id bigint,
                                                     p_user_id bigint, p_is_parent boolean,
                                                     p_limit bigint ,
                                                     p_offset bigint ,
                                                     p_company_project_status_type_id bigint ,
                                                     p_sort_column character varying ,
                                                     p_sort_direction character varying);

drop function if exists flow.search_projects_with_down_line(p_searchterm character varying, p_company_id bigint,
                                                            p_user_id bigint, p_is_parent boolean, p_limit bigint,
                                                            p_offset bigint,
                                                            p_company_project_status_type_id bigint,
                                                            p_sort_column character varying,
                                                            p_sort_direction character varying );


alter table flow.company_project_status_type add column if not exists used_in_commissions boolean not null default false;

update flow.company_project_status_type cpst
set used_in_commissions = true
where id in (63,64,65,66);
