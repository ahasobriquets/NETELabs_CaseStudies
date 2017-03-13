-- This script creates a scopus-id publication nodelist and edgelist,
-- for the pure purpose of network calculation.

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 01/25/2017

-- drug* will be replaced by the actual drug_name


-- Create gen1 scopus-id


drop table if exists drug_gen1_pubsid;
create table drug_gen1_pubsid tablespace elsevier_tbs as
select distinct b.pub_sid from drug_pmid1 a
join drug_scopus_pub_out b
on a.pmid = b.pmid::integer;

-- Create gen2 scopus-id
drop table if exists drug_gen2_pubsid;
create table drug_gen2_pubsid tablespace elsevier_tbs as
select distinct b.ref_sid as pub_sid from drug_gen1_pubsid a
join drug_scopus_pub_cites b
on a.pub_sid = b.pub_sid;

-- Create publications edgelist
drop table if exists drug_pub_edgelist;
create table drug_pub_edgelist tablespace elsevier_tbs as
select distinct a.pub_sid, a.ref_sid from drug_scopus_pub_cites a
join drug_gen1_pubsid b
on a.pub_sid = b.pub_sid;

insert into drug_pub_edgelist
  select distinct a.pub_sid, a.ref_sid from drug_scopus_pub_cites a
  join drug_gen2_pubsid b
  on a.pub_sid = b.pub_sid
  where a.ref_sid in (select * from drug_gen1_pubsid);

-- Create publications nodelist
drop table if exists drug_pub_nodelist;
create table drug_pub_nodelist tablespace elsevier_tbs as
  select * from drug_gen1_pubsid;

insert into drug_pub_nodelist
  select * from drug_gen2_pubsid
  where pub_sid not in (select * from drug_gen1_pubsid);
