-- This script creates a scopus-id publication nodelist and edgelist,
-- for the pure purpose of network calculation.

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 01/25/2017

-- Create gen1 scopus-id


drop table if exists alemtuzumab_gen1_pubsid;
create table alemtuzumab_gen1_pubsid tablespace elsevier_tbs as
select distinct b.pub_sid from alemtuzumab_pmid1 a
join alemtuzumab_scopus_pub_out b
on a.pmid = b.pmid::integer;

-- Create gen2 scopus-id
drop table if exists alemtuzumab_gen2_pubsid;
create table alemtuzumab_gen2_pubsid tablespace elsevier_tbs as
select distinct b.ref_sid as pub_sid from alemtuzumab_gen1_pubsid a
join alemtuzumab_scopus_pub_cites b
on a.pub_sid = b.pub_sid;

-- Create publications edgelist
drop table if exists alemtuzumab_pub_edgelist;
create table alemtuzumab_pub_edgelist tablespace elsevier_tbs as
select distinct a.pub_sid, a.ref_sid from alemtuzumab_scopus_pub_cites a
join alemtuzumab_gen1_pubsid b
on a.pub_sid = b.pub_sid;

insert into alemtuzumab_pub_edgelist
  select distinct a.pub_sid, a.ref_sid from alemtuzumab_scopus_pub_cites a
  join alemtuzumab_gen2_pubsid b
  on a.pub_sid = b.pub_sid
  where a.ref_sid in (select * from alemtuzumab_gen1_pubsid);

-- Create publications nodelist
drop table if exists alemtuzumab_pub_nodelist;
create table alemtuzumab_pub_nodelist tablespace elsevier_tbs as
  select * from alemtuzumab_gen1_pubsid;

insert into alemtuzumab_pub_nodelist
  select * from alemtuzumab_gen2_pubsid
  where pub_sid not in (select * from alemtuzumab_gen1_pubsid);
