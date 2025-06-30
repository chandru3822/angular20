CREATE TABLE if not exists flow.api_config_type
(
  id                       serial  NOT NULL,
  config_name        varchar(255) not null,
  config_name_code   varchar(255) not null,
  parent_list_of_value_id  bigint not null,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT flow_api_config_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_act_parent_list_of_value_id_fk FOREIGN KEY (parent_list_of_value_id)
    REFERENCES flow.list_of_value (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_act123_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_act12222_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create index if not exists act_parent_list_of_value_id_idx on flow.api_config_type(parent_list_of_value_id);
create index if not exists act_config_name_code_idx on flow.api_config_type(config_name_code);

CREATE TABLE if not exists flow.api_config
(
  id                       serial  NOT NULL,
  api_config_type_id     bigint not null,
  list_of_value_id  bigint not null,
  value            text not null,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT flow_api_config_pk PRIMARY KEY (id),
  CONSTRAINT flow_apic__list_of_value_id_fk FOREIGN KEY (list_of_value_id)
    REFERENCES flow.list_of_value (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_api_config_123_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_api_config_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create index if not exists api_config_list_of_value_id_idx on flow.api_config(list_of_value_id);
create unique index if not exists api_config_list_of_value_id_ap_type_idx on flow.api_config(list_of_value_id,api_config_type_id);


insert into flow.api_config_type(config_name, config_name_code, parent_list_of_value_id, date_created, date_modified, created_by_id, modified_by_id, archived)
(select 'Inverter Brand','INVERTER_BRAND',143,now(),now(),2384850,2384850,false
 where not exists(select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'));

insert into flow.api_config_type(config_name, config_name_code, parent_list_of_value_id, date_created, date_modified, created_by_id, modified_by_id, archived)
  (select 'Panel Brand','PANEL_BRAND',238,now(),now(),2384850,2384850,false
   where not exists(select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'));

insert into flow.api_config_type(config_name, config_name_code, parent_list_of_value_id, date_created, date_modified, created_by_id, modified_by_id, archived)
  (select 'Storage Type','STORAGE_TYPE',26297,now(),now(),2384850,2384850,false
   where not exists(select id from flow.api_config_type where config_name_code = 'STORAGE_TYPE'));



insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),23914,'IQ8M-72-2-US [240V],IQ8M-72-M-US',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),24094,'IQ8X-80-M-US [240V],IQ8X-80-M-US (240V)',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),20285,'IQ8PLUS-72-M-US [240V],IQ8PLUS-72-2-US',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),28308,'IQ8MC-72-2-US [240V],IQ8MC-72-M-US (240V)',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),29236,'IQ8HC-72-2-US [240V],IQ8HC-72-M-US (240V)',now(),2384850,2384850);



insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),243,'REC Solar',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),23877,'Silfab Solar Inc.',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),247,'Jinko Solar',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),242,'Hanwha Q CELLS',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),248,'SEG SOLAR INC.',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),26296,'JA Solar',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),252,'LONGi Solar',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),24669,'Seraphim Solar System Co., Ltd.',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'PANEL_BRAND'),20372,'CertainTeed',now(),2384850,2384850);




insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'STORAGE_TYPE'),29139,'selfConsumption,self consumption,self_consumption',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'STORAGE_TYPE'),26298,'backupDuringOutage',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'STORAGE_TYPE'),26299,'savingsOnElectricityBill,energy_arbitrage,energy arbitrage',now(),2384850,2384850);




insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),19146,'IQ 7+ (240V)',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),429,'IQ7-60-2-US (240V)',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),20275,'IQ7A-72-2-US (240V),IQ7A-72-2-INT',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),22929,'IQ7HS-66-M-US (240V',now(),2384850,2384850);

insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),23299,'IQ7X-96-2-US (240V),IQ7X-96-2-INT',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),22928,'IQ8A-72-2-US',now(),2384850,2384850);

insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),24441,'GW9600A-MS (240V)',now(),2384850,2384850);
insert into flow.api_config(api_config_type_id, list_of_value_id, value, date_modified, created_by_id, modified_by_id)
values((select id from flow.api_config_type where config_name_code = 'INVERTER_BRAND'),24445,'Powerwall 3 (integrated inverter)',now(),2384850,2384850);


