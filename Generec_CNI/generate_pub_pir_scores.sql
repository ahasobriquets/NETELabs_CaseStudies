
-- passing parameters: alemtuzumab alemtuzumab_pub_nodelist alemtuzumab_pub_edgelist alemtuzumab_scopus_pub_auth


drop table if exists alemtuzumab_test_network;
select distinct pub_sid into alemtuzumab_test_network from alemtuzumab_pub_nodelist;
--5188

drop table if exists temp_test_network_citation_pre;
select ref_sid as pub_sid , count(pub_sid) as citation into temp_test_network_citation_pre from alemtuzumab_pub_edgelist group by ref_sid;
--5104

drop table if exists alemtuzumab_testnetwork_citation;
select a.pub_sid, coalesce(b.citation,0) as citation
into  alemtuzumab_testnetwork_citation
from alemtuzumab_test_network a
left join temp_test_network_citation_pre b
on a.pub_sid = b.pub_sid
order by citation;
--5188


drop table if exists temp_testnetwork_pub_pir_pre;
select a.pub_sid, b.citation as pub_cit, a.ref_sid, c.citation as ref_cit
into temp_testnetwork_pub_pir_pre
from alemtuzumab_pub_edgelist a
left join alemtuzumab_testnetwork_citation b
on a.pub_sid = b.pub_sid
left join alemtuzumab_testnetwork_citation c
on a.ref_sid = c.pub_sid
order by ref_sid;
--9492

drop table if exists temp_testnetwork_pub_pir_pre1;
select ref_sid as pub_sid, sum(pub_cit)+ref_cit as pub_pir
into  temp_testnetwork_pub_pir_pre1
from temp_testnetwork_pub_pir_pre group by ref_sid,ref_cit;
--5104


drop table if exists temp_testnetwork_pub_pir_pre2;

select a.pub_sid, b.pub_pir
into temp_testnetwork_pub_pir_pre2
from alemtuzumab_test_network a
left join temp_testnetwork_pub_pir_pre1 b
on a.pub_sid = b.pub_sid;


drop table if exists alemtuzumab_testnetwork_pub_pir;
select pub_sid, coalesce(pub_pir,0) as pub_pir
into alemtuzumab_testnetwork_pub_pir
from temp_testnetwork_pub_pir_pre2;



--Cleaning
drop table if exists temp_test_network_citation_pre;
drop table if exists temp_testnetwork_pub_pir_pre;
drop table if exists temp_testnetwork_pub_pir_pre1;
drop table if exists temp_testnetwork_pub_pir_pre2;

