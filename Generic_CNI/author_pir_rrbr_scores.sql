
-- Author: Samet Keserci
-- Usage: psql -d elsevier -v author_pub=$authorpub -f author_pir_rrbr_scores.sql
-- where authorpub=${drug_name}_scopus_pub_auth. See generic_CNI_master.sh script


-- Passing parameters: drug_scopus_pub_auth as author_pub.
-- Generate the pir score and the total number of the publication in test network for each
drop table if exists temp_testnetwork_pub_auth_pir;
select a.auth_sid, a.full_name, count(b.pub_sid) as doc_count_test,sum(b.pub_pir) as auth_pir ,a.doc_count
into temp_testnetwork_pub_auth_pir
from :author_pub a
inner join drug_testnetwork_pub_pir b
on a.pub_sid=b.pub_sid
group by a.auth_sid,a.full_name,a.doc_count;

--seperate the authors to those have total_doc_count
drop table if exists drug_author_pir_degenerate_rrbr;
select auth_sid,full_name,auth_pir,doc_count_test, doc_count
into drug_author_pir_degenerate_rrbr
from temp_testnetwork_pub_auth_pir
where doc_count is null;

-- generate rrbr score for non-degenrate doc_count
drop table if exists drug_author_pir_rrbr;
select distinct auth_sid,full_name,doc_count_test,doc_count as doc_count_total, doc_count_test/doc_count::float as auth_rrbr,auth_pir
into drug_author_pir_rrbr
from temp_testnetwork_pub_auth_pir
where doc_count is not null;


--Cleaning intermediate tables
drop table if exsits temp_testnetwork_pub_auth_pir;
