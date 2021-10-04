drop function if exists flow.search_contacts(character varying, integer, boolean,
                integer, integer);

drop function  if exists flow.search_contacts_by_user( character varying,  integer,
                                                         boolean,
                                                         integer ,
                                                         integer ,
                                                         integer);

drop function if exists flow.search_contacts_with_down_line( character varying, integer,
                                                                boolean,
                                                                integer,
                                                                integer,
                                                                integer);
