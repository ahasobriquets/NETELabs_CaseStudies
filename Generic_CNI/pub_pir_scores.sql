

-- Author: Samet Keserci
-- Usage: psql -d elsevier -v node_list=$nodelist -v edge_list=$edgelist -v -f test_parameter.sql
-- where nodelist=${drug_name}_pub_nodelist and edgelist=${drug_name}_pub_edgelist. See generic_CNI_master.sh script



-- Passing parameters: drug drug_pub_nodelist drug_pub_edgelist drug_scopus_pub_auth as node_list and edge_list
drop table if exists drug_test_network;
select distinct pub_sid into drug_test_network from :node_list;


drop table if exists temp_test_network_citation_pre;
select ref_sid as pub_sid , count(pub_sid) as citation into temp_test_network_citation_pre from :edge_list group by ref_sid;

drop table if exists drug_testnetwork_citation;
select a.pub_sid, coalesce(b.citation,0) as citation
into  drug_testnetwork_citation
from drug_test_network a
left join temp_test_network_citation_pre b
on a.pub_sid = b.pub_sid
order by citation;


drop table if exists temp_testnetwork_pub_pir_pre;
select a.pub_sid, b.citation as pub_cit, a.ref_sid, c.citation as ref_cit
into temp_testnetwork_pub_pir_pre
from :edge_list a
left join drug_testnetwork_citation b
on a.pub_sid = b.pub_sid
left join drug_testnetwork_citation c
on a.ref_sid = c.pub_sid
order by ref_sid;

drop table if exists temp_testnetwork_pub_pir_pre1;
select ref_sid as pub_sid, sum(pub_cit)+ref_cit as pub_pir
into  temp_testnetwork_pub_pir_pre1
from temp_testnetwork_pub_pir_pre group by ref_sid,ref_cit;


drop table if exists temp_testnetwork_pub_pir_pre2;

select a.pub_sid, b.pub_pir
into temp_testnetwork_pub_pir_pre2
from drug_test_network a
left join temp_testnetwork_pub_pir_pre1 b
on a.pub_sid = b.pub_sid;


drop table if exists drug_testnetwork_pub_pir;
select pub_sid, coalesce(pub_pir,0) as pub_pir
into drug_testnetwork_pub_pir
from temp_testnetwork_pub_pir_pre2;



--Cleaning
drop table if exists temp_test_network_citation_pre;
drop table if exists temp_testnetwork_pub_pir_pre;
drop table if exists temp_testnetwork_pub_pir_pre1;
drop table if exists temp_testnetwork_pub_pir_pre2;
