

# Author: Samet Keserci
# Usage: sh create_scopus_tables.sh [drug_name]
# Date: 03/07/17



drug_name=$1

# load data from the directory  /labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/

psql -d elsevier -c "create table  ${drug_name}_scopus_pub_affs(pub_sid varchar(30),aff_sid varchar(30), name  varchar(500),city varchar(500),country varchar(500),url varchar(1000)) "
psql -d elsevier -c "create table  ${drug_name}_scopus_pub_auth_affs(auth_sid varchar(30),aff_sid varchar(30),is_current varchar(20)) "
psql -d elsevier -c "create table  ${drug_name}_scopus_pub_auth(pub_sid varchar(30),auth_sid varchar(30), full_name  varchar(500),last_name varchar(500),first_name varchar(500),initials varchar(100), doc_count varchar(10))"
psql -d elsevier -c "create table  ${drug_name}_scopus_pub_cites(pub_sid varchar(30),ref_sid varchar(30),source_year varchar(4), source_name varchar(500),source_volume varchar(500), source_first_page varchar(500), source_last_page varchar(500), title text, text text ) "
psql -d elsevier -c "create table  ${drug_name}_scopus_pub_idx(pub_sid varchar(30), name varchar(5000)) "
psql -d elsevier -c "create table  ${drug_name}_scopus_pub_key(pub_sid varchar(30), name varchar(5000)) "
psql -d elsevier -c "create table  ${drug_name}_scopus_pub_out(pub_sid varchar(30), pmid varchar(30), doi varchar(500), eid varchar(500), publish_date varchar(100), title varchar(5000)) "
psql -d elsevier -c "create table  ${drug_name}_scopus_pub_src(pub_sid varchar(30), issn varchar(100), type varchar(100), name varchar(500), cover_date varchar(100), volume varchar(200), issue varchar(100), pages varchar(200) ) "
psql -d elsevier -c "create table  ${drug_name}_scopus_pub_subj(pub_sid varchar(30),code varchar(50),abbr varchar(50),name varchar(500)) "
