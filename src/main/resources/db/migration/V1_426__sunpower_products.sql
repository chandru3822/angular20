create table if not exists brs.sunpower_product
(
    id               bigserial
    constraint sunpower_product_pk
    primary key,
    sunpower_id                     varchar(200)            not null,
    product_name                    varchar(500)            not null,
    product_type                    varchar(200)            not null,
    archived         boolean   default false not null,
    date_created     timestamp,
    date_modified    timestamp default now()
);

create unique index if not exists sunpower_product_name_uindex
  on brs.sunpower_product (product_name);

-- Financial Products
insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '36e73111-fc76-4222-99d6-db96256a3be8','5 Year Loan at 8.99% APR','FINANCIAL',false,now()
  where not exists (select id from brs.sunpower_product where product_name = '5 Year Loan at 8.99% APR');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '4968dde0-b0d3-4eee-bbd5-8e9ceef32132','10 Year Loan at 9.74% APR','FINANCIAL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = '10 Year Loan at 9.74% APR');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'e2d09af5-0a74-4be8-adf4-0fa80d884b45','15 Year Loan at 4.99% APR','FINANCIAL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = '15 Year Loan at 4.99% APR');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '51ce78ce-3648-42ee-9111-f881882e91a2','20 Year Loan at 3.99% APR','FINANCIAL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = '20 Year Loan at 3.99% APR');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '61f96a09-da72-46b3-965d-7c0fc063e421','25 Year Loan at 3.99% APR','FINANCIAL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = '25 Year Loan at 3.99% APR');

-- Panels
insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '7a62a698-5a2c-4f76-bfc6-390ddb48c013','REC','PANEL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'REC');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'ef3682ea-29e4-453b-8870-4a3f7803b515','SPR-U400-BLK','PANEL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SPR-U400-BLK');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'ef3682ea-29e4-453b-8870-4a3f7803b515','SPR-U4000-BLK','PANEL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SPR-U4000-BLK');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '4f4f34e0-11d0-4ec9-87cb-29d527ccd98e','QCells 400','PANEL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'QCells 400');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'ca01a5a1-1216-44e2-9349-2f4c1f1fc4da','URECO - United Renewable Energy Co. 400','PANEL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'URECO - United Renewable Energy Co. 400');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '76e76560-d34d-4e03-bc9f-f060fc90270a','SEG SOLAR INC. 405','PANEL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SEG SOLAR INC. 405');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'dc6dee61-244a-40d9-a1d2-92c3010d1553','SEG SOLAR INC. 400','PANEL',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SEG SOLAR INC. 400');

-- Inverter
insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'bcafa7ab-a358-4787-820d-25c35f35bb2b','Enphase IQ7A Microinverters','INVERTER',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'Enphase IQ7A Microinverters');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '6b91c7c3-0d0e-4d7b-ab88-de491f9035ba','Enphase IQ7 Microinverters','INVERTER',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'Enphase IQ7 Microinverters');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '6a88f9dd-b24e-4cf0-af79-1bb51e33f7d0','Enphase IQ8+ Microinverters','INVERTER',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'Enphase IQ8+ Microinverters');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'f52fb971-f12f-41bb-9443-2a38e4a86497','Enphase IQ7+ Microinverters','INVERTER',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'Enphase IQ7+ Microinverters');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '2f96e2d9-e5aa-4f78-9292-a8f334734171','SPR-A5 Microinverters','INVERTER',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SPR-A5 Microinverters');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'a4729499-fce5-4ad1-9e54-346687d48fe6','Enphase IQ7X Microinverters','INVERTER',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'Enphase IQ7X Microinverters');

-- Battery
insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'd240090d-0ad7-4e0b-b0a9-da15d5c5a87b','SunPower SunVault 13.0','BATTERY',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SunPower SunVault 13.0');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '744b846c-332d-4335-8a3f-4635429d2137','SunPower SunVault 19.5','BATTERY',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SunPower SunVault 19.5');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select 'fbdd477d-fae3-4270-8e51-2924c545f4ef','SunPower SunVault 26.0','BATTERY',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SunPower SunVault 26.0');

insert into brs.sunpower_product(sunpower_id, product_name, product_type, archived, date_created)
select '59c739ff-528d-4278-aaa2-8fc7aed17ceb','SunPower SunVault 39.0','BATTERY',false,now()
    where not exists (select id from brs.sunpower_product where product_name = 'SunPower SunVault 39.0');
